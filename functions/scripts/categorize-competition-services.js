import { mkdir, writeFile } from 'node:fs/promises';
import { pathToFileURL } from 'node:url';
import { resolve } from 'node:path';
import { isDeepStrictEqual } from 'node:util';
import { GoogleAuth } from 'google-auth-library';
import { planCompetitionCategorization } from '../competition-categories.js';

const args = process.argv.slice(2);
const value = (name) => args.find((arg) => arg.startsWith(`${name}=`))?.slice(name.length + 1);
const projectId = value('--project');
const apply = args.includes('--apply');
const flags = ['--project=', '--confirm-project=', '--firebase-cli-auth=', '--apply'];
if (args.some((arg) => !/^--(?:project=.+|confirm-project=.+|firebase-cli-auth=.+|apply)$/.test(arg)) ||
    flags.some((flag) => args.filter((arg) => arg.startsWith(flag)).length > 1) ||
    !projectId || !/^[a-z][a-z0-9-]{4,62}$/.test(projectId) ||
    (apply && value('--confirm-project') !== projectId) ||
    (process.env.FIRESTORE_EMULATOR_HOST && !projectId.startsWith('demo-'))) {
  console.error('Usage: node functions/scripts/categorize-competition-services.js --project=PROJECT [--apply --confirm-project=PROJECT] [--firebase-cli-auth=PATH_TO_CLI_AUTH_MODULE]');
  process.exit(1);
}

try {
  const emulator = process.env.FIRESTORE_EMULATOR_HOST;
  let token = emulator ? 'owner' : undefined;
  if (!emulator) {
    const cliAuthPath = value('--firebase-cli-auth');
    if (cliAuthPath) {
      const module = await import(pathToFileURL(resolve(cliAuthPath)).href);
      const auth = module.default ?? module;
      const account = auth.getGlobalDefaultAccount();
      if (!account) throw new Error('authentication-required');
      token = (await auth.getAccessToken(account.tokens.refresh_token, ['https://www.googleapis.com/auth/cloud-platform'])).access_token;
    } else {
      token = await new GoogleAuth({ scopes: ['https://www.googleapis.com/auth/datastore'] }).getAccessToken();
    }
    if (!token) throw new Error('authentication-required');
  }
  const root = `projects/${projectId}/databases/(default)/documents`;
  const origin = emulator ? `http://${emulator}` : 'https://firestore.googleapis.com';
  const request = async (url, body) => {
    const response = await fetch(url, {
      method: body ? 'POST' : 'GET',
      headers: { ...(token ? { Authorization: `Bearer ${token}` } : {}), 'Content-Type': 'application/json' },
      ...(body ? { body: JSON.stringify(body) } : {}),
      signal: AbortSignal.timeout(30000),
    });
    if (!response.ok) throw new Error(`firestore-${response.status}`);
    return response.json();
  };
  const list = async (collection) => {
    const documents = [];
    let cursor;
    do {
      const url = new URL(`${origin}/v1/${root}/${collection}`);
      url.searchParams.set('pageSize', '200');
      if (cursor) url.searchParams.set('pageToken', cursor);
      const page = await request(url);
      documents.push(...(page.documents ?? []));
      cursor = page.nextPageToken;
    } while (cursor);
    return documents;
  };
  const read = async () => {
    const [services, categories] = await Promise.all([list('layanan'), list('competitionCategories')]);
    return { projectId, readAt: new Date().toISOString(), services, categories };
  };
  const before = await read();
  const plan = planCompetitionCategorization(before);
  const directory = resolve('build/competition-catalog');
  await mkdir(directory, { recursive: true });
  const snapshot = `${directory}/${projectId}-${Date.now()}-${apply ? 'apply' : 'dry-run'}.json`;
  // Mandatory catalog-only backup before any write, containing no credentials.
  await writeFile(snapshot, JSON.stringify({ ...before, plan }, null, 2), { flag: 'wx' });
  if (plan.writes.length > 450) throw new Error('plan-too-large');
  if (apply && plan.writes.length) {
    // One atomic commit with per-document preconditions; stale plans abort.
    await request(`${origin}/v1/${root}:commit`, { writes: plan.writes });
    const after = await read();
    for (const original of before.services) {
      const current = after.services.find((doc) => doc.name === original.name);
      const assignment = plan.assignments.find((item) => original.name.endsWith(`/layanan/${item.id}`));
      const expected = structuredClone(original.fields);
      if (assignment) expected.competitionCategoryId = { stringValue: assignment.categoryId };
      if (!current || !isDeepStrictEqual(current.fields, expected)) throw new Error('post-write-verification-required');
    }
    for (const assignment of plan.assignments) {
      const category = after.categories.find((doc) => doc.name === `${root}/competitionCategories/${assignment.categoryId}`);
      if (category?.fields?.active?.booleanValue !== true || category.fields?.name?.stringValue !== assignment.categoryName) throw new Error('post-write-verification-required');
    }
    await writeFile(snapshot.replace(/\.json$/, '-after.json'), JSON.stringify(after, null, 2), { flag: 'wx' });
  }
  console.log(JSON.stringify({ projectId, mode: apply ? 'apply' : 'dry-run', snapshot,
    categoryWrites: plan.writes.length - plan.assignments.length,
    servicesLinked: plan.assignments.length, assignments: plan.assignments, skipped: plan.skipped,
    verification: apply ? 'passed-or-no-op' : 'not-applied' }, null, 2));
} catch (error) {
  const known = /^(authentication-required|firestore-\d+|invalid-project|invalid-snapshot|category-id-conflict|plan-too-large|post-write-verification-required)$/;
  console.error(`Categorization stopped: ${known.test(error?.message) ? error.message : 'credentials, connectivity or local snapshot unavailable'}. Inspect the catalog snapshot and rerun a dry-run before retrying.`);
  process.exitCode = 1;
}
