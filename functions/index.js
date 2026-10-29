import { getApps, initializeApp } from 'firebase-admin/app';
import { getFirestore, FieldValue } from 'firebase-admin/firestore';
import { onCall, HttpsError } from 'firebase-functions/v2/https';
import { onMessagePublished } from 'firebase-functions/v2/pubsub';
import { defineBoolean } from 'firebase-functions/params';
import { GoogleAuth } from 'google-auth-library';
import { PACKAGE_NAME, digest, validateSelection } from './purchase-validation.js';

import { fulfillPurchase } from './fulfill-purchase.js';
import { changePlayOrderStatus, reserveWithdrawal, changeWithdrawalStatus, revokePlayPurchase } from './finance.js';

if (getApps().length === 0) initializeApp();
const db = getFirestore();
const billingEnabled = defineBoolean('PLAY_BILLING_ENABLED', { default: false });
const googleAuth = new GoogleAuth({ scopes: ['https://www.googleapis.com/auth/androidpublisher'] });
const options = { region: 'asia-southeast2', maxInstances: 5 };
const time = () => FieldValue.serverTimestamp();

function requireUser(request) {
  if (!request.auth || request.auth.token.firebase?.sign_in_provider === 'anonymous') {
    throw new HttpsError('unauthenticated', 'Login diperlukan.');
  }
  return request.auth.uid;
}

async function playRequest(productId, token, consume = false) {
  const client = await googleAuth.getClient();
  const url = `https://androidpublisher.googleapis.com/androidpublisher/v3/applications/${PACKAGE_NAME}/purchases/products/${encodeURIComponent(productId)}/tokens/${encodeURIComponent(token)}${consume ? ':consume' : ''}`;
  // Never log request objects: the URL contains a purchase token.
  try {
    const response = await client.request({ url, method: consume ? 'POST' : 'GET' });
    return response.data;
  } catch {
    // Gaxios errors can contain URLs, OAuth headers and purchase tokens.
    // Retry with a safe error rather than letting that object enter logs.
    throw new Error('Google Play API request failed');
  }
}

export const preparePlayPurchase = onCall(options, async (request) => {
  const uid = requireUser(request);
  if (!billingEnabled.value()) throw new HttpsError('failed-precondition', 'Pembayaran belum diaktifkan.');
  let selection;
  try { selection = validateSelection(request.data); }
  catch { throw new HttpsError('invalid-argument', 'Pilihan layanan tidak valid.'); }
  const catalogId = selection.serviceId === 'kuesioner' ? 'kuesioner' : `mentoring_${selection.packageId}`;
  const catalog = (await db.collection('playBillingCatalog').doc(catalogId).get()).data();
  const expectedPrice = selection.serviceId === 'kuesioner' ? 25000 : selection.packageId === 'basic' ? 75000 : 250000;
  if (!catalog?.enabled || typeof catalog.productId !== 'string' ||
      catalog.price !== expectedPrice) {
    throw new HttpsError('failed-precondition', 'Produk belum tersedia.');
  }
  if (selection.serviceId !== 'kuesioner') {
    if (selection.mentorId === uid) throw new HttpsError('invalid-argument', 'Pilih mentor lain.');
    const service = (await db.collection('layanan').doc(selection.serviceId).get()).data();
    if (!service || !['paperlink', 'complink'].includes(service.type)) {
      throw new HttpsError('failed-precondition', 'Layanan tidak tersedia.');
    }
    selection.serviceType = service.type;
    const mentor = (await db.collection('users').doc(selection.mentorId).get()).data();
    if (mentor?.role !== 'mentor' || mentor.status !== 'active' || mentor.verificationStatus !== 'verified' ||
        !Array.isArray(mentor.layananIds) || !mentor.layananIds.includes(selection.serviceId)) {
      throw new HttpsError('failed-precondition', 'Mentor tidak tersedia untuk layanan ini.');
    }
  }
  if (request.data?.quoteOnly === true) return { productId: catalog.productId };
  const intent = db.collection('playPurchaseIntents').doc();
  await db.runTransaction(async (tx) => {
    const limitRef = db.collection('playPurchaseLimits').doc(uid);
    const limit = (await tx.get(limitRef)).data() ?? {};
    const now = Date.now();
    const minute = Math.floor(now / 60000);
    const day = Math.floor(now / 86400000);
    const minuteCount = limit.minute === minute ? limit.minuteCount ?? 0 : 0;
    const dayCount = limit.day === day ? limit.dayCount ?? 0 : 0;
    if (minuteCount >= 20 || dayCount >= 100) throw new HttpsError('resource-exhausted', 'Terlalu banyak percobaan. Coba lagi nanti.');
    tx.set(limitRef, { minute, day, minuteCount: minuteCount + 1, dayCount: dayCount + 1, updatedAt: time() });
    tx.create(intent, { ...selection, userId: uid, productId: catalog.productId,
      price: catalog.price, currency: 'IDR', status: 'pending', createdAt: time() });
  });
  return { productId: catalog.productId, intentId: intent.id, accountId: digest(uid) };
});

export const verifyPlayPurchase = onCall(options, async (request) => {
  const uid = requireUser(request);
  const { productId, purchaseToken } = request.data ?? {};
  if (typeof productId !== 'string' || !/^[a-z0-9_.]{1,200}$/.test(productId) ||
      typeof purchaseToken !== 'string' || !purchaseToken || purchaseToken.length > 10000) {
    throw new HttpsError('invalid-argument', 'Transaksi tidak valid.');
  }
  let purchase;
  try { purchase = await playRequest(productId, purchaseToken); }
  catch { throw new HttpsError('unavailable', 'Verifikasi Google Play belum tersedia.'); }
  let fulfillment;
  try { fulfillment = await fulfillPurchase(db, { uid, productId, purchaseToken, purchase }); }
  catch { throw new HttpsError('permission-denied', 'Pembelian belum sah untuk akun dan pesanan ini.'); }
  const { receiptRef, orderId } = fulfillment;
  // Persist first, consume second. Retrying after a network failure is safe.
  try {
    if (purchase.consumptionState !== 1) await playRequest(productId, purchaseToken, true);
    await receiptRef.update({ consumed: true, consumedAt: time() });
  } catch {
    throw new HttpsError('unavailable', 'Pesanan tersimpan; konfirmasi pembayaran perlu dicoba lagi.');
  }
  return { verified: true, orderId };
});

// Pub/Sub IAM must only allow Google Play's notification publisher. Never expose
// this as an unauthenticated HTTP webhook or trust notificationType as proof.
export const playBillingNotification = onMessagePublished(
  { ...options, topic: 'cermatify-play-billing', retry: true },
  async (event) => {
    const payload = event.data.message.json;
    if (payload.packageName !== PACKAGE_NAME) return;
    const notification = payload.oneTimeProductNotification ?? payload.voidedPurchaseNotification;
    if (!notification) return;
    const { purchaseToken } = notification;
    if (typeof purchaseToken !== 'string') return;
    const receipt = (await db.collection('playPurchases').doc(digest(purchaseToken)).get()).data();
    const sku = notification.sku ?? receipt?.productId;
    if (typeof sku !== 'string' || typeof purchaseToken !== 'string') return;
    const purchase = await playRequest(sku, purchaseToken);
    if (purchase.purchaseState === 0) {
      // Finish pending purchases even if the app was closed before payment
      // completed. Identity comes from Google's signed-in purchase binding and
      // our server intent, never from the Pub/Sub payload's claimed user.
      const intentId = purchase.obfuscatedExternalProfileId;
      if (typeof intentId !== 'string' || !/^[A-Za-z0-9_-]{1,128}$/.test(intentId)) return;
      const intent = (await db.doc(`playPurchaseIntents/${intentId}`).get()).data();
      if (!intent) return;
      const result = await fulfillPurchase(db, { uid: intent.userId, productId: sku, purchaseToken, purchase });
      if (purchase.consumptionState !== 1) await playRequest(sku, purchaseToken, true);
      await result.receiptRef.update({ consumed: true, consumedAt: time() });
      return;
    }
    if (purchase.purchaseState !== 1) return;
    await revokePlayPurchase(db, digest(purchaseToken), sku);
  },
);

export const updatePlayOrderStatus = onCall(options, async (request) => {
  const uid = requireUser(request);
  try { await changePlayOrderStatus(db, uid, request.data?.orderId, request.data?.status); }
  catch { throw new HttpsError('failed-precondition', 'Status atau pembayaran pesanan tidak mengizinkan perubahan ini.'); }
  return { updated: true };
});

export const requestWithdrawal = onCall(options, async (request) => {
  const uid = requireUser(request);
  try { return await reserveWithdrawal(db, uid, request.data); }
  catch { throw new HttpsError('failed-precondition', 'Periksa saldo tersedia, rekening, dan status akun. Minimal pencairan Rp20.000. Jangan mengirim ulang dengan ID baru jika sebelumnya sudah tercatat.'); }
});

export const updateWithdrawalStatus = onCall(options, async (request) => {
  const uid = requireUser(request);
  try { await changeWithdrawalStatus(db, uid, request.data?.withdrawalId, request.data?.status, request.data?.notes ?? ''); }
  catch { throw new HttpsError('failed-precondition', 'Periksa status, dana tertahan, dan referensi transfer untuk menyelesaikan pencairan.'); }
  return { updated: true };
});
