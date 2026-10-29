import { FieldValue } from 'firebase-admin/firestore';
import { digest, validatePurchase } from './purchase-validation.js';

// A single transaction delivers both order and questionnaire, even after a
// timeout/retry. No account balance is credited by a payment callback.
export async function fulfillPurchase(db, { uid, productId, purchaseToken, purchase }) {
  const intentId = purchase.obfuscatedExternalProfileId;
  if (typeof intentId !== 'string' || !/^[A-Za-z0-9_-]{1,128}$/.test(intentId)) throw new Error('invalid-intent');
  const intentRef = db.collection('playPurchaseIntents').doc(intentId);
  const receiptRef = db.collection('playPurchases').doc(digest(purchaseToken));
  const orderRef = db.collection('orders').doc(intentId);
  const time = () => FieldValue.serverTimestamp();
  await db.runTransaction(async (tx) => {
    const [intentDoc, receiptDoc] = await Promise.all([tx.get(intentRef), tx.get(receiptRef)]);
    const intent = intentDoc.data();
    if (!intent) throw new Error('intent-not-found');
    validatePurchase(purchase, { uid, intent: { ...intent, id: intentId }, productId });
    if (receiptDoc.exists) {
      const receipt = receiptDoc.data();
      if (receipt.userId !== uid || receipt.orderId !== intentId || receipt.productId !== productId || receipt.revoked) {
        throw new Error('receipt-already-used-or-revoked');
      }
      return;
    }
    if (intent.status !== 'pending' || purchase.consumptionState === 1) throw new Error('purchase-already-used');
    tx.create(receiptRef, { userId: uid, orderId: intentId, productId,
      googleOrderId: purchase.orderId ?? null, purchaseToken,
      consumed: false, revoked: false, createdAt: time() });
    tx.update(intentRef, { status: 'paid', updatedAt: time() });
    tx.create(orderRef, {
      userId: uid, mentorId: intent.mentorId, layananId: intent.serviceId,
      layananType: intent.serviceId === 'kuesioner' ? 'kuesioner' : 'mentoring',
      packageId: intent.packageId ?? null,
      price: intent.price, currency: intent.currency, status: 'waiting verification',
      billingProvider: 'google_play', paymentStatus: 'paid',
      productId, receiptId: receiptRef.id, createdAt: time(), updatedAt: time(),
      mentorNet: intent.mentorId === 'system' ? 0 : Math.floor(intent.price * 85 / 100),
      balanceState: intent.mentorId === 'system' ? 'none' : 'pending',
    });
    if (intent.mentorId !== 'system') {
      const mentorNet = Math.floor(intent.price * 85 / 100);
      tx.update(db.collection('users').doc(intent.mentorId), { playPending: FieldValue.increment(mentorNet) });
      tx.create(db.collection('financeLedger').doc(`payment_${intentId}`), {
        orderId: intentId, mentorId: intent.mentorId, kind: 'payment_verified',
        gross: intent.price, mentorNet, platformCommission: intent.price - mentorNet,
        // Google service fees/taxes are separate and must be reconciled with
        // Google's financial reports. They never silently reduce mentorNet.
        createdAt: time(),
      });
    }
    if (intent.questionnaire) {
      tx.create(db.collection('kuesioners').doc(intentId), {
        ...intent.questionnaire, userId: uid, orderId: intentId,
        status: 'waiting verification', answers: [], signedBy: [],
        createdAt: time(), updatedAt: time(),
      });
    }
  });
  return { orderId: intentId, receiptRef };
}
