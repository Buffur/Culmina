// Test-only adapter. The approved design/home-lab tree is never written.
import { readFile, writeFile, mkdir, cp, readdir } from 'node:fs/promises';
import { createHash } from 'node:crypto';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { projectRoots } from './root_projection.mjs';

export const sha256 = data => createHash('sha256').update(data).digest('hex');
const here = path.dirname(fileURLToPath(import.meta.url));
const repo = path.resolve(here, '../../..');

function once(source, old, replacement) {
  if (source.split(old).length !== 2) throw new Error(`Expected one source anchor: ${old}`);
  return source.replace(old, replacement);
}
function between(source, start, end, replacement) {
  const a = source.indexOf(start), b = source.indexOf(end, a);
  if (a < 0 || b < a || source.indexOf(start, a + 1) >= 0) {
    throw new Error(`Source revision has changed around ${start}`);
  }
  return source.slice(0, a) + replacement + source.slice(b);
}

export function validateFixture(fixture) {
  if (fixture.fixtureVersion !== 1) throw new Error('Expected fixtureVersion 1');
  if (!Number.isFinite(fixture.nowUtcMs) || !fixture.site?.zone) {
    throw new Error('A fixed UTC clock and site time zone are required');
  }
  if (!fixture.nights?.[fixture.selectedEveningDate]) {
    throw new Error('selectedEveningDate must name an exported night');
  }
  if (!Array.isArray(fixture.weatherHours)) throw new Error('weatherHours must be explicit');
  if ((fixture.display?.temperature ?? 'celsius') !== 'celsius' ||
      (fixture.display?.wind ?? 'kmh') !== 'kmh') {
    throw new Error('Original browser labels require metric units; this adapter cannot claim non-metric parity');
  }
  for (const [date, night] of Object.entries(fixture.nights)) {
    if (night.date !== date || !(night.end > night.start)) throw new Error(`Invalid night ${date}`);
    for (const name of ['dark', 'moonUp', 'moonFree', 'skySegments', 'twilight', 'targetWindows']) {
      if (!Array.isArray(night[name])) throw new Error(`${date}.${name} must be explicit`);
    }
  }
}

/** Keeps source helpers/formatters, replacing only illustrative data providers. */
export function adaptModel(original, fixture) {
  validateFixture(fixture);
  let source = `import canonical from './comparison-fixture.js';\n${original}`;
  source = between(source, "export const zone=", 'export const dayMs=',
    `export const zone=canonical.site.zone;\nexport const fixtureNow=canonical.nowUtcMs;\nexport const retrievedAt=canonical.retrievedAtMs;\n`);
  source = between(source, 'export const fixtureDates=', 'const minute=',
    `export const fixtureDates=Object.keys(canonical.nights).sort();\n`);
  source = between(source, 'export function fixtureNight(', 'const inside=',
    `export function fixtureNight(date=canonical.selectedEveningDate){\n` +
    ` if(!canonical.nights[date])throw new Error('Night not exported: '+date);\n` +
    ` return structuredClone(canonical.nights[date]);\n}\n`);
  source = between(source, 'export function weatherHours(', 'export function weatherForNight(',
    `export function weatherHours(){return structuredClone(canonical.weatherHours);}\n`);
  source = once(source, 'export function weatherForNight(', 'export function sourceWeatherForNight(');
  source = once(source, 'export function weatherSlots(', 'export function sourceWeatherSlots(');
  source = source.replaceAll('now=Date.now()', 'now=fixtureNow');
  source = once(source,
    "const exampleAgeHours=scenario==='stale'?18:scenario==='offline'?4:1,snapshotRetrievedAt=fixtureNow-exampleAgeHours*3600000;",
    'const snapshotRetrievedAt=retrievedAt;');
  source = once(source, "Date.parse('2026-10-19T12:00Z')",
    "Date.parse(new Intl.DateTimeFormat('en-CA',{timeZone:zone,year:'numeric',month:'2-digit',day:'2-digit'}).format(retrievedAt)+'T12:00Z')");
  source += `
// Native DTOs are the comparison input. Source aggregators remain exported
// above for an independent difference report; they are not production truth.
export function weatherForNight(night,scenario='ready'){
 const weatherNight={...night,dark:night.weatherDark??night.dark};
 const source=sourceWeatherForNight(weatherNight,scenario,fixtureNow);
 const native=night.nativeSummary;
 return {...source,...native,hours:weatherHours(),
   ageHours:Math.max(0,(fixtureNow-retrievedAt)/3600000),retrievedAt};
}
export function weatherSlots(night,summary){
 if(Array.isArray(night.nativeSummary?.slots))return structuredClone(night.nativeSummary.slots);
 return sourceWeatherSlots({...night,dark:night.weatherDark??night.dark},summary);
}
`;
  return source;
}

export function adaptConditions(original) {
  let source = `import canonical from './comparison-fixture.js';\n${original}`;
  source = once(source,
    'let active=checkpoint||{plan:saved||defaultPlan(),savedSnapshot:JSON.stringify(saved||defaultPlan()),hasSaved:true};',
    `let active={plan:{...defaultPlan(),site:canonical.site.name,night:canonical.selectedEveningDate},hasSaved:true};active.savedSnapshot=JSON.stringify(active.plan);`);
  // Content substitutions only: the original HTML templates and CSS remain.
  source = once(source, 'Example nights: 19 Oct–1 Nov. Tap to view; your plan stays unchanged.',
    'Canonical native fixture nights. Tap to view; your plan stays unchanged.');
  return source;
}

export function adaptPlanModel(original) {
  let source = `import canonical from './comparison-fixture.js';\nimport roots from './comparison-root-data.js';\n${original}`;
  source = between(source, 'export const catalogObjectCount =', '// Mirrors TargetSearch.',
    `export const catalogObjectCount=canonical.library.counts.targets;\nexport const targetSample=Object.freeze(roots.targets);\nexport const targets=Object.fromEntries(targetSample.map(t=>[t.id,t.name]));\n`);
  source = between(source, 'export const rigs =', '// CameraClass.label',
    `export const rigs=roots.rigs;\n`);
  source = between(source, 'export function defaultPlan()', 'export function rigFor',
    `export function defaultPlan(){return structuredClone(roots.plan);}\n`);
  source = once(source, 'export function assumptionsFor(', 'export function sourceAssumptionsFor(');
  source = once(source, "['','Kyiv outskirts','Rural site'].includes(plan.site)",
    "['',...canonical.library.sites.map(s=>s.name)].includes(plan.site)");
  source = once(source, 'export function estimate(', 'export function sourceEstimate(');
  source += `
export function assumptionsFor(plan,overrides=null){
 return JSON.stringify(plan.blocks)===JSON.stringify(roots.plan.blocks)
   ? {...roots.assumptions,...(overrides||{}),...(plan.assumptions||{})}
   : sourceAssumptionsFor(plan,overrides);
}
export function estimate(plan,overrides=null){
 const result=sourceEstimate(plan,overrides);
 if(plan.night!==roots.plan.night||JSON.stringify(plan.blocks)!==JSON.stringify(roots.plan.blocks))return result;
 const f=roots.fit,n=canonical.nights[plan.night];
 return {...result,integration:f.integrationMs/1000,needed:f.windowLoadMs/1000,
   total:f.sessionBudgetMs/1000,outside:(f.outsideWindowCalibrationMs+(f.setupMs??0))/1000,
   bytes:f.storageMB===null?null:f.storageMB*1e6,usable:f.availableMs/1000,
   verdict:roots.verdict,windowStart:n.targetWindows[0]?.start??null,
   windowEnd:n.targetWindows.at(-1)?.end??null,assumptions:assumptionsFor(plan,overrides)};
}
`;
  return source;
}

export function adaptRootModule(name, original) {
  let source = `import canonical from './comparison-fixture.js';\nimport roots from './comparison-root-data.js';\n${original}`;
  if (name === 'library.js') {
    source = between(source, 'const CATALOGUE =', '// Kept across remounts',
      `const CATALOGUE=roots.targets.filter(t=>t.bundled).map(t=>({...t,key:'catalogue:'+t.id,vMag:t.magnitude}));\n\n`);
    source = between(source, 'function exampleData()', '/* ---------- Isolated local persistence',
      `function exampleData(){return structuredClone(roots.library);}\n\n`);
  } else if (name === 'logbook.js') {
    source = once(source, "const EXAMPLE_NOW = Date.parse('2026-10-19T16:00:00Z');",
      'const EXAMPLE_NOW = canonical.nowUtcMs;');
    source = once(source, "const ZONE = 'Europe/Kyiv';", 'const ZONE = canonical.site.zone;');
    source = between(source, 'function exampleEntries()', '/* ---------- Isolated local persistence',
      `function exampleEntries(){return structuredClone(roots.entries);}\n\n`);
  } else if (name === 'settings.js') {
    source = between(source, 'function defaultSettings()', 'const isObject =',
      `function defaultSettings(){return structuredClone(roots.settings);}\n\n`);
  } else if (name === 'preview-bridge.js') {
    source = between(source, 'export const initialPlanningPreferences=', 'const clone=',
      `export const initialPlanningPreferences=Object.freeze(roots.settings.planning);\n`);
  } else if (name === 'app.js') {
    source = between(source, 'const fixture =', 'let previewPlan=',
      `const fixture={site:canonical.site.name,night:canonical.selectedEveningDate,target:canonical.tonight.targetLabel,catalog:roots.plan.target,resultDue:false};\n`);
    source = between(source, 'function dueResult()', 'function navigation()',
      `function dueResult(){return '';}\n`);
  } else if (name === 'plan.js') {
    source = once(source, "const SITES=['Kyiv outskirts','Rural site',...libraryChoices.sites.map(s=>s.key)];",
      'const SITES=canonical.library.sites.map(s=>s.name);');
    source = once(source, 'function formatBytes(bytes){', "function formatBytes(bytes){if(bytes===null||!Number.isFinite(bytes))return 'Unknown';");
  }
  return source;
}

async function files(root) {
  const result = [];
  for (const entry of await readdir(root, { withFileTypes: true })) {
    if (['evidence', 'node_modules', '.git'].includes(entry.name)) continue;
    const full = path.join(root, entry.name);
    if (entry.isDirectory()) result.push(...await files(full));
    else result.push(full);
  }
  return result;
}

export async function prepare(fixturePath) {
  const sourceDir = path.join(repo, 'design/home-lab');
  const raw = await readFile(fixturePath);
  const fixture = JSON.parse(raw);
  validateFixture(fixture);
  const rootData = projectRoots(fixture);
  const entries = [];
  for (const file of (await files(sourceDir)).sort()) {
    entries.push({ path: path.relative(sourceDir, file).replaceAll('\\', '/'),
      sha256: sha256(await readFile(file)) });
  }
  const fingerprint = sha256(JSON.stringify(entries) + sha256(raw)).slice(0, 16);
  const out = path.join(repo, 'build/design-comparison', fingerprint);
  // Reusing an identical source+fixture fingerprint is deterministic.
  await mkdir(out, { recursive: true });
  for (const entry of entries) {
    const dest = path.join(out, entry.path);
    await mkdir(path.dirname(dest), { recursive: true });
    await cp(path.join(sourceDir, entry.path), dest);
  }
  await writeFile(path.join(out, 'comparison-fixture.js'),
    `export default ${JSON.stringify(fixture)};\n`);
  await writeFile(path.join(out, 'comparison-root-data.js'),
    `export default ${JSON.stringify(rootData)};\n`);
  await writeFile(path.join(out, 'night-model.js'),
    adaptModel(await readFile(path.join(sourceDir, 'night-model.js'), 'utf8'), fixture));
  await writeFile(path.join(out, 'conditions.js'),
    adaptConditions(await readFile(path.join(sourceDir, 'conditions.js'), 'utf8')));
  await writeFile(path.join(out, 'plan-model.js'),
    adaptPlanModel(await readFile(path.join(sourceDir, 'plan-model.js'), 'utf8')));
  const rootModules = ['library.js', 'logbook.js', 'settings.js', 'preview-bridge.js', 'app.js', 'plan.js'];
  for (const name of rootModules) {
    await writeFile(path.join(out, name),
      adaptRootModule(name, await readFile(path.join(sourceDir, name), 'utf8')));
  }
  await writeFile(path.join(out, 'package.json'), '{"type":"module"}\n');
  const generated = [];
  for (const name of ['night-model.js', 'conditions.js', 'comparison-fixture.js',
    'comparison-root-data.js', 'plan-model.js', ...rootModules]) {
    generated.push({ path: name, sha256: sha256(await readFile(path.join(out, name))) });
  }
  const manifest = {
    kind: 'test-only canonical native DTO / original Hybrid presentation',
    fixture: { path: path.resolve(fixturePath), sha256: sha256(raw) },
    generatedAtUtc: new Date().toISOString(), source: entries, generated,
    scope: ['Tonight', 'Plan', 'Night', 'Moon', 'Weather', 'Logbook', 'Library', 'Settings'],
    limitations: [
      'Comparison uses fixed initial native records; edits inside the copied browser prototype are not native calculation evidence.',
      'Native fit/budget/storage values replace initial browser estimate output; sourceEstimate remains available for independent comparison.',
      'Original wording about examples and fixed coming-night bounds can remain; compare facts and chart geometry separately.',
      'Browser and native aggregate disagreement is reported separately; nativeSummary supplies shared render input.',
      'Continuous Moon-up events and native five-minute Moon rail can differ; inspect exported gridMoonUp separately.',
      'This adapter accepts metric fixtures only; native other-unit behavior has separate widget tests.',
      'Host/browser captures do not establish emulator, physical-device or owner acceptance.',
    ],
  };
  await writeFile(path.join(out, 'comparison-manifest.json'), JSON.stringify(manifest, null, 2));
  // Verify source remained byte-identical, including all CSS, before reporting.
  for (const entry of entries) {
    if (sha256(await readFile(path.join(sourceDir, entry.path))) !== entry.sha256) {
      throw new Error(`Original source changed while adapting: ${entry.path}`);
    }
  }
  return { out, fixture, manifest };
}

if (process.argv[1] && path.resolve(process.argv[1]) === fileURLToPath(import.meta.url)) {
  if (!process.argv[2]) throw new Error('Usage: node tool/design/comparison/prepare.mjs fixture.json');
  const result = await prepare(process.argv[2]);
  const selected = result.fixture.selectedEveningDate;
  console.log(JSON.stringify({ out: result.out,
    route: `conditions.html?variant=blend&font=Geist&night=${selected}&view=weather&theme=light&scale=1` }, null, 2));
}
