import test from 'node:test';
import assert from 'node:assert/strict';
import { spawnSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';
import { initializeApp, deleteApp } from 'firebase-admin/app';
import { getFirestore } from 'firebase-admin/firestore';
import { planCompetitionCategorization } from '../competition-categories.js';

test('catalog dry-run, atomic apply, idempotency and stale-plan rejection use emulator only', async () => {
  assert.ok(process.env.FIRESTORE_EMULATOR_HOST, 'Firestore emulator required');
  const projectId = 'demo-competition-categories';
  const app = initializeApp({ projectId }, 'competition-catalog-test');
  const db = getFirestore(app);
  try {
    for (const collection of ['layanan', 'competitionCategories']) {
      for (const document of (await db.collection(collection).get()).docs) await document.ref.delete();
    }
    await db.doc('layanan/poster').set({ name: 'Poster Competition', type: 'complink', harga: 20000, untouched: 'keep' });
    await db.doc('layanan/essay').set({ name: 'Essai Competition', type: 'complink', harga: 20000 });
    await db.doc('layanan/olympiad').set({ name: 'Olimpiade', type: 'complink', harga: 20000 });
    const run = (apply = false) => {
      const result = spawnSync(process.execPath, [fileURLToPath(new URL('../scripts/categorize-competition-services.js', import.meta.url)), `--project=${projectId}`,
        ...(apply ? ['--apply', `--confirm-project=${projectId}`] : [])], { encoding: 'utf8', timeout: 30000 });
      assert.equal(result.status, 0, result.stderr);
      return JSON.parse(result.stdout);
    };
    assert.equal(run().servicesLinked, 2);
    assert.equal((await db.collection('competitionCategories').get()).size, 0);
    assert.equal((await db.doc('layanan/poster').get()).data().competitionCategoryId, undefined);
    assert.equal(run(true).servicesLinked, 2);
    assert.deepEqual((await db.doc('layanan/poster').get()).data(), {
      name: 'Poster Competition', type: 'complink', harga: 20000, untouched: 'keep', competitionCategoryId: 'desain-media-kreatif',
    });
    assert.deepEqual((await db.doc('layanan/olympiad').get()).data(), { name: 'Olimpiade', type: 'complink', harga: 20000 });
    assert.equal(run(true).servicesLinked, 0);
    assert.equal((await db.collection('competitionCategories').get()).size, 2);

    await db.doc('layanan/business').set({ name: 'Business Plan Competition', type: 'complink', harga: 20000 });
    const root = `projects/${projectId}/databases/(default)/documents`;
    const origin = `http://${process.env.FIRESTORE_EMULATOR_HOST}`;
    const before = await (await fetch(`${origin}/v1/${root}/layanan`, { headers: { Authorization: 'Bearer owner' } })).json();
    const plan = planCompetitionCategorization({ projectId, services: before.documents, categories: [] });
    await db.doc('layanan/business').update({ harga: 25000 });
    const response = await fetch(`${origin}/v1/${root}:commit`, {
      method: 'POST', headers: { Authorization: 'Bearer owner', 'Content-Type': 'application/json' }, body: JSON.stringify({ writes: plan.writes }),
    });
    assert.equal(response.ok, false);
    assert.equal((await db.doc('competitionCategories/bisnis-kewirausahaan').get()).exists, false);
    assert.deepEqual((await db.doc('layanan/business').get()).data(), { name: 'Business Plan Competition', type: 'complink', harga: 25000 });
  } finally {
    await db.terminate();
    await deleteApp(app);
  }
});
