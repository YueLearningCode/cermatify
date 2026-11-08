import { applicationDefault, initializeApp } from 'firebase-admin/app';
import { getFirestore, FieldPath } from 'firebase-admin/firestore';
import { pathToFileURL } from 'node:url';
import { resolve } from 'node:path';
import { syncPublicProfile } from '../public-profile.js';

const args = process.argv.slice(2);
const value = (name) => args.find((arg) => arg.startsWith(`${name}=`))?.slice(name.length + 1);
const projectId = value('--project');
const apply = args.includes('--apply');
const unknownOrRepeated = args.some((arg) => !/^--(?:project=.+|confirm-project=.+|firebase-cli-auth=.+|apply)$/.test(arg)) ||
  ['--project=', '--confirm-project=', '--firebase-cli-auth=', '--apply'].some((prefix) => args.filter((arg) => arg.startsWith(prefix)).length > 1);
if (unknownOrRepeated || !projectId || !/^[a-z][a-z0-9-]{4,62}$/.test(projectId) ||
    (apply && value('--confirm-project') !== projectId) ||
    (process.env.FIRESTORE_EMULATOR_HOST && projectId !== 'demo-cermatify')) {
  console.error('Usage: node scripts/migrate-public-profiles.js --project=PROJECT [--apply --confirm-project=PROJECT] [--firebase-cli-auth=PATH_TO_CLI_AUTH_MODULE]');
  process.exit(1);
}
// Never embed or print keys, tokens or profile data. Persist counts only.
let db;
const counts = { created: 0, changed: 0, unchanged: 0, missing: 0 };
try {
  const cliAuthPath = value('--firebase-cli-auth');
  let credential;
  if (process.env.FIRESTORE_EMULATOR_HOST) {
    initializeApp({ projectId });
  } else if (cliAuthPath) {
    const module = await import(pathToFileURL(resolve(cliAuthPath)).href);
    const auth = module.default ?? module;
    const account = auth.getGlobalDefaultAccount();
    if (!account) throw new Error('authentication-required');
    credential = { getAccessToken: async () => {
      const tokens = await auth.getAccessToken(account.tokens.refresh_token, ['https://www.googleapis.com/auth/cloud-platform']);
      if (!tokens.access_token) throw new Error('authentication-required');
      return { access_token: tokens.access_token, expires_in: 3600 };
    } };
    initializeApp({ projectId, credential });
  } else {
    initializeApp({ projectId, credential: applicationDefault() });
  }
  db = getFirestore();
  let cursor;
  while (true) {
    let query = db.collection('users').orderBy(FieldPath.documentId()).limit(200);
    if (cursor) query = query.startAfter(cursor);
      const page = await query.select().get();
    if (page.empty) break;
    for (const user of page.docs) {
      counts[await syncPublicProfile(db, user.id, { apply })]++;
    }
    cursor = page.docs.at(-1);
  }
  console.log(JSON.stringify({ projectId, mode: apply ? 'apply' : 'dry-run', counts }));
} catch {
  console.error('Migration stopped. Check credentials, permissions and connectivity. Rerunning is safe; private profiles were not modified.');
  process.exitCode = 1;
} finally {
  await db?.terminate();
}
