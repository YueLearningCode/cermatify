import { spawnSync } from 'node:child_process';
import test from 'node:test';
import assert from 'node:assert/strict';
import { publicProfileSourceFields } from '../public-profile.js';
import { firebaseCliGoogleAuth } from '../scripts/firebase-cli-auth.js';

test('CLI OAuth adapter uses token expiry and refreshes through the existing session', async () => {
  const expiry = Date.now() + 3600000;
  let calls = 0;
  const auth = firebaseCliGoogleAuth({
    getGlobalDefaultAccount: () => ({ tokens: { refresh_token: 'test-refresh' } }),
    getAccessToken: async (refresh, scopes) => {
      assert.equal(refresh, 'test-refresh');
      assert.deepEqual(scopes, ['https://www.googleapis.com/auth/cloud-platform']);
      calls++;
      return { access_token: 'test-access', expires_at: expiry };
    },
  }, 'demo-cermatify');
  const client = await auth.getClient();
  assert.equal((await client.getRequestHeaders()).get('authorization'), 'Bearer test-access');
  assert.equal(client.credentials.expiry_date, expiry);
  await client.getRequestHeaders();
  assert.equal(calls, 1);
});

test('CLI OAuth adapter rejects missing sessions and expired tokens', async () => {
  assert.throws(() => firebaseCliGoogleAuth({ getGlobalDefaultAccount: () => null }, 'demo-cermatify'), /authentication-required/);
  const auth = firebaseCliGoogleAuth({
    getGlobalDefaultAccount: () => ({ tokens: { refresh_token: 'test-refresh' } }),
    getAccessToken: async () => ({ access_token: 'test-access', expires_at: Date.now() - 1 }),
  }, 'demo-cermatify');
  await assert.rejects(() => auth.getRequestHeaders(), /authentication-required/);
});

test('profile migration read mask excludes contacts, finances and consent metadata', () => {
  for (const field of ['email', 'noTelp', 'saldo', 'playAvailable', 'nomorRekening', 'namaRekening', 'adultConfirmed', 'termsVersion', 'termsAcceptedAt']) {
    assert.equal(publicProfileSourceFields.includes(field), false, field);
  }
  assert.ok(publicProfileSourceFields.includes('nama'));
  assert.ok(publicProfileSourceFields.includes('role'));
  assert.ok(publicProfileSourceFields.includes('verificationStatus'));
});

test('migration CLI rejects ambiguous targets and apply without matching project before using credentials', () => {
  for (const args of [[], ['--project=cermatify', '--apply'],
    ['--project=cermatify', '--apply', '--confirm-project=other-project'],
    ['--project=cermatify', '--project=other-project'],
    ['--project=cermatify', '--dry-run', '--apply', '--confirm-project=cermatify']]) {
    const result = spawnSync(process.execPath, ['scripts/migrate-public-profiles.js', ...args], { encoding: 'utf8' });
    assert.equal(result.status, 1);
    assert.match(result.stderr, /Usage:/);
  }
});
