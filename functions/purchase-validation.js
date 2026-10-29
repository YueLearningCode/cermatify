import { createHash } from 'node:crypto';

export const PACKAGE_NAME = 'com.cermatify.app';
export const digest = (value) => createHash('sha256').update(value).digest('hex');

export function validatePurchase(purchase, { uid, intent, productId }) {
  if (purchase.purchaseState !== 0) throw new Error('purchase-not-paid');
  if (purchase.obfuscatedExternalAccountId !== digest(uid)) throw new Error('account-mismatch');
  if (purchase.obfuscatedExternalProfileId !== intent.id) throw new Error('intent-mismatch');
  if (intent.userId !== uid || intent.productId !== productId) throw new Error('selection-mismatch');
  if ((purchase.quantity ?? 1) !== 1) throw new Error('unsupported-quantity');
  if (intent.status !== 'pending' && intent.status !== 'paid') throw new Error('invalid-intent-state');
}

export function validateSelection(input) {
  if (!input || typeof input.serviceId !== 'string' ||
      !/^[A-Za-z0-9_-]{1,128}$/.test(input.serviceId)) throw new Error('invalid-service');
  if (input.serviceId !== 'kuesioner') {
    if (typeof input.mentorId !== 'string' || !/^[A-Za-z0-9_-]{1,128}$/.test(input.mentorId)) {
      throw new Error('invalid-mentor');
    }
    const packageId = input.packageId ?? 'basic';
    if (!['basic', 'intensive'].includes(packageId)) throw new Error('invalid-package');
    return { serviceId: input.serviceId, mentorId: input.mentorId, packageId };
  }
  const value = input.questionnaire;
  if (!value || typeof value.link !== 'string' || value.link.length > 2048) throw new Error('invalid-link');
  const link = new URL(value.link);
  if (link.protocol !== 'https:' || link.username || link.password) throw new Error('invalid-link');
  const questionnaire = { link: link.href };
  for (const key of ['rentangUsia', 'jenisKelamin', 'tingkatPenghasilan', 'pendidikanTerakhir']) {
    if (typeof value[key] !== 'string' || value[key].length > 200) throw new Error('invalid-criteria');
    // No demographic targeting for the UI's initial "all" option.
    questionnaire[key] = /^(semua|pilih)/i.test(value[key]) ? null : value[key];
  }
  return { serviceId: input.serviceId, mentorId: 'system', questionnaire };
}
