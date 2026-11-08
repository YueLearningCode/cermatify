import test from 'node:test';
import assert from 'node:assert/strict';
import { spawnSync } from 'node:child_process';
import { competitionCategoryForService, planCompetitionCategorization } from '../competition-categories.js';

const projectId = 'demo-competition-categories';
const root = `projects/${projectId}/databases/(default)/documents`;
const service = (id, name, extra = {}) => ({ name: `${root}/layanan/${id}`, updateTime: '2026-11-07T10:00:00.000Z',
  fields: { name: { stringValue: name }, type: { stringValue: 'complink' }, harga: { integerValue: '20000' }, ...extra } });

test('the actual twelve competition names map to four understandable groups', () => {
  const expected = [
    ['UI/UX Design', 'desain-media-kreatif'], ['Poster', 'desain-media-kreatif'], ['Desain Grafis', 'desain-media-kreatif'],
    ['Infographics', 'desain-media-kreatif'], ['Videografi', 'desain-media-kreatif'],
    ['Business Case', 'bisnis-kewirausahaan'], ['Business Plan', 'bisnis-kewirausahaan'],
    ['Essai', 'karya-tulis-penelitian'], ['Paper', 'karya-tulis-penelitian'], ['LKTI', 'karya-tulis-penelitian'],
    ['Debate', 'debat-public-speaking'], ['Speech', 'debat-public-speaking'],
  ];
  for (const [name, id] of expected) assert.equal(competitionCategoryForService(`${name} Competition`)?.id, id);
  assert.equal(competitionCategoryForService('  esai   COMPETITION  ')?.id, 'karya-tulis-penelitian');
  assert.equal(competitionCategoryForService('Olimpiade'), null);
  assert.equal(competitionCategoryForService('Poster Competition Junior'), null);
});

test('plan only patches category IDs and protects every current document version', () => {
  const services = [service('poster', 'Poster Competition'), service('ux', 'UI/UX Design Competition')];
  const before = structuredClone(services);
  const plan = planCompetitionCategorization({ projectId, services, categories: [] });
  assert.deepEqual(services, before);
  assert.equal(plan.assignments.length, 2);
  assert.equal(plan.writes.length, 3); // one shared category, two service links
  for (const write of plan.writes.slice(1)) {
    assert.deepEqual(write.updateMask.fieldPaths, ['competitionCategoryId']);
    assert.deepEqual(Object.keys(write.update.fields), ['competitionCategoryId']);
    assert.equal(write.currentDocument.updateTime, services[0].updateTime);
  }
  assert.deepEqual(plan.writes[0].currentDocument, { exists: false });
});

test('existing assignments, unknown names and different service types are not overwritten', () => {
  const services = [service('linked', 'Poster Competition', { competitionCategoryId: { stringValue: 'custom' } }),
    service('unknown', 'Robotics Competition'), service('paper', 'Paper Competition', { type: { stringValue: 'paperlink' } }),
    service('invalid', 'Poster Competition', { competitionCategoryId: { integerValue: '123' } })];
  const plan = planCompetitionCategorization({ projectId, services, categories: [] });
  assert.equal(plan.writes.length, 0);
  assert.deepEqual(plan.skipped.map((item) => item.reason), ['already-assigned', 'unknown-competition', 'different-service-type', 'invalid-existing-category-field']);
});

test('existing active labels are reused and guarded against concurrent archival', () => {
  const category = { name: `${root}/competitionCategories/custom-design`, updateTime: '2026-11-07T09:00:00Z',
    fields: { name: { stringValue: 'DESAIN & MEDIA KREATIF' }, active: { booleanValue: true } } };
  const plan = planCompetitionCategorization({ projectId, services: [service('poster', 'Poster Competition')], categories: [category] });
  assert.equal(plan.assignments[0].categoryId, 'custom-design');
  assert.equal(plan.assignments[0].categoryName, 'DESAIN & MEDIA KREATIF');
  assert.deepEqual(plan.writes[0].currentDocument, { updateTime: category.updateTime });
  const collision = { ...category, name: `${root}/competitionCategories/desain-media-kreatif`, fields: { name: { stringValue: 'Other' }, active: { booleanValue: false } } };
  assert.throws(() => planCompetitionCategorization({ projectId, services: [service('poster', 'Poster Competition')], categories: [collision] }), /category-id-conflict/);
});

test('cross-project snapshots and ambiguous CLI targets fail before accessing credentials', () => {
  assert.throws(() => planCompetitionCategorization({ projectId: 'other-project', services: [service('poster', 'Poster Competition')], categories: [] }), /invalid-snapshot/);
  for (const args of [[], ['--project=cermatify', '--apply'], ['--project=cermatify', '--apply', '--confirm-project=other-project'], ['--project=cermatify', '--project=other-project']]) {
    const result = spawnSync(process.execPath, ['scripts/categorize-competition-services.js', ...args], { encoding: 'utf8' });
    assert.equal(result.status, 1);
    assert.match(result.stderr, /Usage:/);
  }
});
