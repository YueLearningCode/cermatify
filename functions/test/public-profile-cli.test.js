import { spawnSync } from 'node:child_process';
import test from 'node:test';
import assert from 'node:assert/strict';

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
