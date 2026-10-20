import test from 'node:test';
import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';
import { adaptModel, adaptConditions, adaptPlanModel, adaptRootModule, validateFixture } from './prepare.mjs';
import { projectRoots } from './root_projection.mjs';

const original = await readFile(new URL('../../../design/home-lab/night-model.js', import.meta.url), 'utf8');
const conditions = await readFile(new URL('../../../design/home-lab/conditions.js', import.meta.url), 'utf8');
const start = Date.parse('2026-11-10T12:00:00Z');
const slot = { start: start + 3600000, end: start + 7200000, available: false,
  instant: true, precedingMinutes: 35, temp: null, dew: null, cloud: null };
const fixture = {
  fixtureVersion: 1, nowUtcMs: start, retrievedAtMs: start,
  selectedEveningDate: '2026-11-10', site: { name: 'Canonical site', zone: 'UTC' },
  weatherHours: [],
  nights: { '2026-11-10': {
    date: '2026-11-10', zone: 'UTC', start, end: start + 86400000,
    dark: [{ start: start + 3300000, end: start + 7500000 }],
    moonUp: [], moonFree: [], skySegments: [], twilight: [], targetWindows: [],
    nativeSummary: { sampleCount: 1, coveredSamples: 0, slots: [slot] },
  } },
};
const load = async value => {
  const adapted = adaptModel(original, value).replace(
    "import canonical from './comparison-fixture.js';",
    `const canonical=${JSON.stringify(value)};`);
  return import(`data:text/javascript;base64,${Buffer.from(adapted).toString('base64')}`);
};

test('all root adaptations refuse drift and retain presentation templates', async () => {
  for (const name of ['plan-model.js', 'library.js', 'logbook.js', 'settings.js',
    'preview-bridge.js', 'app.js', 'plan.js']) {
    const source = await readFile(new URL('../../../design/home-lab/' + name, import.meta.url), 'utf8');
    const adapt = value => name === 'plan-model.js' ? adaptPlanModel(value) : adaptRootModule(name, value);
    const adapted = adapt(source);
    assert.ok(adapted.includes("import roots from './comparison-root-data.js';"), name);
    assert.throws(() => adapt('source revision changed'), /anchor|revision/, name);
    if (name === 'app.js') assert.ok(adapted.includes('<div class="app-context">'));
    if (name === 'library.js') assert.ok(adapted.includes('library-list'));
  }
});

test('root projection retains native unknown storage and historical result identity/counts', () => {
  const snapshot = {
    takenAtUtcMs: start, preferences: { perFrameOverheadS: 5, setupMin: null,
      feasibilityMarginPercent: 15, darknessLimitDeg: -18, minAltitudeDeg: 20 },
    target: { catalogId: 'M42' }, rig: { id: 7, cameraClass: 'astroColour',
      focalLengthMm: 400, focalRatio: 5.6, pixelPitchUm: 3.76 },
    site: { name: 'Canonical site', latitudeDeg: 46, longitudeDeg: 14 },
    night: { startUtcMs: start, endUtcMs: start + 86400000 },
    blocks: [{ frameType: 'light', exposureS: 60, frameCount: 100, binning: 1,
      gainKind: 'unknown', gainValue: null }],
  };
  const value = { ...fixture, planSnapshot: snapshot,
    library: { rigs: [{ nativeId: 7, cameraClass: 'astroColour', provenance: { record: 'Native fixture' } }],
      targets: [{ id: 'M42', name: 'Great Orion Nebula', bundled: true }], sites: [] },
    settings: { planning: {} },
    plan: { fit: { state: 'fits', availableMs: 7200000, storageMB: null } },
    logbook: { manifest: { sessions: [{ id: 42, name: null, status: 'completed',
      plan_snapshot: snapshot, time_zone_id: 'UTC', evening_date: '2026-11-10',
      labels: { target: 'M42', rig: 'Native rig' }, completed_at_utc_ms: start,
      blocks: [{ id: 16, frame_type: 'light', filter_name: null, exposure_s: 60,
        frame_count: 100, binning: 1, gain_value: null, confirmed_frames: 40 }],
      results: { result_kind: 'partly', not_done_reason: null,
        environmental_notes: 'Cloud interrupted capture', processing_notes: null } }] } },
  };
  const roots = projectRoots(value);
  assert.equal(roots.fit.storageMB, null);
  assert.equal(roots.assumptions.bytesPerFrame, null);
  assert.equal(roots.assumptions.outsideSetup, 0);
  assert.equal(roots.plan.rig, '7');
  assert.equal(roots.plan.blocks[0].gain, null);
  assert.equal(roots.entries[0].id, 'example-native-42');
  assert.equal(roots.entries[0].result.counts.b16, 40);
  assert.equal(roots.entries[0].result.outcome, 'partly');
  assert.equal(roots.entries[0].plan.blocks[0].planned, 100);
  assert.equal(roots.entries[0].plan.blocks[0].sensitivity, null);
  assert.throws(() => projectRoots(fixture), /All-root comparison/);
});

test('adapter uses exact canonical intervals and independent copies', async () => {
  const model = await load(fixture);
  const night = model.fixtureNight();
  assert.deepEqual(night, fixture.nights['2026-11-10']);
  night.dark[0].start = 0;
  assert.equal(model.fixtureNight().dark[0].start, start + 3300000);
  assert.throws(() => model.fixtureNight('2026-11-11'), /not exported/);
  assert.equal(model.timeLabel(start), '12:00');
});
test('native unknown and preceding-hour mask survives the render adapter', async () => {
  const model = await load(fixture);
  const night = model.fixtureNight();
  const summary = model.weatherForNight(night, 'ready', Date.now());
  assert.equal(summary.sampleCount, 1);
  assert.equal(summary.coveredSamples, 0);
  assert.equal(summary.ageHours, 0);
  assert.equal(summary.leadDays, 0);
  assert.deepEqual(model.weatherSlots(night, summary), [slot]);
  assert.equal(typeof model.sourceWeatherForNight, 'function');
  assert.equal(typeof model.sourceWeatherSlots, 'function');
});
test('invalid DTO and changed source anchors fail explicitly', () => {
  assert.throws(() => validateFixture({}), /fixtureVersion/);
  assert.throws(() => adaptModel('changed revision', fixture), /revision/);
  const output = adaptConditions(conditions);
  assert.match(output, /site:canonical.site.name/);
  assert.match(output, /night:canonical.selectedEveningDate/);
  assert.equal((output.match(/function hourlyChart/g) ?? []).length, 1);
});
