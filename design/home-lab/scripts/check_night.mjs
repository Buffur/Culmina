import {weatherSlots} from '../night-model.js';
// Node checks for the Home lab browser fixtures (night-model.js, plan-model.js).
// Prototype-only: these test fixture invariants, not Culmina's production astronomy.
// Run: node --test design/home-lab/scripts/check_night.mjs
// Note: the model files are ES modules without a package.json "type"; this needs a
// Node version that detects module syntax (22.7+), otherwise add "type":"module" nearby.
import test from 'node:test';
import assert from 'node:assert/strict';
import {
  fixtureNight, fixtureDates, fixtureNow, retrievedAt, dayMs, nextDate,
  intersect, subtractIntervals, totalTime, cursorFacts, resetCursor,
  weatherForNight, weatherHours, localInstant, timeLabel, instantLabel, hoursLabel
} from '../night-model.js';
import {
  defaultPlan, defaultBlock, validPlan, saveProblem, estimate, savePlanRecord,
  readSavedPlan, readPlanArchive, readNavigationDraft, writeNavigationDraft,
  adoptViewedNight, planStorageKey, navigationDraftKey
} from '../plan-model.js';

const H = 3600000, MIN = 60000;
const D0 = '2026-10-19';
const DST = '2026-10-24'; // 24-hour UTC night in Europe/Kyiv (clocks go back 2026-10-25)

function deepFreeze(o) {
  if (o && typeof o === 'object' && !Object.isFrozen(o)) {
    Object.freeze(o);
    Object.values(o).forEach(deepFreeze);
  }
  return o;
}
const frozenNight = (date = D0, scenario = 'ready') => deepFreeze(fixtureNight(date, scenario));
function memoryStorage(initial = {}) {
  const m = new Map(Object.entries(initial));
  return {
    getItem: k => (m.has(k) ? m.get(k) : null),
    setItem: (k, v) => { m.set(k, String(v)); },
    raw: k => m.get(k)
  };
}
const at = (time, date = D0) => localInstant(date, time);

// ---------- interval arithmetic ----------
test('intersect: overlap, touching and disjoint spans', () => {
  assert.deepEqual(intersect({ start: 0, end: 10 }, { start: 5, end: 20 }), { start: 5, end: 10 });
  assert.deepEqual(intersect({ start: 0, end: 10 }, { start: 2, end: 4 }), { start: 2, end: 4 });
  assert.equal(intersect({ start: 0, end: 10 }, { start: 10, end: 20 }), null, 'touching spans share no time');
  assert.equal(intersect({ start: 0, end: 10 }, { start: 11, end: 20 }), null);
});

test('subtractIntervals: none, all, split, edges, unsorted/overlapping cover', () => {
  const span = { start: 0, end: 100 };
  assert.deepEqual(subtractIntervals(span, []), [span], 'nothing covered keeps the span');
  assert.deepEqual(subtractIntervals(span, [{ start: 200, end: 300 }]), [span], 'unrelated cover keeps the span');
  assert.deepEqual(subtractIntervals(span, [{ start: -10, end: 110 }]), [], 'full cover leaves nothing');
  assert.deepEqual(subtractIntervals(span, [{ start: 0, end: 100 }]), [], 'exact cover leaves nothing');
  assert.deepEqual(subtractIntervals(span, [{ start: 40, end: 60 }]), [{ start: 0, end: 40 }, { start: 60, end: 100 }]);
  assert.deepEqual(subtractIntervals(span, [{ start: 0, end: 30 }]), [{ start: 30, end: 100 }]);
  assert.deepEqual(subtractIntervals(span, [{ start: 70, end: 100 }]), [{ start: 0, end: 70 }]);
  assert.deepEqual(
    subtractIntervals(span, [{ start: 60, end: 80 }, { start: 10, end: 30 }, { start: 25, end: 40 }]),
    [{ start: 0, end: 10 }, { start: 40, end: 60 }, { start: 80, end: 100 }],
    'unsorted and overlapping covers'
  );
});

test('subtractIntervals: conserves time and does not mutate inputs', () => {
  const span = deepFreeze({ start: 0, end: 100 });
  const covered = deepFreeze([{ start: 50, end: 90 }, { start: -5, end: 20 }, { start: 15, end: 25 }]);
  const rest = subtractIntervals(span, covered);
  const removed = covered.map(c => intersect(span, c)).filter(Boolean);
  const merged = subtractIntervals(span, rest); // what was covered inside the span
  assert.equal(totalTime(rest) + totalTime(merged), 100);
  assert.ok(removed.length > 0);
  for (const r of rest) for (const c of covered) assert.equal(intersect(r, c), null, 'remainder never overlaps cover');
});

// ---------- moon-free dark classification ----------
test('Moon-free: absence of Moon in the dark is distinct from no dark time', () => {
  const noDark = fixtureNight(D0, 'no-dark');
  assert.deepEqual(noDark.dark, []);
  assert.deepEqual(noDark.moonFree, []);
  assert.equal(noDark.classification, 'No dark time');

  const moonAll = fixtureNight(D0, 'moon-all');
  assert.deepEqual(moonAll.moonFree, []);
  assert.equal(moonAll.classification, 'No moon-free dark', 'dark exists but Moon covers it');

  const below = fixtureNight(D0, 'moon-below');
  assert.deepEqual(below.moonUp, [], 'known absence of Moon above horizon');
  assert.deepEqual(below.moonFree, below.dark);
  assert.equal(below.classification, 'Moon-free all dark time');
});

test('Moon-free: mixed night splits dark time and conserves it', () => {
  const n = fixtureNight(D0, 'mixed');
  assert.equal(n.classification, 'Split moon-free intervals');
  assert.deepEqual(n.moonFree, [
    { start: at('21:15'), end: at('23:00') },
    { start: at('02:00', nextDate(D0)), end: at('04:45', nextDate(D0)) }
  ]);
  assert.equal(totalTime(n.moonFree), 4.5 * H);
  for (const f of n.moonFree) {
    assert.ok(n.dark.some(d => f.start >= d.start && f.end <= d.end), 'moon-free lies inside dark');
    for (const m of n.moonUp) assert.equal(intersect(f, m), null);
  }
});

test('Moon-free: default night is free in the morning; late-waning night only in the evening', () => {
  const n = fixtureNight(D0);
  assert.equal(n.classification, 'Moon-free in the morning');
  assert.deepEqual(n.moonFree, [{ start: at('00:30', nextDate(D0)), end: at('04:45', nextDate(D0)) }]);
  assert.equal(hoursLabel(totalTime(n.moonFree)), '4 h 15 min');

  const late = fixtureNight('2026-10-31');
  assert.equal(late.classification, 'Moon-free in the evening');
  assert.equal(late.moonFree[0].start, late.dark[0].start);
  assert.equal(totalTime(late.moonFree), 2.25 * H);
});

test('fixtureNight: unknown date falls back to the first fixture date; no-dark has no dark or target window', () => {
  assert.equal(fixtureNight('1999-01-01').date, fixtureDates[0]);
  const n = fixtureNight(D0, 'no-dark');
  assert.deepEqual(n.targetWindows, []);
  assert.equal(n.skySegments.some(s => s.sky === 'Dark'), false);
  assert.equal(n.twilight.find(t => t.label === 'Astronomical dusk').at, null, 'unknown twilight stays null');
});

// ---------- 24-hour UTC DST night ----------
test('DST night keeps the project’s 24-hour UTC SessionNight and 8.5 h elapsed dark time', () => {
  const n = fixtureNight(DST);
  assert.equal(n.end - n.start, 24 * H);
  assert.equal(totalTime(n.dark), 8.5 * H, 'wall clock 21:15-04:45 is 7.5 h but one hour is repeated');
  assert.equal(hoursLabel(totalTime(n.dark)), '8 h 30 min');
  assert.equal(fixtureNight('2026-10-23').end - fixtureNight('2026-10-23').start, 24 * H);
});

test('DST night: readouts carry the correct local time and zone offset', () => {
  const n = fixtureNight(DST);
  assert.equal(timeLabel(n.dark[0].start), '21:15');
  assert.equal(timeLabel(n.dark[0].end), '04:45');
  assert.match(instantLabel(n.dark[0].start), /GMT\+3/);
  assert.match(instantLabel(n.dark[0].end), /GMT\+2/);
  assert.equal(timeLabel(n.end), '12:00');
  assert.equal(timeLabel(n.sunrise), '07:00');
});

test('DST night: cursor readout reports elapsed remaining time and the offset at the end instant', () => {
  const n = frozenNight(DST);
  const f = cursorFacts(n, n.dark[0].start);
  assert.match(f.detail, /^8 h 30 min remaining/);
  assert.match(f.detail, /until .*GMT\+2/);
});

test('DST night: events before the fall-back retain their pre-transition offset', () => {
  // On 2026-10-25 local 00:30 is still EEST (+03:00); the transition happens at 04:00 local.
  assert.equal(timeLabel(localInstant('2026-10-25', '00:30')), '00:30');
  const n = fixtureNight(DST);
  assert.equal(timeLabel(n.targetWindows[0].start), '00:30');
});

// ---------- cursor facts ----------
test('cursor before darkness: counts down to darkness, not remaining', () => {
  const n = frozenNight();
  const f = cursorFacts(n, at('20:00'));
  assert.match(f.detail, /^Darkness in 1 h 15 min · from /);
  assert.doesNotMatch(f.detail, /remaining/);
  assert.equal(f.state, 'Astronomical twilight · Moon above horizon');
  assert.equal(cursorFacts(n, at('21:15') - MIN).detail.startsWith('Darkness in 1 min'), true);
});

test('cursor inside dark: reports remaining time until the end of the interval', () => {
  const n = frozenNight();
  const moonUpDark = cursorFacts(n, at('22:00'));
  assert.equal(moonUpDark.state, 'Dark · Moon above horizon');
  assert.match(moonUpDark.detail, /^6 h 45 min remaining/);
  const free = cursorFacts(n, at('01:00', nextDate(D0)));
  assert.equal(free.state, 'Moon-free dark');
  assert.match(free.detail, /^3 h 45 min remaining/);
  assert.equal(free.moon, 'Moon below horizon');
});

test('cursor boundaries: start inclusive, end exclusive (dark and moon-free)', () => {
  const n = frozenNight();
  const next = nextDate(D0);
  assert.match(cursorFacts(n, at('21:15')).detail, /^7 h 30 min remaining/);
  assert.match(cursorFacts(n, at('21:15') - 1).detail, /^Darkness in/);

  assert.equal(cursorFacts(n, at('00:30', next)).state, 'Moon-free dark', 'Moon-free starts at moonset');
  assert.equal(cursorFacts(n, at('00:30', next) - 1).state, 'Dark · Moon above horizon');

  const end = cursorFacts(n, at('04:45', next));
  assert.equal(end.state, 'Astronomical twilight · Moon below horizon');
  assert.equal(end.detail, 'Dark time has ended for this night.');
  assert.match(cursorFacts(n, at('04:45', next) - MIN).detail, /^1 min remaining/);
});

test('cursor boundaries on a mixed-Moon night', () => {
  const n = frozenNight(D0, 'mixed');
  const next = nextDate(D0);
  assert.match(cursorFacts(n, at('22:00')).detail, /^6 h 45 min remaining/);
  assert.match(cursorFacts(n, at('22:00')).detail, /Moon-free for another 1 h/);
  assert.equal(cursorFacts(n, at('23:00')).state, 'Dark · Moon above horizon', 'Moon interval starts inclusive');
  assert.equal(cursorFacts(n, at('02:00', next)).state, 'Moon-free dark', 'Moon interval ends exclusive');
});

test('cursor is clamped to the viewed night and does not mutate it', () => {
  const n = frozenNight();
  assert.equal(cursorFacts(n, n.start - 5 * H).instant, n.start);
  assert.equal(cursorFacts(n, n.end + 5 * H).instant, n.end-5*MIN);
  assert.equal(cursorFacts(n, n.start - 5 * H).state.startsWith('Daylight'), true);
});

test('cursor: no-dark and Moon-below/Moon-all nights', () => {
  const noDark = frozenNight(D0, 'no-dark');
  const f = cursorFacts(noDark, at('01:00', nextDate(D0)));
  assert.match(f.detail, /^No dark time/);
  assert.doesNotMatch(f.state, /^Dark|Moon-free dark/);

  const below = frozenNight(D0, 'moon-below');
  const b = cursorFacts(below, at('22:00'));
  assert.equal(b.state, 'Moon-free dark');
  assert.match(b.detail, /^6 h 45 min remaining/);
  assert.doesNotMatch(b.detail, /Moon (sets|rises)/);

  const all = frozenNight(D0, 'moon-all');
  const a = cursorFacts(all, at('22:00'));
  assert.equal(a.state, 'Dark · Moon above horizon');
  assert.match(a.detail, /^6 h 45 min remaining/);
});

test('cursor: a Moon interval clipped at the night boundary is not reported as a Moon set', () => {
  // Moon is above the horizon for the whole viewed window; nothing in the data says it sets at the 12:00 window edge.
  const f = cursorFacts(frozenNight(D0, 'moon-all'), at('22:00'));
  assert.doesNotMatch(f.detail, /Moon sets at/);
});

// ---------- Now reset ----------
test('Now reset applies only inside the viewed night', () => {
  const n = fixtureNight(D0);
  assert.deepEqual(resetCursor(n, fixtureNow), { instant: fixtureNow, label: 'Now' });
  assert.deepEqual(resetCursor(n, n.start), { instant: n.start, label: 'Now' });
  assert.deepEqual(resetCursor(n, n.end), { instant: n.start, label: 'Night start' }, 'end is exclusive');
  assert.deepEqual(resetCursor(n, n.start - 1), { instant: n.start, label: 'Night start' });

  const other = fixtureNight(nextDate(D0));
  assert.equal(fixtureNow >= other.start && fixtureNow < other.end, false, 'precondition: now is outside the next night');
  assert.deepEqual(resetCursor(other, fixtureNow), { instant: other.start, label: 'Night start' });
  assert.equal(resetCursor(fixtureNight(D0, 'no-dark'), fixtureNow).label, 'Now', 'dark time is irrelevant to Now');
});

// ---------- weather ----------
test('weather: coverage and cloud ranges use dark-span hourly instants', () => {
  const n = frozenNight();
  const w = weatherForNight(n, 'ready');
  assert.equal(w.status, 'Full dark-time coverage');
  assert.equal(w.coveredSamples,7);assert.equal(w.sampleCount,7);
  assert.equal(w.partial, false);
  assert.equal(w.cloud,31); // Mean of the seven known instantaneous samples, not preceding-hour interpolation.
  assert.ok(w.cloudMin <= w.cloud && w.cloud <= w.cloudMax);
});

test('weather: missing hours inside the dark are gaps, not zero cloud', () => {
  const n = frozenNight();
  const w = weatherForNight(n, 'partial');
  assert.equal(w.status, 'Partial dark-time coverage');
  assert.equal(w.partial, true);
  assert.equal(w.darkMs, 7.5 * H);
  assert.equal(w.coveredSamples,5,'two missing hourly instants stay unavailable');assert.equal(w.sampleCount,7);
  assert.equal(w.cloud, 27, 'mean over known hours only (zero-filling would give 19)');
  const gaps = w.hours.filter(h => h.cloud === null);
  assert.equal(gaps.length, 2);
  for (const g of gaps) assert.equal(g.temp, null);
  assert.ok(w.tempMin !== 0 && w.tempMin !== null);
});

test('weather: forecast that ends mid-night is partial; fully out of range is unavailable, not zero', () => {
  const lastHour = weatherHours('ready').at(-1).end;
  const mid = weatherForNight(frozenNight('2026-10-21'), 'ready');
  assert.equal(mid.status, 'Partial dark-time coverage');
  assert.equal(mid.coveredSamples,4);assert.equal(mid.sampleCount,7);
  assert.ok(mid.coveredSamples < mid.sampleCount);
  assert.notEqual(mid.cloud, null);

  const out = weatherForNight(frozenNight('2026-10-22'), 'ready');
  assert.equal(out.status, 'Forecast unavailable');
  assert.equal(out.unavailable, true);
  assert.equal(out.coveredSamples,0);
  for (const key of ['cloud', 'cloudMin', 'cloudMax', 'tempMin', 'tempMax', 'dewMin']) {
    assert.equal(out[key], null, key + ' stays unknown, never 0');
  }
  assert.deepEqual(out.hours, []);
});

test('weather: no dark time, loading, error and no-site never fabricate values', () => {
  const noDark = weatherForNight(frozenNight(D0, 'no-dark'), 'ready');
  assert.equal(noDark.status, 'No dark time');
  assert.equal(noDark.cloud, null);
  const n = frozenNight();
  assert.equal(weatherForNight(n, 'loading').status, 'Loading');
  assert.equal(weatherForNight(n, 'error').status, 'Couldn’t load forecast');
  for (const s of ['loading', 'error', 'unknown', 'no-site']) {
    const w = weatherForNight(n, s);
    assert.equal(w.cloud, null);
    assert.equal(w.unavailable, true);
    assert.deepEqual(w.hours, []);
  }
});

test('weather: snapshot age (stale/offline flag) is independent of forecast lead time', () => {
  const near = weatherForNight(frozenNight(D0), 'stale');
  assert.equal(near.stale, true);
  assert.equal(near.status, 'Stale snapshot');
  assert.equal(near.leadDays, 0, 'a night that has started is never negative lead');
  assert.equal(near.ageHours,18);assert.equal(retrievedAt-near.retrievedAt,17*H);

  const far = weatherForNight(frozenNight('2026-10-21'), 'ready');
  assert.equal(far.stale, false);
  assert.equal(far.leadDays, 2);
  assert.equal(weatherForNight(frozenNight('2026-10-22'), 'ready').leadDays, 3);
  assert.equal(weatherForNight(frozenNight(D0), 'offline').status, 'Offline · cached snapshot');
  assert.equal(weatherForNight(frozenNight(D0), 'offline').offline, true);
  assert.ok(weatherForNight(frozenNight('2026-10-22'), 'ready').leadDays * dayMs >= 0);
});

// ---------- plans ----------
test('save eligibility needs only site, target and rig (empty plan can be saved)', () => {
  const empty = deepFreeze({ ...defaultPlan(), blocks: [] });
  assert.equal(validPlan(empty), true);
  assert.equal(saveProblem(empty), null);
  assert.equal(estimate(empty).missing, 'Needs a block', 'estimate still says there is nothing to estimate');
  assert.equal(estimate(empty).integration, 0);

  assert.equal(saveProblem({ ...empty, site: '' }), 'Choose an observing site.');
  assert.equal(saveProblem({ ...empty, target: '' }), 'Choose a target.');
  assert.equal(saveProblem({ ...empty, rig: '' }), 'Choose a rig.');
});

test('canonical save record archives the prior original when a copy is saved', () => {
  const storage = memoryStorage();
  const original = deepFreeze(defaultPlan());
  savePlanRecord(storage, original);
  assert.deepEqual(readSavedPlan(storage), original);
  assert.deepEqual(readPlanArchive(storage), [], 'nothing to archive on first save');

  const copy = deepFreeze({ ...structuredClone(original), id: 'copy-1', copyOfId: 'example-original', night: '2026-10-20' });
  savePlanRecord(storage, copy);
  assert.deepEqual(readSavedPlan(storage), copy);
  assert.deepEqual(readPlanArchive(storage), [original], 'archived original is byte-for-byte the saved one');

  savePlanRecord(storage, { ...copy, night: '2026-10-21' });
  assert.equal(readPlanArchive(storage).length, 1, 're-saving the same plan id does not duplicate the archive');

  const copy2 = { ...structuredClone(original), id: 'copy-2', night: '2026-10-22' };
  savePlanRecord(storage, copy2);
  const archive = readPlanArchive(storage);
  assert.equal(archive.length, 2);
  assert.deepEqual(archive[0], original, 'the original is kept once');
  assert.equal(archive[1].id, 'copy-1');
});

test('savePlanRecord rejects an invalid plan and leaves storage untouched', () => {
  const storage = memoryStorage();
  const original = defaultPlan();
  savePlanRecord(storage, original);
  const before = storage.raw(planStorageKey);
  assert.throws(() => savePlanRecord(storage, { ...original, target: 'NGC0000' }), /Invalid plan/);
  assert.equal(storage.raw(planStorageKey), before);
});

function savedState(plan = defaultPlan()) {
  return { plan, savedSnapshot: JSON.stringify(plan), hasSaved: true };
}

test('adopting a night from a clean saved plan creates a new draft copy, original untouched', () => {
  const state = deepFreeze(savedState());
  const r = adoptViewedNight(state, '2026-10-21');
  assert.equal(r.status, 'adopted');
  assert.equal(r.state.plan.night, '2026-10-21');
  assert.equal(r.state.hasSaved, false, 'the copy is a draft until saved');
  assert.notEqual(r.state.plan.id, undefined);
  assert.equal(r.state.plan.copyOfId, 'example-original');
  assert.deepEqual(r.source, defaultPlan(), 'source is the saved original');
  assert.equal(state.plan.night, D0);
  assert.match(r.message, /saved original is unchanged/);
  assert.equal(validPlan(r.state.plan), true);
  assert.notEqual(r.state.plan, state.plan);
  assert.notEqual(r.state.plan.blocks, state.plan.blocks, 'blocks are not shared with the original');
});

test('copy of a saved plan that already has an id records that id as its origin', () => {
  const plan = { ...defaultPlan(), id: 'saved-1' };
  const r = adoptViewedNight(deepFreeze(savedState(plan)), '2026-10-20');
  assert.equal(r.state.plan.copyOfId, 'saved-1');
  assert.notEqual(r.state.plan.id, 'saved-1');
});

test('dirty saved plan needs a choice; cancel changes nothing', () => {
  const saved = defaultPlan();
  const dirty = { ...structuredClone(saved), blocks: [{ ...defaultBlock(), count: 7 }] };
  const state = deepFreeze({ plan: dirty, savedSnapshot: JSON.stringify(saved), hasSaved: true });
  assert.deepEqual(adoptViewedNight(state, '2026-10-20'), { status: 'needs-choice' });
  assert.deepEqual(adoptViewedNight(state, '2026-10-20', 'continue'), { status: 'needs-choice' });
  assert.deepEqual(adoptViewedNight(state, '2026-10-20', 'cancel'), { status: 'cancelled' });
});

test('dirty saved plan + Discard adopts the saved source, not the edits; Save adopts the edits', () => {
  const saved = defaultPlan();
  const dirty = { ...structuredClone(saved), blocks: [{ ...defaultBlock(), count: 7 }] };
  const state = deepFreeze({ plan: dirty, savedSnapshot: JSON.stringify(saved), hasSaved: true });

  const discard = adoptViewedNight(state, '2026-10-20', 'discard');
  assert.equal(discard.status, 'adopted');
  assert.deepEqual(discard.source, saved);
  assert.equal(discard.state.plan.blocks[0].count, 120);
  assert.equal(discard.state.plan.night, '2026-10-20');
  assert.equal(discard.state.hasSaved, false);

  const keep = adoptViewedNight(state, '2026-10-20', 'save');
  assert.equal(keep.status, 'adopted');
  assert.equal(keep.state.plan.blocks[0].count, 7);
  assert.equal(keep.state.plan.night, '2026-10-20');
});

test('Discard with an unreadable saved snapshot is an error, not a silent adoption', () => {
  const state = deepFreeze({ plan: { ...defaultPlan(), blocks: [] }, savedSnapshot: '{not json', hasSaved: true });
  assert.deepEqual(adoptViewedNight(state, '2026-10-20', 'discard'), { status: 'error', reason: 'Saved source is unavailable.' });
});

test('adopt then save archives the original and keeps copy provenance', () => {
  const storage = memoryStorage();
  const original = defaultPlan();
  savePlanRecord(storage, original);
  const r = adoptViewedNight(savedState(original), '2026-10-22');
  savePlanRecord(storage, r.state.plan);
  assert.equal(readSavedPlan(storage).night, '2026-10-22');
  assert.equal(readSavedPlan(storage).copyOfId, 'example-original');
  assert.deepEqual(readPlanArchive(storage), [original]);
});

test('unsaved draft adopts the night in place: edits kept, no copy, still not saved', () => {
  const draft = { ...defaultPlan(), blocks: [{ ...defaultBlock(), count: 33 }] };
  const state = deepFreeze({ plan: draft, savedSnapshot: '', hasSaved: false });
  const r = adoptViewedNight(state, '2026-10-23');
  assert.equal(r.status, 'adopted');
  assert.equal(r.state.plan.night, '2026-10-23');
  assert.equal(r.state.plan.blocks[0].count, 33);
  assert.equal(r.state.plan.id, undefined);
  assert.equal(r.state.plan.copyOfId, undefined);
  assert.equal(r.state.hasSaved, false);
  assert.equal(r.state.savedSnapshot, '');
  assert.match(r.message, /Not saved/);
  assert.equal(state.plan.night, D0, 'input is untouched');
});

test('adopting a night with no example data is refused', () => {
  const state = deepFreeze(savedState());
  for (const date of ['2026-11-02', '2025-01-01', 'tomorrow']) {
    assert.deepEqual(adoptViewedNight(state, date), { status: 'error', reason: 'This date has no example night data.' });
  }
});

// ---------- stored navigation snapshot / fallback ----------
test('navigation snapshot round-trips a valid draft', () => {
  const storage = memoryStorage();
  const state = { plan: defaultPlan(), savedSnapshot: '', hasSaved: false };
  writeNavigationDraft(storage, state);
  assert.deepEqual(readNavigationDraft(storage), state);
});

test('invalid navigation snapshots fall back to null', () => {
  const good = { plan: defaultPlan(), savedSnapshot: '', hasSaved: false };
  const cases = {
    missing: undefined,
    notJson: '{oops',
    jsonNull: 'null',
    badTarget: JSON.stringify({ ...good, plan: { ...good.plan, target: 'NGC0000' } }),
    badNight: JSON.stringify({ ...good, plan: { ...good.plan, night: '2030-01-01' } }),
    duplicateBlockIds: JSON.stringify({ ...good, plan: { ...good.plan, blocks: [defaultBlock('a'), defaultBlock('a')] } }),
    badBlock: JSON.stringify({ ...good, plan: { ...good.plan, blocks: [{ ...defaultBlock(), exposure: 'abc' }] } }),
    snapshotNotString: JSON.stringify({ ...good, savedSnapshot: {} }),
    hasSavedNotBoolean: JSON.stringify({ ...good, hasSaved: 'yes' })
  };
  for (const [name, value] of Object.entries(cases)) {
    const storage = memoryStorage(value === undefined ? {} : { [navigationDraftKey]: value });
    assert.equal(readNavigationDraft(storage), null, name);
  }
  const throwing = { getItem() { throw new Error('storage blocked'); } };
  assert.equal(readNavigationDraft(throwing), null);
  assert.equal(readSavedPlan(throwing), null);
});

test('writeNavigationDraft refuses an invalid plan and writes nothing', () => {
  const storage = memoryStorage();
  assert.throws(() => writeNavigationDraft(storage, { plan: { ...defaultPlan(), rig: 'telescope' }, savedSnapshot: '', hasSaved: false }), /Invalid plan draft/);
  assert.equal(storage.raw(navigationDraftKey), undefined);
});

test('saved plan reader accepts the legacy bare plan and the v2 record, rejects invalid data', () => {
  const plan = defaultPlan();
  assert.deepEqual(readSavedPlan(memoryStorage({ [planStorageKey]: JSON.stringify(plan) })), plan);
  assert.deepEqual(readSavedPlan(memoryStorage({ [planStorageKey]: JSON.stringify({ kind: 'planning-lab-v2', active: plan, archive: [] }) })), plan);
  assert.equal(readSavedPlan(memoryStorage({ [planStorageKey]: JSON.stringify({ ...plan, site: 'Mars' }) })), null);
  assert.equal(readSavedPlan(memoryStorage()), null);
  const archive = readPlanArchive(memoryStorage({ [planStorageKey]: JSON.stringify({ kind: 'planning-lab-v2', active: plan, archive: [plan, { ...plan, target: 'bad' }] }) }));
  assert.deepEqual(archive, [plan], 'invalid archive entries are dropped');
});


test('all example dates retain 24-hour UTC windows and a contiguous sky-state axis',()=>{
 for(let i=0;i<14;i++){
  const date=new Date(Date.UTC(2026,9,19+i)).toISOString().slice(0,10);
  for(const scenario of ['ready','no-dark','polar-dark','moon-middle']){
   const n=fixtureNight(date,scenario);assert.equal(n.end-n.start,dayMs);
   assert.equal(n.skySegments[0].start,n.start);assert.equal(n.skySegments.at(-1).end,n.end);
   n.skySegments.forEach((segment,index)=>{assert.ok(segment.end>segment.start);if(index)assert.equal(segment.start,n.skySegments[index-1].end);});
  }
 }
});
test('middle-only moon-free interval and polar darkness are distinct states',()=>{
 const middle=fixtureNight('2026-10-19','moon-middle');assert.equal(middle.classification,'Moon-free in the middle of dark time');assert.equal(totalTime(middle.moonFree),3*H);
 const polar=fixtureNight('2026-10-19','polar-dark');assert.equal(totalTime(polar.dark),24*H);assert.ok(polar.twilight.every(x=>x.at===null));
});

test('partial forecast retains missing trailing hourly slots on the dark-time axis',()=>{
 const n=fixtureNight('2026-10-21'),summary=weatherForNight(n),slots=weatherSlots(n,summary);
 assert.ok(summary.partial);assert.equal(slots.length,8);assert.equal(slots.filter(x=>x.instant).length,7);
 const tail=slots.filter(x=>x.instant&&x.start>summary.hours.at(-1).start);
 assert.equal(tail.length,3);assert.ok(tail.every(x=>x.cloud===null&&x.temp===null&&x.visibility===null));
 assert.deepEqual(weatherSlots(n,weatherForNight(n,'unknown')),[]);
});

test('cursor never selects the next night and Now is snapped consistently to the five-minute grid',()=>{
 const n=fixtureNight();assert.equal(cursorFacts(n,n.end).instant,n.end-5*MIN);
 const offGrid=n.start+12*MIN+31_000;assert.equal(resetCursor(n,offGrid).instant,n.start+10*MIN);
 const polar=fixtureNight('2026-10-19','polar-dark');assert.notEqual(cursorFacts(polar,polar.end).state,'Daylight · Moon below horizon');
});
test('missing cloud variable preserves known temperatures and actual forecast-row coverage',()=>{
 const n=fixtureNight(),w=weatherForNight(n,'missing-variable');assert.equal(w.unavailable,false);assert.equal(w.coveredSamples,w.sampleCount);assert.equal(w.cloudSamples,0);assert.equal(w.cloudMin,null);assert.equal(w.cloudMax,null);assert.notEqual(w.tempMin,null);assert.equal(w.status,'Full dark-time coverage');
});
test('polar dark coverage includes both span endpoint instants and agrees with status',()=>{
 const w=weatherForNight(fixtureNight('2026-10-20','polar-dark'));assert.equal(w.sampleCount,25);assert.equal(w.coveredSamples,25);assert.equal(w.status,'Full dark-time coverage');
});

test('retrieval age follows the supplied clock without moving forecast lead or coverage',()=>{const n=fixtureNight(),base=weatherForNight(n,'ready',fixtureNow),later=weatherForNight(n,'ready',fixtureNow+4*H);assert.equal(later.ageHours,5);assert.equal(later.leadDays,base.leadDays);assert.equal(later.coveredSamples,base.coveredSamples);assert.equal(later.retrievedAt,base.retrievedAt);});
