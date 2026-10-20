// Read-only numerical audit of the generated browser adapter against its DTO.
import { readFile, writeFile } from 'node:fs/promises';
import path from 'node:path';
import { pathToFileURL } from 'node:url';
import assert from 'node:assert/strict';

const root = path.resolve(process.argv[2] ?? '');
if (!process.argv[2]) throw new Error('Usage: node inspect.mjs generated-directory');
const manifest = JSON.parse(await readFile(path.join(root, 'comparison-manifest.json')));
const model = await import(pathToFileURL(path.join(root, 'night-model.js')).href);
const canonical = (await import(pathToFileURL(path.join(root, 'comparison-fixture.js')).href)).default;
const report = {
  fixtureHash: manifest.fixture.sha256,
  sourceRevision: manifest.source.find(x => x.path === 'night-model.js').sha256,
  renderInput: 'Native exported summaries and slots; original browser aggregation audited separately below.',
  results: [],
};
const roots = (await import(pathToFileURL(path.join(root, 'comparison-root-data.js')).href)).default;
const planModel = await import(pathToFileURL(path.join(root, 'plan-model.js')).href);
const library = await import(pathToFileURL(path.join(root, 'library.js')).href);
const logbook = await import(pathToFileURL(path.join(root, 'logbook.js')).href);
const settings = await import(pathToFileURL(path.join(root, 'settings.js')).href);
assert.ok(planModel.validPlan(roots.plan), 'Canonical plan must be accepted by the original browser validator');
assert.ok(library.validateLibraryPayload({ kind: 'culmina-library-preview', version: 1, ...roots.library }));
assert.ok(logbook.validateLogbookPayload({ kind: 'culmina-logbook-preview', version: 1, entries: roots.entries }));
assert.ok(settings.validateSettingsPayload({ kind: 'culmina-settings-preview', version: 1, settings: roots.settings }));
const renderedEstimate = planModel.estimate(planModel.defaultPlan());
assert.equal(renderedEstimate.integration * 1000, canonical.plan.fit.integrationMs);
assert.equal(renderedEstimate.needed * 1000, canonical.plan.fit.windowLoadMs);
assert.equal(renderedEstimate.total * 1000, canonical.plan.fit.sessionBudgetMs);
assert.equal(renderedEstimate.bytes, canonical.plan.fit.storageMB == null ? null : canonical.plan.fit.storageMB * 1e6);
assert.equal(roots.entries.length, canonical.logbook.count);
assert.equal(roots.targets.length, canonical.library.counts.targets);
report.rootValidation = {
  originalValidatorsAcceptAll: true,
  initialPlanEstimateMatchesNative: true,
  unknownStoragePreserved: renderedEstimate.bytes === null,
  counts: canonical.library.counts,
  logbookEntries: roots.entries.length,
  settings: roots.settings,
  originalBrowserEstimate: planModel.sourceEstimate(roots.plan),
};
for (const date of Object.keys(canonical.nights)) {
  const night = model.fixtureNight(date);
  const render = model.weatherForNight(night);
  const sourceNight = { ...night, dark: night.weatherDark ?? night.dark };
  const source = model.sourceWeatherForNight(sourceNight, 'ready', canonical.nowUtcMs);
  const native = night.nativeSummary;
  const sourceSlots = model.sourceWeatherSlots(sourceNight, source);
  const renderSlots = model.weatherSlots(night, render);
  const differences = [];
  for (const field of ['sampleCount', 'coveredSamples', 'cloudSamples', 'cloudMin', 'cloudMax',
    'tempMin', 'tempMax', 'dewMin', 'dewKnownSamples', 'dewRiskSamples']) {
    if (native?.[field] !== source[field]) differences.push({
      field, native: native?.[field] ?? null, originalBrowserAggregate: source[field] ?? null,
    });
  }
  const sourceByTime = new Map(sourceSlots.map(x => [x.start, x]));
  let slotMembershipDifferences = 0, precedingFractionDifferences = 0;
  for (const slot of renderSlots) {
    const other = sourceByTime.get(slot.start);
    if (!other || other.instant !== slot.instant) slotMembershipDifferences++;
    else if (other.precedingMinutes !== slot.precedingMinutes) precedingFractionDifferences++;
  }
  const nativeSlotsIdentical = JSON.stringify(native?.slots) === JSON.stringify(renderSlots);
  if (!nativeSlotsIdentical) throw new Error(`Render adapter corrupted native slots: ${date}`);
  report.results.push({
    date, nativeSlotsIdentical, sourceSlotCount: sourceSlots.length, nativeSlotCount: renderSlots.length,
    slotMembershipDifferences, precedingFractionDifferences, aggregateDifferences: differences,
    skySegments: night.skySegments.length,
    darkGridVersusContinuous: JSON.stringify(night.dark) !== JSON.stringify(night.weatherDark),
    moonContinuousVersusGrid: JSON.stringify(night.moonUp) !== JSON.stringify(night.gridMoonUp),
  });
}
const output = path.join(root, 'comparison-numeric-audit.json');
await writeFile(output, JSON.stringify(report, null, 2));
console.log(JSON.stringify({
  output, nights: report.results.length,
  nativeSlotsIdentical: report.results.every(x => x.nativeSlotsIdentical),
  nightsWithAggregateDifferences: report.results.filter(x => x.aggregateDifferences.length).length,
  nightsWithPrecedingFractionDifferences: report.results.filter(x => x.precedingFractionDifferences).length,
}, null, 2));
