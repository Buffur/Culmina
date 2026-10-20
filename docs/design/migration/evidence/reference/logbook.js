// Logbook tab of Culmina's Android browser prototype: mountLogbook(root, api).
//
// Functional reference (production Flutter, read-only here):
// lib/presentation/screens/logbook/logbook_screen.dart (list, search, filters,
// Upcoming/Past), session_detail_screen.dart (read-only snapshot detail),
// progress_screen.dart (Progress by target), screens/execution/results_screen.dart
// ("How did it go?"), SessionsViewModel, ResultsViewModel, PlanState,
// SessionReconciliation (CALC-37) and TargetProgress (CALC-38).
//
// Every entry is a labelled browser fixture. Local edits (results, deletions)
// live only under culmina-logbook-preview-v1; this module never reads or writes
// the plan preview, navigation checkpoints or any application database.

const STORAGE_KEY = 'culmina-logbook-preview-v1';
const CONTEXT_KEY = 'culmina-logbook-context-v1';
const PAYLOAD_KIND = 'culmina-logbook-preview';
const PAYLOAD_VERSION = 1;
// The lab's shared fixture clock (night-model.js fixtureNow): 19 Oct 2026,
// 19:00 Kyiv time. Upcoming/Past and "can a result be recorded" use it, so the
// example nights do not drift with the real date.
const EXAMPLE_NOW = Date.parse('2026-10-19T16:00:00Z');
const ZONE = 'Europe/Kyiv';
const SCENARIOS = ['ready', 'empty', 'error', 'storage-error'];
const ENTRY_ID = /^(example|local)-[a-z0-9-]{1,64}$/;
const BLOCK_ID = /^[a-z0-9-]{1,32}$/;
const MAX_FRAMES = 100000; // results_screen.dart _frames
const MAX_NOTE = 4000; // prototype guard only
const FRAME_TYPES = { Light: 'Lights', Dark: 'Darks', Flat: 'Flats', Bias: 'Bias', DarkFlat: 'Dark flats' };
const OUTCOMES = [
  ['asPlanned', 'Completed as planned'],
  ['partly', 'Partly'],
  ['notDone', 'Not done'],
];
const REASONS = [['', 'Not given'], ['clouds', 'Clouds'], ['wind', 'Wind'], ['dew', 'Dew'], ['equipment', 'Equipment'], ['other', 'Other']];
const STATE_WORDS = { saved: 'Saved', completed: 'Completed', partly: 'Partly', notDone: 'Not done' };
// SessionListStatus: Completed includes Partly results; Tracking has no example.
const STATE_FILTERS = [['saved', 'Saved'], ['completed', 'Completed'], ['notDone', 'Not done']];
const MEMORY_ONLY = ['unreadable', 'unavailable', 'scenario'];

// Kept across remounts within the page, as SessionsViewModel keeps them across navigation.
const ui = { query: '', filter: emptyFilter(), filtersOpen: false, listScroll: 0, undo: null, undoError: '' };

function emptyFilter() {
  return { states: [], target: '', site: '', from: '', to: '' };
}

/* ---------- Example nights (fixtures, not measurements) ---------- */

const SITES = {
  kyiv: { name: 'Kyiv outskirts', latDeg: 50.4, lonDeg: 30.6, elevationM: null, bortle: null, sqm: null },
  rural: { name: 'Rural site', latDeg: 50.8, lonDeg: 30.95, elevationM: 160, bortle: 4, sqm: null },
};
// The same example rigs as plan-model.js: only recorded properties, unknown otherwise.
const RIGS = {
  dslr: { name: 'DSLR · 135 mm lens', cameraClass: 'DSLR / mirrorless', sensitivity: 'iso', focalLengthMm: 135, focalRatio: null, pixelUm: null },
  phone: { name: 'Phone · wide camera', cameraClass: 'Phone', sensitivity: 'iso', focalLengthMm: null, focalRatio: null, pixelUm: null },
  astro: { name: 'Astro camera · refractor', cameraClass: 'Astro camera (colour)', sensitivity: 'gain', focalLengthMm: 400, focalRatio: 5.6, pixelUm: 3.76 },
};
const TARGETS = {
  m31: { name: 'M31', raDec: '00h 42m 44s, +41° 16′ 09″' },
  m33: { name: 'M33', raDec: '01h 33m 51s, +30° 39′ 37″' },
  m42: { name: 'M42', raDec: '05h 35m 17s, −05° 23′ 28″' },
  m45: { name: 'M45', raDec: '03h 47m 24s, +24° 07′ 00″' },
  ngc7000: { name: 'NGC 7000', raDec: '20h 59m 17s, +44° 31′ 44″' },
};

const light = (id, filter, exposureS, planned, sensitivity, binning = 1) =>
  ({ id, type: 'Light', filter, exposureS, planned, sensitivity, binning });
const calibration = (id, type, exposureS, planned, sensitivity) =>
  ({ id, type, filter: null, exposureS, planned, sensitivity, binning: 1 });

// The fixed 24-hour night key from local mean solar noon (ADR-007), as the
// snapshot's "Night span"; it is not an imaging window.
function nightKey(evening, lonDeg) {
  const start = Math.round((Date.parse(`${evening}T12:00:00Z`) - (lonDeg / 15) * 3600000) / 60000) * 60000;
  return { evening, startUtc: new Date(start).toISOString(), endUtc: new Date(start + 86400000).toISOString() };
}

function example(id, target, site, rig, evening, blocks, result) {
  return {
    id,
    example: true,
    name: null,
    plan: {
      takenAtUtc: `${evening}T10:30:00.000Z`,
      zone: ZONE,
      night: nightKey(evening, SITES[site].lonDeg),
      darknessLimitDeg: -18,
      minAltitudeDeg: 30,
      site: { ...SITES[site] },
      target: { ...TARGETS[target] },
      rig: { ...RIGS[rig] },
      blocks,
    },
    result: result && {
      outcome: result.outcome,
      counts: result.counts || {},
      reason: result.reason || null,
      environmentalNotes: result.environmentalNotes || null,
      processingNotes: result.processingNotes || null,
      recordedAtUtc: null,
      local: false,
    },
  };
}

function exampleEntries() {
  return [
    example('example-m31-2026-10-12', 'm31', 'kyiv', 'dslr', '2026-10-12',
      [light('b1', 'Broadband', 60, 120, 800), light('b2', 'Broadband', 120, 30, 800)],
      { outcome: 'partly', counts: { b1: 96, b2: 30 }, environmentalNotes: 'Cloud from about 01:10; the 60 s block stopped early.' }),
    example('example-ngc7000-2026-10-08', 'ngc7000', 'rural', 'astro', '2026-10-08',
      [light('b1', 'Dual-band', 300, 36, 100), light('b2', 'Dual-band', 300, 12, 200), calibration('b3', 'Dark', 300, 20, 100)],
      { outcome: 'asPlanned', processingNotes: 'Gain 200 frames kept apart from gain 100 when stacking.' }),
    example('example-m45-2026-10-10', 'm45', 'kyiv', 'phone', '2026-10-10',
      [light('b1', null, 10, 200, null)],
      { outcome: 'notDone', reason: 'clouds' }),
    example('example-m31-2026-10-05', 'm31', 'rural', 'dslr', '2026-10-05',
      [light('b1', 'Broadband', 60, 100, 800), light('b2', 'Broadband', 30, 40, null)],
      { outcome: 'asPlanned', environmentalNotes: 'ISO of the 30 s block was not written down.' }),
    // The unrecorded result: its night has ended, no result yet.
    example('example-m33-2026-10-15', 'm33', 'kyiv', 'dslr', '2026-10-15',
      [light('b1', 'Broadband', 60, 150, 1600)], null),
    // Upcoming: its night has not started at the example clock.
    example('example-m42-2026-10-24', 'm42', 'rural', 'dslr', '2026-10-24',
      [light('b1', 'Broadband', 90, 80, 800)], null),
  ];
}

/* ---------- Isolated local persistence ---------- */

const isString = v => typeof v === 'string';
const optString = v => v === null || isString(v);
const optNumber = v => v === null || Number.isFinite(v);
const isDate = v => isString(v) && /^\d{4}-\d{2}-\d{2}$/.test(v);
const isInstant = v => isString(v) && Number.isFinite(Date.parse(v));

function validBlock(b) {
  return !!b && isString(b.id) && BLOCK_ID.test(b.id) && Object.hasOwn(FRAME_TYPES, b.type) && optString(b.filter) &&
    Number.isFinite(b.exposureS) && b.exposureS > 0 && Number.isSafeInteger(b.planned) && b.planned >= 0 &&
    optNumber(b.sensitivity) && Number.isSafeInteger(b.binning) && b.binning >= 1;
}

function validPlan(p) {
  return !!p && isInstant(p.takenAtUtc) && isString(p.zone) &&
    !!p.night && isDate(p.night.evening) && isInstant(p.night.startUtc) && isInstant(p.night.endUtc) &&
    optNumber(p.darknessLimitDeg) && optNumber(p.minAltitudeDeg) &&
    !!p.site && isString(p.site.name) && ['latDeg', 'lonDeg', 'elevationM', 'bortle', 'sqm'].every(k => optNumber(p.site[k])) &&
    !!p.target && isString(p.target.name) && optString(p.target.raDec) &&
    !!p.rig && isString(p.rig.name) && optString(p.rig.cameraClass) && [null, 'iso', 'gain'].includes(p.rig.sensitivity) &&
    ['focalLengthMm', 'focalRatio', 'pixelUm'].every(k => optNumber(p.rig[k])) &&
    Array.isArray(p.blocks) && p.blocks.length <= 50 && p.blocks.every(validBlock) &&
    new Set(p.blocks.map(b => b.id)).size === p.blocks.length;
}

function validResult(r, blocks) {
  if (r === null) return true;
  if (!r || !OUTCOMES.some(([value]) => value === r.outcome)) return false;
  const lights = new Set(blocks.filter(b => b.type === 'Light').map(b => b.id));
  const counts = r.counts;
  if (!counts || typeof counts !== 'object' || Array.isArray(counts)) return false;
  if (!Object.entries(counts).every(([id, n]) => lights.has(id) && Number.isSafeInteger(n) && n >= 0 && n <= MAX_FRAMES)) return false;
  if (r.outcome === 'partly' && ![...lights].every(id => Object.hasOwn(counts, id))) return false;
  return REASONS.some(([value]) => value === (r.reason ?? '')) && optString(r.environmentalNotes) && optString(r.processingNotes) &&
    (r.recordedAtUtc === null || isInstant(r.recordedAtUtc)) && typeof r.local === 'boolean';
}

function validEntry(x) {
  return !!x && isString(x.id) && ENTRY_ID.test(x.id) && typeof x.example === 'boolean' && optString(x.name) &&
    validPlan(x.plan) && validResult(x.result, x.plan.blocks);
}

// Shared only by the browser preview backup review. Validation is pure: no
// fixture substitution, storage writes or changes to historical snapshots.
export function validateLogbookPayload(raw) {
  try {
    const value = typeof raw === 'string' ? JSON.parse(raw) : raw;
    return value?.kind === PAYLOAD_KIND && value.version === PAYLOAD_VERSION && Array.isArray(value.entries) &&
      value.entries.every(validEntry) && new Set(value.entries.map(x => x.id)).size === value.entries.length;
  } catch { return false; }
}

function deepFreeze(value) {
  if (value && typeof value === 'object' && !Object.isFrozen(value)) {
    Object.freeze(value);
    for (const child of Object.values(value)) deepFreeze(child);
  }
  return value;
}

// The planned snapshot is immutable: a result edit replaces only `result`.
function freezeEntry(x) {
  deepFreeze(x.plan);
  return x;
}

// status: 'stored' (our key, valid), 'examples' (no key yet), 'unreadable'
// (malformed payload, kept untouched), 'unavailable' (storage threw).
function readStore(storage) {
  let raw;
  try {
    raw = storage.getItem(STORAGE_KEY);
  } catch {
    return { status: 'unavailable', entries: exampleEntries().map(freezeEntry) };
  }
  if (raw === null) return { status: 'examples', entries: exampleEntries().map(freezeEntry) };
  try {
    const value = JSON.parse(raw);
    if (validateLogbookPayload(value)) {
      return { status: 'stored', entries: value.entries.map(freezeEntry) };
    }
  } catch { /* malformed JSON: reported below, never overwritten */ }
  return { status: 'unreadable', entries: exampleEntries().map(freezeEntry) };
}

function writeStore(storage, entries) {
  storage.setItem(STORAGE_KEY, JSON.stringify({ kind: PAYLOAD_KIND, version: PAYLOAD_VERSION, entries }));
}

class PreviewFailure extends Error {
  constructor(kind) {
    super(kind);
    this.kind = kind;
  }
}

/* ---------- Domain rules (mirrors of the production contracts) ---------- */

// PlanState.from: a saved plan without a result is Saved; Completed/Partly/Not done follow the result.
function stateOf(x) {
  if (!x.result) return 'saved';
  return x.result.outcome === 'asPlanned' ? 'completed' : x.result.outcome;
}

// ResultAction.of with the example clock: Edit for a result, Record from the
// saved night's start (SavedNightEnd.startOf), nothing before it.
function resultAction(x) {
  if (x.result) return 'edit';
  return EXAMPLE_NOW >= Date.parse(x.plan.night.startUtc) ? 'record' : 'none';
}

// SessionsViewModel.isUpcoming: a saved plan whose night has not ended. The
// prototype ends the night at its key's end; production uses the dawn at the
// snapshot's darkness limit (CALC-44), which no example night falls between.
function isUpcoming(x) {
  return !x.result && EXAMPLE_NOW < Date.parse(x.plan.night.endUtc);
}

const lightBlocks = x => x.plan.blocks.filter(b => b.type === 'Light');

// Recorded light frames per block; null when the entry has no counts (no
// result, or Not done). "Completed as planned" is the user's report that the
// planned counts were taken (ResultKind.asPlanned), not counted frames.
function recordedCounts(x) {
  const r = x.result;
  if (!r || r.outcome === 'notDone') return null;
  return Object.fromEntries(lightBlocks(x).map(b => [b.id, r.outcome === 'asPlanned' ? b.planned : (r.counts[b.id] ?? 0)]));
}

const plannedSeconds = x => lightBlocks(x).reduce((sum, b) => sum + b.planned * b.exposureS, 0);

function recordedSeconds(x) {
  const counts = recordedCounts(x);
  return counts && lightBlocks(x).reduce((sum, b) => sum + counts[b.id] * b.exposureS, 0);
}

// TargetProgress.of (CALC-38) from recorded results only, per filter as in
// production; beneath each filter, settings that cannot be stacked as one
// comparable group (exposure, sensitivity, binning, rig) stay separate, and a
// block without a recorded sensitivity is never combined with another.
function progressByTarget(entries) {
  const targets = new Map();
  for (const x of entries) {
    const counts = recordedCounts(x);
    if (!counts) continue;
    const name = x.plan.target.name;
    const t = targets.get(name) || { name, seconds: 0, results: 0, lastNight: null, filters: new Map() };
    t.results += 1;
    if (!t.lastNight || x.plan.night.evening > t.lastNight) t.lastNight = x.plan.night.evening;
    for (const b of lightBlocks(x)) {
      const frames = counts[b.id], seconds = frames * b.exposureS;
      const filterName = b.filter?.trim() || 'No filter';
      const f = t.filters.get(filterName) || { name: filterName, seconds: 0, groups: new Map() };
      const kind = x.plan.rig.sensitivity, known = kind !== null && b.sensitivity !== null;
      const key = known ? JSON.stringify([x.plan.rig.name, b.exposureS, kind, b.sensitivity, b.binning]) : `unknown:${x.id}:${b.id}`;
      const g = f.groups.get(key) || { exposureS: b.exposureS, kind, value: b.sensitivity, binning: b.binning, rig: x.plan.rig.name, known, frames: 0, seconds: 0, nights: new Set() };
      g.frames += frames;
      g.seconds += seconds;
      g.nights.add(x.plan.night.evening);
      f.groups.set(key, g);
      f.seconds += seconds;
      t.filters.set(filterName, f);
      t.seconds += seconds;
    }
    targets.set(name, t);
  }
  return [...targets.values()].sort((a, b) => b.lastNight.localeCompare(a.lastNight));
}

/* ---------- Wording and units ---------- */

const dayFormat = new Intl.DateTimeFormat('en-GB', { weekday: 'short', day: 'numeric', month: 'short', timeZone: 'UTC' });
const monthFormat = new Intl.DateTimeFormat('en-GB', { month: 'long', year: 'numeric', timeZone: 'UTC' });

function eveningLabel(date) {
  return dayFormat.format(Date.parse(`${date}T12:00:00Z`)).replace(/,/g, '');
}

function monthLabel(date) {
  return monthFormat.format(Date.parse(`${date.slice(0, 7)}-15T12:00:00Z`));
}

function instantLabel(iso, zone) {
  return new Intl.DateTimeFormat('en-GB', { day: 'numeric', month: 'short', hour: '2-digit', minute: '2-digit', hourCycle: 'h23', timeZone: zone })
    .format(Date.parse(iso));
}

function zoneCaption(iso, zone) {
  const offset = new Intl.DateTimeFormat('en-GB', { timeZone: zone, timeZoneName: 'shortOffset' })
    .formatToParts(Date.parse(iso)).find(p => p.type === 'timeZoneName')?.value;
  return offset ? `${zone} (${offset})` : zone;
}

// QuantityText.duration
function duration(totalSeconds) {
  if (totalSeconds > 0 && totalSeconds < 60) return `${Math.max(1, Math.round(totalSeconds))} s`;
  const minutes = Math.round(totalSeconds / 60), h = Math.floor(minutes / 60), m = minutes % 60;
  if (h === 0) return `${m} min`;
  return m === 0 ? `${h} h` : `${h} h ${m} min`;
}

// QuantityText.exposure (whole and decimal seconds; reciprocal for sub-second)
function exposure(seconds) {
  if (seconds > 0 && seconds < 1) {
    const d = Math.round(1 / seconds);
    if (d >= 2 && Math.abs(seconds * d - 1) <= 0.005) return `${Math.abs(seconds * d - 1) <= 1e-12 ? '' : '≈'}1/${d} s`;
  }
  return `${Number(seconds.toFixed(2))} s`;
}

function degrees(value, digits = 0) {
  if (value === null) return 'unknown';
  const text = Math.abs(value).toFixed(digits);
  return `${value < 0 && Number(text) !== 0 ? '−' : ''}${text}°`;
}

function sensitivityText(kind, value) {
  if (kind === 'iso') return value === null ? 'ISO not recorded' : `ISO ${value}`;
  if (kind === 'gain') return value === null ? 'Gain not recorded' : `Gain ${value}`;
  return 'Sensitivity not recorded';
}

function blockLabel(x, b) {
  const parts = [b.filter || FRAME_TYPES[b.type], exposure(b.exposureS), sensitivityText(x.plan.rig.sensitivity, b.sensitivity)];
  if (b.binning > 1) parts.push(`bin ${b.binning}×${b.binning}`);
  return parts.join(' · ');
}

// entryTitle: the name when there is one, else target · night.
const titleOf = x => x.name ?? `${x.plan.target.name} · ${eveningLabel(x.plan.night.evening)}`;

// EntryShareText.result
function resultPhrase(x) {
  const state = STATE_WORDS[stateOf(x)];
  if (!x.result) return state;
  if (x.result.outcome === 'asPlanned') return `${state}, reported as planned`;
  if (x.result.outcome === 'notDone' && x.result.reason) return `${state} (${x.result.reason})`;
  return state;
}

// ResultsText.integration / plannedOnly
function integrationLine(x) {
  const planned = duration(plannedSeconds(x)), recorded = recordedSeconds(x);
  if (recorded !== null) return `Integration: ${duration(recorded)} of ${planned} planned`;
  const due = !x.result && resultAction(x) === 'record';
  return `Integration: ${due ? 'none recorded of ' : ''}${planned} planned`;
}

function resultWhen(x) {
  return `Record from ${instantLabel(x.plan.night.startUtc, x.plan.zone)} · ${zoneCaption(x.plan.night.startUtc, x.plan.zone)}.`;
}

const plural = (n, one, many = `${one}s`) => `${n} ${n === 1 ? one : many}`;

const MARKS = {
  completed: '<circle cx="12" cy="12" r="8.5"/><path d="m8.5 12.2 2.4 2.4 4.6-5"/>',
  partly: '<circle cx="12" cy="12" r="8.5"/><path d="M12 3.5v17a8.5 8.5 0 0 0 0-17z" fill="currentColor" stroke="none"/>',
  notDone: '<circle cx="12" cy="12" r="8.5"/><path d="m9 9 6 6m0-6-6 6"/>',
  due: '<rect x="5" y="4" width="14" height="16" rx="2"/><path d="M9 4v2h6V4M12 10v4l2.5 1.5"/>',
};
const mark = name => MARKS[name] ? `<svg class="logbook-mark" viewBox="0 0 24 24" aria-hidden="true">${MARKS[name]}</svg>` : '';

/* ---------- Module ---------- */

export function mountLogbook(root, api) {
  const hybrid = (api.variant ?? new URLSearchParams(location.search).get('variant') ?? 'blend') === 'blend';
  const esc = api.esc;
  const storage = api.storage;
  const scenario = SCENARIOS.includes(api.scenario) ? api.scenario : 'ready';
  const S = {
    view: 'list', id: null, from: 'list',
    draft: null, initial: '', baseline: '', errors: {}, saveError: '', saveMissing: false, deleteError: '',
    loadFailed: scenario === 'error',
    simulateFail: scenario === 'storage-error',
    status: 'examples', entries: [],
  };
  const dialogs = new Set();
  let disposed = false;
  let remembered = null;
  // Navigation context is session-only and never contains a result draft.
  // Refusing storage must not interrupt the Logbook task.
  try {
    const saved = JSON.parse(sessionStorage.getItem(CONTEXT_KEY) || 'null');
    if (saved?.version === 1 && saved.scenario === scenario && typeof saved.query === 'string' && saved.query.length <= 4000 &&
      saved.filter && Array.isArray(saved.filter.states) && saved.filter.states.every(s => STATE_FILTERS.some(([v]) => v === s)) &&
      ['target', 'site', 'from', 'to'].every(k => typeof saved.filter[k] === 'string' && saved.filter[k].length <= 4000)) {
      ui.query = saved.query;
      ui.filter = { ...emptyFilter(), ...saved.filter };
      ui.filtersOpen = saved.filtersOpen === true;
      ui.listScroll = Number.isFinite(saved.listScroll) ? Math.max(0, saved.listScroll) : 0;
      remembered = saved;
    }
  } catch { /* Session continuity is optional; durable records are separate. */ }

  function rememberContext() {
    if (S.view === 'list' && scroller) ui.listScroll = scroller.scrollTop;
    try {
      sessionStorage.setItem(CONTEXT_KEY, JSON.stringify({
        version: 1, scenario, query: ui.query, filter: ui.filter, filtersOpen: ui.filtersOpen, listScroll: ui.listScroll,
        view: S.view === 'edit' ? S.from : S.view, id: S.id,
      }));
    } catch { /* Keep operating when sessionStorage is denied. */ }
  }

  function load() {
    if (scenario === 'empty') {
      S.status = 'scenario';
      S.entries = [];
      return;
    }
    const read = readStore(storage);
    S.status = read.status;
    S.entries = read.entries;
  }

  const find = id => S.entries.find(x => x.id === id);
  const selector = (attr, id) => `[${attr}="${CSS.escape(id)}"]`;

  // Applies `change` to the freshest stored list, so an edit made in another
  // tab is never dropped, then writes only this module's key. Memory-only
  // states never write (a malformed payload stays as it is).
  function mutate(change) {
    if (S.simulateFail) throw new PreviewFailure('simulated');
    if (MEMORY_ONLY.includes(S.status)) {
      S.entries = change(S.entries).map(freezeEntry);
      return ' (kept in this tab only)';
    }
    const fresh = readStore(storage);
    if (fresh.status === 'unreadable' || fresh.status === 'unavailable') {
      S.status = fresh.status;
      throw new PreviewFailure(fresh.status);
    }
    const next = change(fresh.entries);
    try {
      writeStore(storage, next);
    } catch {
      throw new PreviewFailure('write');
    }
    S.entries = next.map(freezeEntry);
    S.status = 'stored';
    return '';
  }

  function failureText(error, action) {
    switch (error?.kind) {
      case 'simulated':
        return `Couldn't ${action}. This preview simulates a storage failure; nothing changed and your input is kept. Try again clears the simulation.`;
      case 'unreadable':
        return `Couldn't ${action}: the stored preview data can't be read, so it was left unchanged. Try again keeps the change in this tab only.`;
      case 'unavailable':
        return `Couldn't ${action}: browser storage is unavailable. Try again keeps the change in this tab only.`;
      default:
        return `Couldn't ${action}: this browser refused to store it. Nothing changed and your input is kept.`;
    }
  }

  /* ----- Rendering ----- */

  root.innerHTML = '<div class="logbook-view"></div>';
  const view = root.firstElementChild;
  const scroller = root.closest('.android-scroll');

  function show(next, { id = S.id, focus = null } = {}) {
    if (S.view === 'list' && scroller) ui.listScroll = scroller.scrollTop;
    S.view = next;
    S.id = id;
    render(focus);
    if (scroller) scroller.scrollTop = next === 'list' ? ui.listScroll : 0;
    if (focus && next !== 'list') view.querySelector(focus)?.scrollIntoView({ block: 'nearest' });
    rememberContext();
  }

  function render(focus = null) {
    if (S.view === 'detail') {
      const x = find(S.id);
      api.setHeader(x ? titleOf(x) : 'Logbook', () => show('list', { focus: selector('data-open-entry', S.id) }));
      view.innerHTML = detailView(x);
    } else if (S.view === 'progress') {
      api.setHeader('Progress by target', () => show('list', { focus: '[data-open-progress]' }));
      view.innerHTML = progressView();
    } else if (S.view === 'edit') {
      api.setHeader('How did it go?', () => cancelEdit());
      view.innerHTML = editView();
    } else {
      api.setHeader('Logbook');
      view.innerHTML = listView();
      renderResults();
    }
    const target = (focus && view.querySelector(focus)) || (S.view !== 'list' && view.querySelector('[data-focus-start]')) || null;
    target?.focus({ preventScroll: true });
  }

  function previewNote() {
    const notice = {
      unreadable: `<div class="workspace-error" role="status"><p>The stored Logbook preview data can't be read. It is kept unchanged: the example nights are shown and changes stay in this tab only.</p>
        <div class="workspace-actions"><button type="button" class="secondary-button" data-replace-store>Replace stored data with these entries</button></div></div>`,
      unavailable: '<div class="workspace-error" role="status"><p>Browser storage is unavailable here, so changes stay in this tab only.</p></div>',
      scenario: '<p class="logbook-note">Empty scenario: no entries are shown. Stored preview data is untouched.</p>',
    }[S.status] || '';
    return `<p class="logbook-note">Example nights · 19 Oct 2026, 19:00 Kyiv time · saved in this browser.</p>${notice}`;
  }

  function filterCount() {
    const f = ui.filter;
    return f.states.length + (f.target ? 1 : 0) + (f.site ? 1 : 0) + (f.from || f.to ? 1 : 0);
  }

  const rangeInverted = () => !!(ui.filter.from && ui.filter.to && ui.filter.from > ui.filter.to);

  function matches(x) {
    const f = ui.filter, state = stateOf(x), bucket = state === 'partly' ? 'completed' : state;
    if (f.states.length && !f.states.includes(bucket)) return false;
    if (f.target && x.plan.target.name !== f.target) return false;
    if (f.site && x.plan.site.name !== f.site) return false;
    if (!rangeInverted()) {
      if (f.from && x.plan.night.evening < f.from) return false;
      if (f.to && x.plan.night.evening > f.to) return false;
    }
    // SessionsViewModel.searched: name, target, site or notes, ignoring case.
    const q = ui.query.trim().toLowerCase();
    if (!q) return true;
    return [x.name, x.plan.target.name, x.plan.site.name, x.result?.environmentalNotes, x.result?.processingNotes]
      .some(text => !!text && text.toLowerCase().includes(q));
  }

  function options(pick) {
    return [...new Set(S.entries.map(pick))].sort((a, b) => a.localeCompare(b));
  }

  function listView() {
    if (S.loadFailed) {
      return `<div class="workspace-error" role="alert"><p>Couldn't load the Logbook.</p>
        <p class="workspace-copy">This is the preview's simulated load failure; stored entries are untouched.</p>
        <div class="workspace-actions"><button type="button" class="secondary-button" data-retry-load>Try again</button></div></div>`;
    }
    const f = ui.filter;
    const select = (name, label, values, current) => `<label class="block-input">${label}
      <select data-filter="${name}"><option value="">All</option>${values.map(v => `<option value="${esc(v)}"${v === current ? ' selected' : ''}>${esc(v)}</option>`).join('')}${current && !values.includes(current) ? `<option value="${esc(current)}" selected>${esc(current)}</option>` : ''}</select></label>`;
    return `${previewNote()}
      <div class="workspace-toolbar logbook-toolbar">
        <label class="block-input logbook-search">Search
          <input type="search" data-search value="${esc(ui.query)}" placeholder="Name, target, site or notes" autocomplete="off" enterkeyhint="search">
        </label>
      </div>
      <details class="logbook-filters" data-filters${ui.filtersOpen ? ' open' : ''}>
        <summary><span data-filter-summary></span></summary>
        <div class="workspace-form">
          <fieldset><legend>State</legend>
            ${STATE_FILTERS.map(([value, label]) => `<label class="logbook-check"><input type="checkbox" data-filter-state value="${value}"${f.states.includes(value) ? ' checked' : ''}><span>${label}</span></label>`).join('')}
            <p class="logbook-caption">Completed includes Partly results, as in the app.</p>
          </fieldset>
          ${select('target', 'Target', options(x => x.plan.target.name), f.target)}
          ${select('site', 'Site', options(x => x.plan.site.name), f.site)}
          <fieldset><legend>Nights (evening date)</legend>
            <div class="logbook-range">
              <label class="block-input">From<input type="date" data-filter="from" value="${esc(f.from)}"></label>
              <label class="block-input">To<input type="date" data-filter="to" value="${esc(f.to)}"></label>
            </div>
            <p class="field-error" data-range-error role="status"></p>
          </fieldset>
          <div class="workspace-actions"><button type="button" class="secondary-button" data-clear-filters>Clear filters</button></div>
        </div>
      </details>
      <button type="button" class="workspace-row logbook-row" data-open-progress>
        <span class="logbook-row-text"><span class="logbook-row-title">Progress by target</span>
        <span class="workspace-copy">Integration so far, from your results</span></span>${api.icon('next')}
      </button>
      <p class="logbook-count" data-result-count aria-live="polite"></p>
      <div data-results></div>`;
  }

  // Updates only the results, so the search field keeps its caret and IME state.
  function renderResults() {
    const box = view.querySelector('[data-results]');
    if (!box) return;
    const visible = S.entries.filter(matches);
    const count = filterCount(), narrowed = count > 0 || !!ui.query.trim();
    const summary = view.querySelector('[data-filter-summary]');
    if (summary) summary.textContent = count ? `Filters · ${count} on` : 'Filters';
    const rangeError = view.querySelector('[data-range-error]');
    if (rangeError) rangeError.textContent = rangeInverted() ? 'The first night is after the last, so the night filter is not applied.' : '';
    const counter = view.querySelector('[data-result-count]');
    if (counter) counter.textContent = narrowed ? `${visible.length} of ${plural(S.entries.length, 'entry', 'entries')}` : plural(S.entries.length, 'entry', 'entries');

    let html = undoView();
    if (!S.entries.length) {
      html += `<div class="workspace-empty"><p>${hybrid?'Nothing saved yet. Save a plan, then return here to record its result.':'Nothing saved yet. Plans you save appear here, and their results once you record them.'}</p>${hybrid?`<div class="workspace-actions"><a class="secondary-button" href="plan.html?variant=blend&amp;theme=${api.display?.theme||'light'}&amp;scale=${api.display?.scale||'1'}">Open planner</a></div>`:''}</div>`;
    } else if (!visible.length) {
      html += `<div class="workspace-empty"><p>Nothing matches the search or the filters.</p>
        <div class="workspace-actions"><button type="button" class="secondary-button" data-clear-all>Clear search and filters</button></div></div>`;
    }
    const upcoming = visible.filter(isUpcoming).sort((a, b) => a.plan.night.evening.localeCompare(b.plan.night.evening));
    const past = visible.filter(x => !isUpcoming(x)).sort((a, b) => b.plan.night.evening.localeCompare(a.plan.night.evening));
    if (upcoming.length) {
      html += `<section class="logbook-group" aria-labelledby="logbook-upcoming"><h2 id="logbook-upcoming">Upcoming</h2>
        <ul class="logbook-list">${upcoming.map(rowView).join('')}</ul></section>`;
    }
    if (past.length) {
      const months = new Map();
      for (const x of past) {
        const key = x.plan.night.evening.slice(0, 7);
        months.set(key, [...(months.get(key) || []), x]);
      }
      html += `<section class="logbook-group" aria-labelledby="logbook-past"><h2 id="logbook-past">Past</h2>
        ${[...months.values()].map(list => `<h3 class="logbook-month">${esc(monthLabel(list[0].plan.night.evening))}</h3>
          <ul class="logbook-list">${list.map(rowView).join('')}</ul>`).join('')}</section>`;
    }
    box.innerHTML = html;
  }

  function undoView() {
    const u = ui.undo;
    if (!u) return '';
    return `<div class="logbook-undo" role="status">
      <p>Deleted “${esc(u.title)}”.</p>
      <div class="workspace-actions"><button type="button" class="secondary-button" data-undo>Undo</button>
      <button type="button" class="quiet-button" data-dismiss-undo>Dismiss</button></div>
      ${ui.undoError ? `<p class="field-error" role="alert">${esc(ui.undoError)}</p>` : ''}</div>`;
  }

  function rowView(x) {
    const state = stateOf(x), action = resultAction(x), due = action === 'record' && !x.result;
    const id = esc(x.id);
    return `<li class="logbook-entry">
      <button type="button" class="workspace-row logbook-row" data-open-entry="${id}">
        <span class="logbook-row-text">
          <span class="logbook-row-title">${esc(titleOf(x))}</span>
          <span class="logbook-state">${mark(state)}<span>${STATE_WORDS[state]}</span>${due ? `<span class="logbook-due">${mark('due')}Result not recorded</span>` : ''}</span>
          <span class="workspace-copy">${esc(x.plan.rig.name)} · ${esc(x.plan.site.name)}</span>
          <span class="logbook-integration">${esc(integrationLine(x))}</span>
          ${action === 'none' ? `<span class="logbook-caption">${esc(resultWhen(x))}</span>` : ''}
          ${x.example ? `<span class="logbook-caption">Example night${x.result?.local ? ' · result edited in this browser' : ''}</span>` : ''}
        </span>${api.icon('next')}
      </button>
      ${action === 'none' ? '' : `<button type="button" class="quiet-button logbook-row-action" data-result-entry="${id}">${action === 'record' ? 'Record result' : 'Edit result'}<span class="logbook-hidden"> for ${esc(titleOf(x))}</span></button>`}
    </li>`;
  }

  const facts = rows => `<dl class="workspace-facts logbook-facts">${rows.map(([k, v]) => `<div><dt>${esc(k)}</dt><dd>${esc(v)}</dd></div>`).join('')}</dl>`;

  function missingView() {
    return `<div class="workspace-empty"><p data-focus-start tabindex="-1">This entry no longer exists.</p>
      <div class="workspace-actions"><button type="button" class="secondary-button" data-back-list>Back to Logbook</button></div></div>`;
  }

  function detailView(x) {
    if (!x) return missingView();
    const p = x.plan, state = stateOf(x), action = resultAction(x), counts = recordedCounts(x);
    const due = action === 'record' && !x.result;
    const progress = progressByTarget(S.entries).find(t => t.name === p.target.name);
    const recordedLine = b => {
      if (b.type !== 'Light') return 'Not counted: the result form records light frames only';
      if (counts) {
        const n = counts[b.id];
        return `${plural(n, 'frame')} · ${duration(n * b.exposureS)}${x.result.outcome === 'asPlanned' ? ' (reported as planned)' : ''}`;
      }
      if (x.result?.outcome === 'notDone') return 'None: Not done';
      return due ? 'None recorded yet' : 'Not yet: the night has not started';
    };
    const notes = [
      ['Conditions and events', x.result?.environmentalNotes],
      ['Processing notes', x.result?.processingNotes],
    ].filter(([, v]) => v);
    return `<section class="logbook-result" aria-labelledby="logbook-result">
        <h2 id="logbook-result" tabindex="-1" data-focus-start class="logbook-state logbook-state-large">${mark(state)}<span>${esc(resultPhrase(x))}</span></h2>
        ${due ? `<p class="logbook-due">${mark('due')}Result not recorded</p>` : ''}
        <p class="logbook-figure">${esc(integrationLine(x))}</p>
        ${action === 'none' ? `<p class="workspace-copy">${esc(resultWhen(x))}</p>` : ''}
        ${x.result?.local && x.result.recordedAtUtc ? `<p class="logbook-caption">Result saved in this browser preview, ${esc(instantLabel(x.result.recordedAtUtc, p.zone))}.</p>` : ''}
        ${x.example ? '<p class="logbook-caption">Example night: fixture values, not measurements.</p>' : ''}
        ${action === 'none' ? '' : `<div class="workspace-actions"><button type="button" class="primary-button" data-result-entry="${esc(x.id)}">${action === 'record' ? 'Record result' : 'Edit result'}</button></div>`}
      </section>
      <section class="logbook-section" aria-labelledby="logbook-blocks">
        <h2 id="logbook-blocks">Planned and recorded</h2>
        <p class="workspace-copy">Light-frame integration and counts. The saved plan stays unchanged.</p>
        <ul class="logbook-blocks">${p.blocks.map(b => `<li>
          <span class="logbook-block-label">${esc(blockLabel(x, b))}</span>
          <dl class="logbook-pair">
            <div><dt>Planned</dt><dd>${b.planned} × ${esc(exposure(b.exposureS))}${b.type === 'Light' ? ` · ${duration(b.planned * b.exposureS)}` : ''}</dd></div>
            <div><dt>Recorded</dt><dd>${esc(recordedLine(b))}</dd></div>
          </dl></li>`).join('')}</ul>
        ${facts([
          ['Planned integration', duration(plannedSeconds(x))],
          ['Recorded integration', counts ? duration(recordedSeconds(x)) : 'none recorded'],
        ])}
      </section>
      <details class="logbook-section logbook-snapshot" aria-labelledby="logbook-snapshot">
        <summary id="logbook-snapshot"><span>Plan as saved</span><span class="logbook-caption">Read-only night, site, target and rig snapshot</span></summary>
        <p class="workspace-copy">Taken ${esc(instantLabel(p.takenAtUtc, p.zone))}. Changes to Library records or this result never replace the saved snapshot.</p>
        <h3>Night</h3>
        ${facts([
          ['Night span', `${instantLabel(p.night.startUtc, p.zone)} – ${instantLabel(p.night.endUtc, p.zone)}`],
          ['Times in', zoneCaption(p.night.startUtc, p.zone)],
          ['Darkness limit', degrees(p.darknessLimitDeg)],
          ['Minimum altitude', degrees(p.minAltitudeDeg)],
        ])}
        <h3>Site</h3>
        ${facts([
          ['Name', p.site.name],
          ['Position', `${degrees(p.site.latDeg, 3)}, ${degrees(p.site.lonDeg, 3)}`],
          ['Elevation', p.site.elevationM === null ? 'unknown' : `${p.site.elevationM} m`],
          ['Bortle', p.site.bortle === null ? 'unknown' : String(p.site.bortle)],
          ['SQM', p.site.sqm === null ? 'unknown' : `${p.site.sqm} mag/arcsec²`],
        ])}
        <h3>Target</h3>
        ${facts([['Name', p.target.name], ['RA / Dec (J2000)', p.target.raDec || 'unknown']])}
        <h3>Rig</h3>
        ${facts([
          ['Name', p.rig.name],
          ['Camera class', p.rig.cameraClass || 'unknown'],
          ['Sensitivity control', p.rig.sensitivity === 'iso' ? 'ISO' : p.rig.sensitivity === 'gain' ? 'Gain' : 'unknown'],
          ['Focal length', p.rig.focalLengthMm === null ? 'unknown' : `${p.rig.focalLengthMm} mm`],
          ['Focal ratio', p.rig.focalRatio === null ? 'unknown' : `f/${p.rig.focalRatio.toFixed(1)}`],
          ['Pixel pitch', p.rig.pixelUm === null ? 'unknown' : `${p.rig.pixelUm} µm`],
        ])}
      </details>
      <section class="logbook-section" aria-labelledby="logbook-notes">
        <h2 id="logbook-notes">Notes</h2>
        ${notes.length ? facts(notes) : '<p class="workspace-copy">None recorded.</p>'}
      </section>
      <section class="logbook-section" aria-labelledby="logbook-so-far">
        <h2 id="logbook-so-far">This target so far</h2>
        ${progress ? targetProgressView(progress, 3) : '<p class="workspace-copy">No recorded results for this target yet.</p>'}
      </section>
      <details class="logbook-section logbook-export">
        <summary>Export this entry</summary>
        <p class="workspace-copy">Text summary leaves out notes and site coordinates. Full JSON includes both; review it before sharing.</p>
        <p class="logbook-caption">Browser preview export, not a native session or application backup. Nothing is sent to a service.</p>
        <div class="workspace-actions">
          <button type="button" class="secondary-button" data-export-entry="${esc(x.id)}" data-export-format="text">Download text summary</button>
          <button type="button" class="secondary-button" data-export-entry="${esc(x.id)}" data-export-format="json">Download full JSON</button>
        </div>
      </details>
      <section class="logbook-section">
        <div class="workspace-actions"><button type="button" class="secondary-button logbook-destructive" data-delete-entry="${esc(x.id)}">${api.icon('trash')}<span>Delete entry</span></button></div>
        ${S.deleteError ? `<div class="workspace-error" role="alert"><p>${esc(S.deleteError)}</p>
          <div class="workspace-actions"><button type="button" class="secondary-button" data-retry-delete="${esc(x.id)}">Try again</button></div></div>` : ''}
      </section>`;
  }

  function targetProgressView(t, level) {
    const h = level, sub = level + 1;
    return `<section class="logbook-progress${hybrid ? ' logbook-progress-hybrid' : ''}">
      <div class="logbook-target-heading"><h${h}>${esc(t.name)}</h${h}><span class="logbook-figure">${duration(t.seconds)}</span></div>
      ${hybrid ? `<p class="logbook-caption">${plural(t.results, 'result')} · Last imaged ${esc(eveningLabel(t.lastNight))}</p>` : `<p class="workspace-copy">Recorded integration · ${plural(t.results, 'result')}</p>
      <p class="workspace-copy">Last imaged: ${esc(eveningLabel(t.lastNight))}</p>`}
      ${[...t.filters.values()].map(f => `<h${sub} class="logbook-filter-name"><span>${esc(f.name)}</span><span>${duration(f.seconds)}</span></h${sub}>
        <ul class="logbook-groups">${[...f.groups.values()].map(g => `<li>
          <span class="logbook-group-label">${esc([exposure(g.exposureS), sensitivityText(g.kind, g.value), ...(g.binning > 1 ? [`bin ${g.binning}×${g.binning}`] : []), g.rig].join(' · '))}</span>
          <span class="logbook-integration">${plural(g.frames, 'frame')} · ${duration(g.seconds)} · ${plural(g.nights.size, 'night')}</span>
          ${g.known ? '' : '<span class="logbook-caption">Sensitivity not recorded: kept separate, never combined with another group.</span>'}
        </li>`).join('')}</ul>`).join('')}
    </section>`;
  }

  function progressView() {
    const list = progressByTarget(S.entries);
    const intro = `<p class="workspace-copy" data-focus-start tabindex="-1">${hybrid ? 'Recorded integration by target and filter.' : 'Recorded integration by target and filter. Compatible capture settings stay grouped below each filter.'}</p>`;
    if (!list.length) {
      return `${intro}<div class="workspace-empty"><p>No results yet. Integration adds up here once you record how a saved plan went.</p></div>`;
    }
    const explanation = `Totals per filter follow the app's progress. Beneath each filter, frames are grouped only when exposure, sensitivity, binning and rig all match; "reported as planned" counts are your report, not counted files. This is integration time, not a measure of signal or image quality.`;
    return `${intro}${list.map(t => targetProgressView(t, 2)).join('')}
      ${hybrid ? `<details class="logbook-section logbook-progress-guide"><summary>How totals are grouped</summary><p class="workspace-copy">${explanation}</p></details>` : `<p class="logbook-note">${explanation}</p>`}`;
  }

  /* ----- Result editor ----- */

  function draftFrom(x) {
    const r = x.result;
    return {
      outcome: r?.outcome ?? '',
      // ResultsScreen._fill: a result's counts, else the plan's.
      counts: Object.fromEntries(lightBlocks(x).map(b => [b.id, String(
        !r ? b.planned : r.outcome === 'asPlanned' ? b.planned : r.outcome === 'partly' ? (r.counts[b.id] ?? 0) : 0)])),
      reason: r?.reason ?? '',
      environmentalNotes: r?.environmentalNotes ?? '',
      processingNotes: r?.processingNotes ?? '',
    };
  }

  const dirty = () => S.view === 'edit' && JSON.stringify(S.draft) !== S.initial;

  function openEditor(id, from) {
    const x = find(id);
    if (!x || resultAction(x) === 'none') return;
    S.id = id;
    S.from = from;
    S.draft = draftFrom(x);
    S.initial = JSON.stringify(S.draft);
    S.baseline = JSON.stringify(x.result);
    S.errors = {};
    S.saveError = '';
    S.saveMissing = false;
    show('edit');
  }

  function leaveEditor(message) {
    const focus = S.from === 'detail' ? '[data-result-entry]' : selector('data-result-entry', S.id);
    S.draft = null;
    show(S.from, { focus });
    if (message) api.announce(message);
  }

  async function cancelEdit() {
    if (dirty()) {
      const discard = await confirmDialog({ title: 'Discard your changes?', message: 'The result stays as it was saved.', confirm: 'Discard', cancel: 'Keep editing' });
      if (!discard || disposed || S.view !== 'edit') return;
    }
    leaveEditor('');
  }

  function editView() {
    const x = find(S.id);
    if (!x) return missingView();
    const d = S.draft, err = S.errors, p = x.plan, lights = lightBlocks(x);
    const fieldError = key => err[key] ? `<span class="field-error" id="logbook-error-${esc(key)}">${esc(err[key])}</span>` : '';
    const invalid = key => err[key] ? ` aria-invalid="true" aria-describedby="logbook-error-${esc(key)}"` : '';
    return `<form class="workspace-form logbook-form" data-result-form novalidate>
      <section class="logbook-editor-identity" aria-labelledby="logbook-review">
        <h2 id="logbook-review" tabindex="-1" data-focus-start>${esc(p.target.name)} · ${esc(eveningLabel(p.night.evening))}</h2>
        <details class="logbook-editor-plan"><summary>Plan context and light frames</summary>
          <p class="workspace-copy">${esc(p.site.name)} · ${esc(p.rig.name)}</p>
          <p class="logbook-caption">${esc(duration(plannedSeconds(x)))} planned integration · result only; saved plan unchanged.</p>
          <ul class="logbook-planned">${lights.map(b => `<li>${esc(blockLabel(x, b))} · ${b.planned} planned</li>`).join('')}</ul>
          ${lights.length ? '' : '<p class="workspace-copy">This plan has no light blocks.</p>'}
        </details>
      </section>
      <fieldset class="logbook-choices"${invalid('outcome')}><legend>Outcome</legend>
        ${OUTCOMES.map(([value, label]) => `<label class="logbook-choice"><input type="radio" name="logbook-outcome" value="${value}"${d.outcome === value ? ' checked' : ''}><span>${label}</span></label>`).join('')}
        ${fieldError('outcome')}
      </fieldset>
      ${d.outcome === 'asPlanned' ? '<p class="workspace-copy">Records every light block as fully taken. This is your report, not a frame count.</p>' : ''}
      ${d.outcome === 'partly' ? `<fieldset class="workspace-form"><legend>Light frames you took</legend>
        ${lights.map(b => `<label class="block-input">${esc(blockLabel(x, b))} · light frames
          <input type="text" inputmode="numeric" pattern="[0-9]*" autocomplete="off" data-count="${esc(b.id)}" value="${esc(d.counts[b.id])}"${invalid(`count-${b.id}`)}>
          <span class="field-hint">${b.planned} planned · a whole number, 0 or more</span>${fieldError(`count-${b.id}`)}</label>`).join('')}
      </fieldset>` : ''}
      ${d.outcome === 'notDone' ? `<fieldset class="logbook-choices"><legend>Why? (optional)</legend>
        ${REASONS.map(([value, label]) => `<label class="logbook-choice"><input type="radio" name="logbook-reason" value="${value}"${d.reason === value ? ' checked' : ''}><span>${label}</span></label>`).join('')}
      </fieldset>` : ''}
      <fieldset class="workspace-form"><legend>Notes (optional)</legend>
        <label class="block-input">Conditions and events<textarea rows="3" data-note="environmentalNotes"${invalid('environmentalNotes')}>${esc(d.environmentalNotes)}</textarea>${fieldError('environmentalNotes')}</label>
        <label class="block-input">Processing notes<textarea rows="3" data-note="processingNotes"${invalid('processingNotes')}>${esc(d.processingNotes)}</textarea>${fieldError('processingNotes')}</label>
      </fieldset>
      ${S.saveError ? `<div class="workspace-error" role="alert"><p>${esc(S.saveError)}</p>
        <div class="workspace-actions">${S.saveMissing ? '<button type="button" class="secondary-button" data-back-list>Back to Logbook</button>' : '<button type="button" class="secondary-button" data-retry-save>Try again</button>'}</div></div>` : ''}
      <div class="workspace-actions logbook-form-actions">
        <button type="button" class="secondary-button" data-cancel-edit>Cancel</button>
        <button type="submit" class="primary-button">Save result</button>
      </div>
    </form>`;
  }

  function validate(x) {
    const d = S.draft, errors = {};
    if (!d.outcome) errors.outcome = 'Choose how it went.';
    if (d.outcome === 'partly') {
      for (const b of lightBlocks(x)) {
        const text = String(d.counts[b.id] ?? '').trim();
        if (!/^\d+$/.test(text)) errors[`count-${b.id}`] = 'Enter the frames you took (0 or more).';
        else if (Number(text) > MAX_FRAMES) errors[`count-${b.id}`] = 'At most 100,000 frames.';
      }
    }
    for (const key of ['environmentalNotes', 'processingNotes']) {
      if (d[key].length > MAX_NOTE) errors[key] = `At most ${MAX_NOTE} characters in this preview.`;
    }
    return errors;
  }

  function saveResult() {
    const x = find(S.id);
    if (!x) return;
    S.errors = validate(x);
    const firstError = Object.keys(S.errors)[0];
    if (firstError) {
      S.saveError = '';
      render(firstError === 'outcome' ? '[name="logbook-outcome"]' : firstError.startsWith('count-')
        ? selector('data-count', firstError.slice(6)) : selector('data-note', firstError));
      api.announce('Check the highlighted fields.');
      return;
    }
    const d = S.draft;
    const result = {
      outcome: d.outcome,
      counts: d.outcome === 'partly' ? Object.fromEntries(lightBlocks(x).map(b => [b.id, Number(d.counts[b.id].trim())])) : {},
      reason: d.outcome === 'notDone' ? (d.reason || null) : null,
      environmentalNotes: d.environmentalNotes.trim() || null,
      processingNotes: d.processingNotes.trim() || null,
      recordedAtUtc: new Date().toISOString(),
      local: true,
    };
    let note;
    try {
      note = mutate(list => {
        const current = list.find(y => y.id === S.id);
        if (!current) throw new PreviewFailure('missing');
        // S4-DEF-08: a form opened on an entry that changed since writes nothing.
        if (JSON.stringify(current.result) !== S.baseline) throw new PreviewFailure('stale');
        return list.map(y => (y.id === S.id ? { ...y, result } : y));
      });
    } catch (error) {
      if (error.kind === 'missing') {
        load();
        S.saveMissing = true;
        S.saveError = 'This entry no longer exists, so nothing was saved.';
      } else if (error.kind === 'stale') {
        load();
        const fresh = find(S.id);
        S.draft = draftFrom(fresh);
        S.initial = JSON.stringify(S.draft);
        S.baseline = JSON.stringify(fresh.result);
        S.saveError = 'This entry changed in another tab since you opened the form. Nothing was saved; the form now shows the entry as it is.';
      } else {
        S.saveError = failureText(error, 'save the result');
      }
      render(S.saveMissing ? '[data-back-list]' : '[data-retry-save]');
      api.announce(S.saveError);
      return;
    }
    leaveEditor(`Result saved${note}.`);
  }

  /* ----- Delete and Undo ----- */

  async function deleteEntry(id, { confirmFirst = true } = {}) {
    const x = find(id);
    if (!x) return;
    if (confirmFirst) {
      const sure = await confirmDialog({
        title: 'Delete this entry?',
        message: `“${titleOf(x)}” and its result are deleted from this preview Logbook. Undo is offered right after.`,
        confirm: 'Delete',
        destructive: true,
      });
      if (!sure || disposed || S.view !== 'detail' || S.id !== id) return;
    }
    let removed = null, index = -1, note;
    try {
      note = mutate(list => {
        index = list.findIndex(y => y.id === id);
        removed = index < 0 ? null : list[index];
        return list.filter(y => y.id !== id);
      });
    } catch (error) {
      S.deleteError = failureText(error, 'delete the entry');
      render('[data-retry-delete]');
      api.announce(S.deleteError);
      return;
    }
    S.deleteError = '';
    // One Undo at a time, as a newer message replaces the older one.
    ui.undo = removed && { entry: removed, index, title: titleOf(removed) };
    ui.undoError = '';
    show('list', { focus: ui.undo ? '[data-undo]' : null });
    api.announce(`Entry deleted${note}.${ui.undo ? ' Undo is available.' : ''}`);
  }

  // Puts back exactly the deleted entry, by its id, at its earlier place; the
  // rest of the list, including later edits, stays as it is now.
  function undoDelete() {
    const u = ui.undo;
    if (!u) return;
    let note;
    try {
      note = mutate(list => (list.some(y => y.id === u.entry.id)
        ? list
        : [...list.slice(0, Math.min(u.index, list.length)), u.entry, ...list.slice(Math.min(u.index, list.length))]));
    } catch (error) {
      ui.undoError = failureText(error, 'restore the entry');
      renderResults();
      view.querySelector('[data-undo]')?.focus();
      api.announce(ui.undoError);
      return;
    }
    ui.undo = null;
    ui.undoError = '';
    renderResults();
    (view.querySelector(selector('data-open-entry', u.entry.id)) || view.querySelector('[data-search]'))?.focus();
    api.announce(`Entry restored${note}.`);
  }

  /* ----- Dialog ----- */

  function exportEntry(id, format) {
    const x = find(id);
    if (!x || !['json', 'text'].includes(format)) return;
    const p = x.plan, counts = recordedCounts(x);
    // EntryShareText's private-by-default boundary: no notes or coordinates
    // in the human-readable summary. The deliberately separate full file
    // contains the actual entry, without pretending to be manifest v2.
    const summary = [
      titleOf(x), '', `Night: ${eveningLabel(p.night.evening)} (${p.zone})`,
      `Site: ${p.site.name}`, `Rig: ${p.rig.name}`, `Result: ${resultPhrase(x)}`,
      integrationLine(x), ...lightBlocks(x).map(b => `  ${blockLabel(x, b)}: ${counts ? `${counts[b.id]} of ${b.planned}` : `${b.planned} planned`}`),
      '', 'Culmina browser preview · example data',
    ].join('\n');
    const body = format === 'json' ? JSON.stringify({ kind: 'culmina-session-preview', version: 1, entry: x }, null, 2) : summary;
    let url = null;
    try {
      url = URL.createObjectURL(new Blob([body], { type: format === 'json' ? 'application/json;charset=utf-8' : 'text/plain;charset=utf-8' }));
      const link = document.createElement('a');
      link.href = url;
      link.download = `culmina-preview-${x.id}.${format === 'json' ? 'json' : 'txt'}`;
      view.append(link);
      link.click();
      link.remove();
      api.announce(`${format === 'json' ? 'Full entry JSON' : 'Text summary'} download requested. The entry is unchanged.`);
    } catch {
      api.announce('Could not download this entry. Try the download again; the entry is unchanged.');
    } finally {
      if (url) setTimeout(() => URL.revokeObjectURL(url), 1000);
    }
  }

  function confirmDialog({ title, message, confirm, cancel = 'Cancel', destructive = false }) {
    return new Promise(resolve => {
      const dialog = document.createElement('dialog');
      dialog.className = 'logbook-dialog';
      dialog.setAttribute('aria-labelledby', 'logbook-dialog-title');
      dialog.setAttribute('aria-describedby', 'logbook-dialog-message');
      dialog.innerHTML = `<h2 id="logbook-dialog-title">${esc(title)}</h2><p id="logbook-dialog-message">${esc(message)}</p>
        <div class="workspace-actions logbook-dialog-actions">
          <button type="button" class="secondary-button" data-dialog="cancel">${esc(cancel)}</button>
          <button type="button" class="${destructive ? 'secondary-button logbook-destructive' : 'primary-button'}" data-dialog="ok">${esc(confirm)}</button>
        </div>`;
      const opener = document.activeElement;
      const finish = ok => {
        if (!dialogs.has(finish)) return;
        dialogs.delete(finish);
        if (dialog.open) dialog.close();
        dialog.remove();
        if (!ok && !disposed) opener?.focus?.();
        resolve(ok);
      };
      dialog.addEventListener('click', event => {
        const button = event.target.closest('[data-dialog]');
        if (button) finish(button.dataset.dialog === 'ok');
      });
      dialog.addEventListener('cancel', event => {
        event.preventDefault();
        finish(false);
      });
      dialogs.add(finish);
      view.append(dialog);
      dialog.showModal();
      dialog.querySelector('[data-dialog="cancel"]').focus();
    });
  }

  /* ----- Events ----- */

  async function onClick(event) {
    const el = event.target.closest('button');
    if (!el || !view.contains(el) || el.closest('dialog')) return;
    const data = el.dataset;
    if (data.openEntry) {
      S.deleteError = '';
      show('detail', { id: data.openEntry });
    } else if (data.exportEntry) {
      exportEntry(data.exportEntry, data.exportFormat);
    } else if (data.resultEntry) {
      openEditor(data.resultEntry, S.view === 'detail' ? 'detail' : 'list');
    } else if ('openProgress' in data) {
      show('progress');
    } else if ('backList' in data) {
      S.draft = null;
      show('list');
    } else if ('retryLoad' in data) {
      S.loadFailed = false;
      load();
      render('[data-search]');
      api.announce('Logbook loaded.');
    } else if ('clearFilters' in data || 'clearAll' in data) {
      ui.filter = emptyFilter();
      if ('clearAll' in data) ui.query = '';
      render('clearAll' in data ? '[data-search]' : '[data-filters] summary');
      rememberContext();
      api.announce('Filters cleared.');
    } else if ('undo' in data) {
      // Pressing Undo again after a failure is its Try again.
      if (ui.undoError) S.simulateFail = false;
      undoDelete();
    } else if ('dismissUndo' in data) {
      ui.undo = null;
      ui.undoError = '';
      renderResults();
      view.querySelector('[data-search]')?.focus();
    } else if (data.deleteEntry) {
      await deleteEntry(data.deleteEntry);
    } else if (data.retryDelete) {
      S.simulateFail = false;
      await deleteEntry(data.retryDelete, { confirmFirst: false });
    } else if ('retrySave' in data) {
      S.simulateFail = false;
      saveResult();
    } else if ('cancelEdit' in data) {
      await cancelEdit();
    } else if ('replaceStore' in data) {
      const sure = await confirmDialog({
        title: 'Replace the stored preview data?',
        message: 'The unreadable Logbook preview payload is overwritten with the entries shown now. Nothing else in this browser changes.',
        confirm: 'Replace',
        destructive: true,
      });
      if (!sure || disposed) return;
      try {
        writeStore(storage, S.entries);
        S.status = 'stored';
        render('[data-search]');
        api.announce('Stored preview data replaced.');
      } catch {
        api.announce('Browser storage refused the write; the stored data is unchanged.');
      }
    }
  }

  function onInput(event) {
    const el = event.target;
    if (el.matches('[data-search]')) {
      ui.query = el.value;
      renderResults();
      rememberContext();
    } else if (S.view === 'edit' && S.draft) {
      let key = null;
      if (el.dataset.count) {
        S.draft.counts[el.dataset.count] = el.value;
        key = `count-${el.dataset.count}`;
      } else if (el.dataset.note) {
        S.draft[el.dataset.note] = el.value;
        key = el.dataset.note;
      }
      if (key && S.errors[key]) {
        delete S.errors[key];
        el.removeAttribute('aria-invalid');
        el.removeAttribute('aria-describedby');
        el.parentElement.querySelector(`#${CSS.escape(`logbook-error-${key}`)}`)?.remove();
      }
    }
  }

  function onChange(event) {
    const el = event.target;
    if (el.matches('[data-filter-state]')) {
      const states = new Set(ui.filter.states);
      if (el.checked) states.add(el.value);
      else states.delete(el.value);
      ui.filter.states = STATE_FILTERS.map(([value]) => value).filter(value => states.has(value));
      renderResults();
      rememberContext();
    } else if (el.dataset.filter) {
      ui.filter[el.dataset.filter] = el.value;
      renderResults();
      rememberContext();
    } else if (el.name === 'logbook-outcome' && S.draft) {
      S.draft.outcome = el.value;
      delete S.errors.outcome;
      const scroll = scroller?.scrollTop;
      render(`[name="logbook-outcome"][value="${el.value}"]`);
      if (scroller) scroller.scrollTop = scroll;
    } else if (el.name === 'logbook-reason' && S.draft) {
      S.draft.reason = el.value;
    }
  }

  function onSubmit(event) {
    if (!event.target.matches('[data-result-form]')) return;
    event.preventDefault();
    saveResult();
  }

  // <details> toggle does not bubble.
  function onToggle(event) {
    if (event.target.matches?.('[data-filters]')) {
      ui.filtersOpen = event.target.open;
      rememberContext();
    }
  }

  // Another tab changed this module's key: read it again, unless a result is
  // being edited (its Save then checks the entry for changes first).
  function onStorage(event) {
    if (event.key !== STORAGE_KEY && event.key !== null) return;
    if (scenario === 'empty' || S.view === 'edit') return;
    load();
    render();
    api.announce('Logbook preview updated from another tab.');
  }

  function onBeforeUnload(event) {
    if (dirty()) event.preventDefault();
  }

  root.addEventListener('click', onClick);
  root.addEventListener('input', onInput);
  root.addEventListener('change', onChange);
  root.addEventListener('submit', onSubmit);
  root.addEventListener('toggle', onToggle, true);
  window.addEventListener('storage', onStorage);
  window.addEventListener('beforeunload', onBeforeUnload);
  window.addEventListener('pagehide', rememberContext);
  scroller?.addEventListener('scroll', rememberContext, { passive: true });

  load();
  render();
  // Restore the list before opening a remembered detail: show() records the
  // list's return position, and must not replace it with the fresh page's zero.
  if (scroller) scroller.scrollTop = ui.listScroll;
  if (remembered?.view === 'detail' && find(remembered.id)) show('detail', { id: remembered.id });
  else if (remembered?.view === 'progress') show('progress');
  if(api.entry&&find(api.entry)){
    if(api.editResult&&resultAction(find(api.entry))!=='none')openEditor(api.entry,'detail');
    else show('detail',{id:api.entry});
  }

  return function cleanup() {
    rememberContext();
    disposed = true;
    for (const finish of [...dialogs]) finish(false);
    root.removeEventListener('click', onClick);
    root.removeEventListener('input', onInput);
    root.removeEventListener('change', onChange);
    root.removeEventListener('submit', onSubmit);
    root.removeEventListener('toggle', onToggle, true);
    window.removeEventListener('storage', onStorage);
    window.removeEventListener('beforeunload', onBeforeUnload);
    window.removeEventListener('pagehide', rememberContext);
    scroller?.removeEventListener('scroll', rememberContext);
  };
}
