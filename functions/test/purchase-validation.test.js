import test from 'node:test';
import assert from 'node:assert/strict';
import { digest, validatePurchase, validateSelection } from '../purchase-validation.js';

const intent = { id: 'intent1', userId: 'alice', productId: 'paper_basic', status: 'pending' };
const valid = { purchaseState: 0, quantity: 1,
  obfuscatedExternalAccountId: digest('alice'), obfuscatedExternalProfileId: 'intent1' };
const context = { uid: 'alice', intent, productId: 'paper_basic' };

test('paid purchase bound to account, product and order is accepted', () => {
  assert.doesNotThrow(() => validatePurchase(valid, context));
});
for (const [name, patch] of Object.entries({
  pending: { purchaseState: 2 }, cancelled: { purchaseState: 1 },
  stolen: { obfuscatedExternalAccountId: digest('bob') },
  otherOrder: { obfuscatedExternalProfileId: 'intent2' },
  multiQuantity: { quantity: 2 }, missingAccount: { obfuscatedExternalAccountId: undefined },
})) {
  test(`rejects ${name} purchase`, () => assert.throws(() => validatePurchase({ ...valid, ...patch }, context)));
}
test('rejects another product and owner even with a paid token', () => {
  assert.throws(() => validatePurchase(valid, { ...context, productId: 'other' }));
  assert.throws(() => validatePurchase(valid, { ...context, intent: { ...intent, userId: 'bob' } }));
});
test('rejects cancelled intent but accepts paid intent for idempotent retry', () => {
  assert.throws(() => validatePurchase(valid, { ...context, intent: { ...intent, status: 'cancelled' } }));
  assert.doesNotThrow(() => validatePurchase(valid, { ...context, intent: { ...intent, status: 'paid' } }));
});
test('selection excludes client price and arbitrary payload fields', () => {
  assert.deepEqual(validateSelection({ serviceId: 'paper', mentorId: 'mentor1', price: 1, admin: true }),
    { serviceId: 'paper', mentorId: 'mentor1', packageId: 'basic' });
});
test('questionnaire rejects unsafe links and normalizes all criteria', () => {
  const input = { serviceId: 'kuesioner', questionnaire: {
    link: 'https://example.com/form', rentangUsia: 'Semua usia', jenisKelamin: 'Semua',
    tingkatPenghasilan: 'Pilih penghasilan', pendidikanTerakhir: 'S1',
  } };
  assert.equal(validateSelection(input).questionnaire.rentangUsia, null);
  for (const link of ['http://example.com', 'javascript:alert(1)', 'https://user:pass@example.com']) {
    assert.throws(() => validateSelection({ ...input, questionnaire: { ...input.questionnaire, link } }));
  }
});
