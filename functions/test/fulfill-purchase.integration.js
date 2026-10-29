import test, { before, beforeEach, after } from 'node:test';
import assert from 'node:assert/strict';
import { initializeApp, deleteApp } from 'firebase-admin/app';
import { getFirestore } from 'firebase-admin/firestore';
import { fulfillPurchase } from '../fulfill-purchase.js';
import { digest } from '../purchase-validation.js';
import { changePlayOrderStatus, reserveWithdrawal, changeWithdrawalStatus, revokePlayPurchase } from '../finance.js';

// Fail closed: these tests must never touch a live Firebase project.
if (!process.env.FIRESTORE_EMULATOR_HOST || process.env.GCLOUD_PROJECT !== 'demo-cermatify') {
  throw new Error('Run only through Firebase emulators:exec --project demo-cermatify');
}
const app = initializeApp({ projectId: 'demo-cermatify' });
const db = getFirestore(app);
process.env.PLAY_BILLING_ENABLED = 'true';
const { preparePlayPurchase } = await import('../index.js');
const purchase = { purchaseState: 0, consumptionState: 0, quantity: 1,
  obfuscatedExternalAccountId: digest('alice'), obfuscatedExternalProfileId: 'intent1' };
const request = { uid: 'alice', productId: 'paper_basic', purchaseToken: 'test-token', purchase };
before(async () => { await db.doc('test/connection').set({ emulator: true }); });
beforeEach(async () => {
  const response = await fetch(`http://${process.env.FIRESTORE_EMULATOR_HOST}/emulator/v1/projects/demo-cermatify/databases/(default)/documents`, { method: 'DELETE' });
  assert.equal(response.ok, true);
  await db.doc('playPurchaseIntents/intent1').set({ userId: 'alice', productId: 'paper_basic',
    serviceId: 'paper', mentorId: 'mentor1', price: 75000, currency: 'IDR', status: 'pending' });
  await db.doc('users/mentor1').set({ saldo: 0, role: 'mentor', status: 'active' });
  await db.doc('users/admin1').set({ role: 'admin' });
});
after(async () => { await db.terminate(); await deleteApp(app); });

test('concurrent duplicate callbacks create one order/receipt and never credit a balance', async () => {
  await Promise.all([fulfillPurchase(db, request), fulfillPurchase(db, request)]);
  assert.equal((await db.collection('orders').get()).size, 1);
  assert.equal((await db.collection('playPurchases').get()).size, 1);
  assert.equal((await db.doc('users/mentor1').get()).data().saldo, 0);
  assert.equal((await db.doc('users/mentor1').get()).data().playPending, 63750);
  assert.equal((await db.doc('orders/intent1').get()).data().paymentStatus, 'paid');
});
test('pending, stolen and mismatched tokens leave no partial order', async () => {
  for (const patch of [{ purchaseState: 2 }, { obfuscatedExternalAccountId: digest('bob') }, { quantity: 2 }]) {
    await assert.rejects(() => fulfillPurchase(db, { ...request, purchase: { ...purchase, ...patch } }));
  }
  assert.equal((await db.collection('orders').get()).size, 0);
  assert.equal((await db.collection('playPurchases').get()).size, 0);
});
test('questionnaire and paid order are delivered atomically and replayed once', async () => {
  await db.doc('playPurchaseIntents/intent1').update({ serviceId: 'kuesioner', questionnaire: { link: 'https://example.com/form' } });
  await fulfillPurchase(db, request);
  await fulfillPurchase(db, request);
  assert.equal((await db.doc('kuesioners/intent1').get()).data().orderId, 'intent1');
  assert.equal((await db.collection('kuesioners').get()).size, 1);
});
test('a revoked token cannot reactivate its order on retry', async () => {
  await fulfillPurchase(db, request);
  await db.doc(`playPurchases/${digest(request.purchaseToken)}`).update({ revoked: true });
  await assert.rejects(() => fulfillPurchase(db, request));
  assert.equal((await db.collection('orders').get()).size, 1);
});
test('one token cannot pay two intents even when both belong to the same user', async () => {
  await fulfillPurchase(db, request);
  await db.doc('playPurchaseIntents/intent2').set({ ...(await db.doc('playPurchaseIntents/intent1').get()).data(), status: 'pending' });
  await assert.rejects(() => fulfillPurchase(db, { ...request, purchase: { ...purchase, obfuscatedExternalProfileId: 'intent2' } }));
  assert.equal((await db.doc('orders/intent2').get()).exists, false);
});

test('only admin can advance paid order; completed service credits 85% once', async () => {
  await fulfillPurchase(db, request);
  await assert.rejects(() => changePlayOrderStatus(db, 'alice', 'intent1', 'progress'));
  await changePlayOrderStatus(db, 'admin1', 'intent1', 'progress');
  assert.equal((await db.doc('users/mentor1').get()).data().playAvailable, undefined);
  await Promise.all([changePlayOrderStatus(db, 'admin1', 'intent1', 'completed'), changePlayOrderStatus(db, 'admin1', 'intent1', 'completed')]);
  const user = (await db.doc('users/mentor1').get()).data();
  assert.equal(user.playAvailable, 63750);
  assert.equal(user.playPending, 0);
});

const withdrawal = { requestId: 'withdrawal_test_0001', nominal: 40000, namaRekening: 'Mentor', nomorRekening: '0123456789' };

test('concurrent withdrawal requests cannot overspend and retry cannot reserve twice', async () => {
  await db.doc('users/mentor1').update({ playAvailable: 63750 });
  const outcomes = await Promise.allSettled([
    reserveWithdrawal(db, 'mentor1', withdrawal),
    reserveWithdrawal(db, 'mentor1', { ...withdrawal, requestId: 'withdrawal_test_0002' }),
  ]);
  assert.equal(outcomes.filter(item => item.status === 'fulfilled').length, 1);
  const docs = await db.collection('withdraws').get();
  await reserveWithdrawal(db, 'mentor1', { ...withdrawal, requestId: docs.docs[0].id });
  const user = (await db.doc('users/mentor1').get()).data();
  assert.equal(user.playAvailable, 23750);
  assert.equal(user.playPayoutReserved, 40000);
});

test('rejection releases reserved funds once; completed transfer requires reference', async () => {
  await db.doc('users/mentor1').update({ playAvailable: 63750 });
  await reserveWithdrawal(db, 'mentor1', withdrawal);
  await changeWithdrawalStatus(db, 'admin1', withdrawal.requestId, 'rejected');
  await changeWithdrawalStatus(db, 'admin1', withdrawal.requestId, 'rejected');
  assert.equal((await db.doc('users/mentor1').get()).data().playAvailable, 63750);
  const another = { ...withdrawal, requestId: 'withdrawal_test_0002' };
  await reserveWithdrawal(db, 'mentor1', another);
  await changeWithdrawalStatus(db, 'admin1', another.requestId, 'approved');
  assert.equal((await db.doc('users/mentor1').get()).data().playPayoutReserved, 40000);
  await assert.rejects(() => changeWithdrawalStatus(db, 'admin1', another.requestId, 'completed'));
  await changeWithdrawalStatus(db, 'admin1', another.requestId, 'completed', 'bank-reference-test');
  await changeWithdrawalStatus(db, 'admin1', another.requestId, 'completed', 'bank-reference-test');
  const user = (await db.doc('users/mentor1').get()).data();
  assert.equal(user.playPayoutReserved, 0);
  assert.equal(user.playAvailable, 23750);
});

test('refund before completion removes pending amount and blocks service activation', async () => {
  await fulfillPurchase(db, request);
  await revokePlayPurchase(db, digest(request.purchaseToken), request.productId);
  await revokePlayPurchase(db, digest(request.purchaseToken), request.productId);
  assert.equal((await db.doc('users/mentor1').get()).data().playPending, 0);
  await assert.rejects(() => changePlayOrderStatus(db, 'admin1', 'intent1', 'progress'));
});

test('refund after reservation puts payout on hold and records uncovered recovery', async () => {
  await fulfillPurchase(db, request);
  await changePlayOrderStatus(db, 'admin1', 'intent1', 'progress');
  await changePlayOrderStatus(db, 'admin1', 'intent1', 'completed');
  await reserveWithdrawal(db, 'mentor1', withdrawal);
  await changeWithdrawalStatus(db, 'admin1', withdrawal.requestId, 'approved');
  await revokePlayPurchase(db, digest(request.purchaseToken), request.productId);
  const user = (await db.doc('users/mentor1').get()).data();
  assert.equal(user.playAvailable, 0);
  assert.equal(user.playDebt, 40000);
  assert.equal(user.playPayoutHold, true);
  await assert.rejects(() => changeWithdrawalStatus(db, 'admin1', withdrawal.requestId, 'completed', 'should-not-transfer'));
});

test('withdrawal validation enforces Rp20k minimum and caller identity', async () => {
  await db.doc('users/mentor1').update({ playAvailable: 100000 });
  await assert.rejects(() => reserveWithdrawal(db, 'mentor1', { ...withdrawal, nominal: 19999 }));
  await assert.rejects(() => reserveWithdrawal(db, 'alice', withdrawal));
  await reserveWithdrawal(db, 'mentor1', { ...withdrawal, nominal: 20000 });
});

test('checkout quote creates no intent; purchase takes package price only from backend catalog', async () => {
  await db.doc('playPurchaseIntents/intent1').delete();
  await db.doc('playBillingCatalog/mentoring_basic').set({ enabled: true, productId: 'cermatify_mentoring_basic', price: 75000 });
  await db.doc('layanan/paper').set({ type: 'paperlink', harga: 10000 });
  await db.doc('users/mentor1').update({ verificationStatus: 'verified', layananIds: ['paper'] });
  const input = { auth: { uid: 'alice', token: { firebase: { sign_in_provider: 'password' } } },
    data: { serviceId: 'paper', mentorId: 'mentor1', packageId: 'basic', price: 1 } };
  const quote = await preparePlayPurchase.run({ ...input, data: { ...input.data, quoteOnly: true } });
  assert.equal(quote.productId, 'cermatify_mentoring_basic');
  assert.equal((await db.collection('playPurchaseIntents').get()).size, 0);
  const result = await preparePlayPurchase.run(input);
  const saved = (await db.doc(`playPurchaseIntents/${result.intentId}`).get()).data();
  assert.equal(saved.price, 75000);
  assert.equal(saved.packageId, 'basic');
  assert.equal(result.accountId, digest('alice'));
});

test('checkout refuses anonymous callers, inactive catalog, self-purchase and rate limit', async () => {
  const data = { serviceId: 'paper', mentorId: 'mentor1' };
  await assert.rejects(() => preparePlayPurchase.run({ data }));
  await assert.rejects(() => preparePlayPurchase.run({ auth: { uid: 'guest', token: { firebase: { sign_in_provider: 'anonymous' } } }, data }));
  const input = { auth: { uid: 'alice', token: {} }, data };
  await assert.rejects(() => preparePlayPurchase.run(input));
  await db.doc('playBillingCatalog/mentoring_basic').set({ enabled: true, productId: 'cermatify_mentoring_basic', price: 75000 });
  await db.doc('layanan/paper').set({ type: 'paperlink' });
  await db.doc('users/mentor1').update({ verificationStatus: 'verified', layananIds: ['paper'] });
  await assert.rejects(() => preparePlayPurchase.run({ auth: { uid: 'mentor1', token: {} }, data }));
  await db.doc('playPurchaseLimits/alice').set({ minute: Math.floor(Date.now() / 60000), minuteCount: 20,
    day: Math.floor(Date.now() / 86400000), dayCount: 100 });
  await assert.rejects(() => preparePlayPurchase.run(input));
});
