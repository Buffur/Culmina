// Settings tab of Culmina's Android browser prototype: mountSettings(root, api).
//
// Functional reference (production Flutter, read-only here):
// lib/presentation/screens/settings/settings_screen.dart (sections, labels,
// slider/stepper steps, advanced summary, scope notice),
// display_settings_section.dart (Appearance and units),
// backup_section.dart (whole-database .astroplan backup; refusal wording),
// lib/domain/models/planning_preferences.dart (defaults and inclusive ranges),
// lib/core/units/display_units.dart (Appearance System/Light/Dark; units),
// lib/presentation/shared/field_mode_button.dart (separate red field mode),
// lib/presentation/screens/about/about_screen.dart and
// lib/core/config/app_identity.dart (About, attribution, licence, privacy).
//
// Everything this module stores lives only under culmina-settings-preview-v1.
// It never reads or writes the plan preview, navigation checkpoints, other tabs'
// keys or any application database, and it never contacts a network service.

import {initialPlanningPreferences} from './preview-bridge.js?v=20261020-hybrid7';

const STORAGE_KEY = 'culmina-settings-preview-v1';
const PAYLOAD_KIND = 'culmina-settings-preview';
const PAYLOAD_VERSION = 1;
const BACKUP_KIND = 'culmina-settings-preview-backup';
const BACKUP_VERSION = 1;
const MAX_BACKUP_BYTES = 64 * 1024; // prototype guard only
const SCENARIOS = ['ready', 'empty', 'error', 'storage-error'];
const MEMORY_ONLY = ['unreadable', 'unavailable', 'scenario'];

// AppIdentity / AboutScreen (production constants, copied as text).
const APP = {
  name: 'Culmina',
  version: '1.0.0',
  author: 'Buffur',
  reddit: 'https://www.reddit.com/user/Buffur/',
  github: 'https://github.com/Buffur',
  source: 'https://github.com/Buffur/Culmina',
  privacy: 'https://buffur.github.io/Culmina/privacy/',
};

/* ---------- Model (mirrors PlanningPreferences and DisplayUnits) ---------- */

// PlanningPreferences: defaults are documented assumptions; ranges inclusive.
// An optional overhead that is null is off ("Not included"), never a zero.
const PLANNING_FIELDS = {
  minAltitudeDeg: { range: [5, 60] },
  darknessLimitDeg: { values: [-18, -15, -12] }, // DarknessLimit
  feasibilityMarginPercent: { range: [0, 50] },
  perFrameOverheadSeconds: { range: [0, 120] },
  moonGateEnabled: { bool: true },
  moonGateMinIlluminationPct: { range: [0, 100] },
  cloudGateEnabled: { bool: true },
  cloudGateMaxPct: { range: [0, 100] },
  ditherEveryNFrames: { range: [1, 100], integer: true, nullable: true },
  ditherSettleSeconds: { range: [0, 600] },
  refocusEveryMinutes: { range: [10, 600], nullable: true },
  refocusSeconds: { range: [0, 600] },
  filterChangeSeconds: { range: [0, 600], nullable: true },
  meridianFlipSeconds: { range: [0, 1800], nullable: true },
  setupMinutes: { range: [0, 240], nullable: true },
  npfK: { range: [1, 3] },
  dewMarginC: { range: [0, 10] },
};

// Values pre-filled when an optional time is switched on (settings_screen.dart).
const OVERHEAD_ON = { ditherEveryNFrames: 3, refocusEveryMinutes: 60, filterChangeSeconds: 30, meridianFlipSeconds: 300, setupMinutes: 30 };

const APPEARANCES = [['system', 'System'], ['light', 'Light'], ['dark', 'Dark']];
const UNITS = {
  temperature: [['celsius', '°C'], ['fahrenheit', '°F']],
  wind: [['kmh', 'km/h'], ['mph', 'mph'], ['ms', 'm/s']],
  elevation: [['metres', 'm'], ['feet', 'ft']],
};
const UNIT_TITLES = { temperature: 'Temperature', wind: 'Wind', elevation: 'Elevation' };
const SCALES = [['1', '100%'], ['1.25', '125%'], ['2', '200%']];

function defaultSettings() {
  return {
    display: { appearance: 'system', units: { temperature: 'celsius', wind: 'kmh', elevation: 'metres' } },
    planning: {...initialPlanningPreferences},
    // TASK 16.3 (owner decision): place-name lookup is opt-in, off by default.
    privacy: { placeNameLookup: false },
  };
}

const isObject = v => !!v && typeof v === 'object' && !Array.isArray(v);
const exactKeys = (o, keys) => isObject(o) && Object.keys(o).length === keys.length && keys.every(k => Object.hasOwn(o, k));

function validField(spec, v) {
  if (spec.bool) return typeof v === 'boolean';
  if (spec.values) return spec.values.includes(v);
  if (v === null) return !!spec.nullable;
  return typeof v === 'number' && Number.isFinite(v) && v >= spec.range[0] && v <= spec.range[1] && (!spec.integer || Number.isInteger(v));
}

function validSettings(s) {
  if (!exactKeys(s, ['display', 'planning', 'privacy'])) return false;
  const d = s.display;
  if (!exactKeys(d, ['appearance', 'units']) || !APPEARANCES.some(([v]) => v === d.appearance)) return false;
  if (!exactKeys(d.units, Object.keys(UNITS)) || !Object.entries(UNITS).every(([k, list]) => list.some(([v]) => v === d.units[k]))) return false;
  const p = s.planning;
  if (!exactKeys(p, Object.keys(PLANNING_FIELDS)) || !Object.entries(PLANNING_FIELDS).every(([k, spec]) => validField(spec, p[k]))) return false;
  return exactKeys(s.privacy, ['placeNameLookup']) && typeof s.privacy.placeNameLookup === 'boolean';
}

const clone = value => JSON.parse(JSON.stringify(value));
// Compare actual validated values, not rounded review labels or JSON key order.
const sameSettings = (a, b) => a === b || (isObject(a) && isObject(b) &&
  Object.keys(a).length === Object.keys(b).length &&
  Object.keys(a).every(k => Object.hasOwn(b, k) && sameSettings(a[k], b[k])));

// Shared with checked prototype backup; does not restore or mutate anything.
export function validateSettingsPayload(raw) {
  try {
    const value = typeof raw === 'string' ? JSON.parse(raw) : raw;
    return value?.kind === PAYLOAD_KIND && value.version === PAYLOAD_VERSION && validSettings(value.settings);
  } catch { return false; }
}

/* ---------- Isolated local persistence ---------- */

// status: 'stored' (our key, valid), 'defaults' (no key yet), 'unreadable'
// (malformed or incompatible payload, kept untouched), 'unavailable' (storage threw).
function readStore(storage) {
  let raw;
  try {
    raw = storage.getItem(STORAGE_KEY);
  } catch {
    return { status: 'unavailable', settings: defaultSettings() };
  }
  if (raw === null) return { status: 'defaults', settings: defaultSettings() };
  try {
    const value = JSON.parse(raw);
    if (value?.kind === PAYLOAD_KIND && value.version === PAYLOAD_VERSION && validSettings(value.settings)) {
      return { status: 'stored', settings: value.settings };
    }
  } catch { /* malformed JSON: reported, never overwritten */ }
  return { status: 'unreadable', settings: defaultSettings() };
}

function writeStore(storage, settings) {
  storage.setItem(STORAGE_KEY, JSON.stringify({ kind: PAYLOAD_KIND, version: PAYLOAD_VERSION, savedAtUtc: new Date().toISOString(), settings }));
}

class PreviewFailure extends Error {
  constructor(kind) {
    super(kind);
    this.kind = kind;
  }
}

// The preview's settings file: checked completely before anything changes.
// Problems follow BackupProblem's meanings, worded for this preview file.
function checkBackup(text) {
  let value;
  try {
    value = JSON.parse(text);
  } catch {
    return { problem: 'this file is not a Culmina preview settings file, or it is damaged' };
  }
  if (!isObject(value) || value.kind !== BACKUP_KIND || !Number.isInteger(value.version)) {
    return { problem: 'this file is not a Culmina preview settings file, or it is damaged' };
  }
  if (value.version > BACKUP_VERSION) return { problem: 'it was made by a newer version of this preview' };
  if (value.version < BACKUP_VERSION) return { problem: 'it is too old for this preview' };
  if (typeof value.createdAtUtc !== 'string' || !Number.isFinite(Date.parse(value.createdAtUtc)) || !validSettings(value.settings)) {
    return { problem: 'the settings in it are damaged, incomplete or outside the allowed ranges' };
  }
  return { backup: { createdAtUtc: value.createdAtUtc, settings: value.settings } };
}

/* ---------- Wording and units ---------- */

const trim = (v, digits = 1) => String(Number(v.toFixed(digits)));
const deg = v => `${v < 0 ? '−' : ''}${trim(Math.abs(v))}°`;
const pct = v => `${trim(v)}%`;
const sec = v => `${Math.round(v)} s`;
const mins = v => `${Math.round(v)} min`;
const onOff = v => (v ? 'On' : 'Off');
const notIncluded = format => v => (v === null ? 'Not included' : format(v));

// QuantityText.duration
function duration(totalSeconds) {
  if (totalSeconds > 0 && totalSeconds < 60) return `${Math.round(totalSeconds)} s`;
  const minutes = Math.round(totalSeconds / 60), h = Math.floor(minutes / 60), m = minutes % 60;
  if (h === 0) return `${m} min`;
  return m === 0 ? `${h} h` : `${h} h ${m} min`;
}

// QuantityText.temperatureDifference: a difference converts by 9/5 only.
const dewText = (celsius, unit) => (unit === 'fahrenheit' ? `${trim(celsius * 9 / 5)} °F` : `${trim(celsius)} °C`);

// SettingsScreen.advancedSummary
function advancedSummary(p) {
  const gates = [p.moonGateEnabled, p.cloudGateEnabled].filter(Boolean).length;
  const times = ['ditherEveryNFrames', 'refocusEveryMinutes', 'filterChangeSeconds', 'meridianFlipSeconds', 'setupMinutes'].filter(k => p[k] !== null).length;
  return `Gates: ${gates} of 2 on · optional times: ${times} of 5 included`;
}

const OVERHEAD_SUMMARY = {
  ditherEveryNFrames: p => `Every ${p.ditherEveryNFrames} lights, ${sec(p.ditherSettleSeconds)} to settle each`,
  refocusEveryMinutes: p => `Every ${mins(p.refocusEveryMinutes)}, ${sec(p.refocusSeconds)} each`,
  filterChangeSeconds: p => `${sec(p.filterChangeSeconds)} per change`,
  meridianFlipSeconds: p => `${duration(p.meridianFlipSeconds)}, once, when the target crosses the meridian`,
  setupMinutes: p => `${mins(p.setupMinutes)}, in the total time only`,
};

// Rows of the restore comparison; stored units (°C) are named explicitly.
const COMPARISON = [
  ['Theme', s => APPEARANCES.find(([v]) => v === s.display.appearance)[1]],
  ...Object.keys(UNITS).map(k => [UNIT_TITLES[k], s => UNITS[k].find(([v]) => v === s.display.units[k])[1]]),
  ['Minimum target altitude', s => deg(s.planning.minAltitudeDeg)],
  ['Darkness limit (Sun altitude)', s => deg(s.planning.darknessLimitDeg)],
  ['Feasibility margin', s => pct(s.planning.feasibilityMarginPercent)],
  ['Time between frames', s => sec(s.planning.perFrameOverheadSeconds)],
  ['Moon gate', s => (s.planning.moonGateEnabled ? `On, at least ${pct(s.planning.moonGateMinIlluminationPct)} lit` : 'Off')],
  ['Cloud gate', s => (s.planning.cloudGateEnabled ? `On, more than ${pct(s.planning.cloudGateMaxPct)} cloud` : 'Off')],
  ['Dither', s => notIncluded(() => OVERHEAD_SUMMARY.ditherEveryNFrames(s.planning))(s.planning.ditherEveryNFrames)],
  ['Refocus', s => notIncluded(() => OVERHEAD_SUMMARY.refocusEveryMinutes(s.planning))(s.planning.refocusEveryMinutes)],
  ['Filter change', s => notIncluded(() => OVERHEAD_SUMMARY.filterChangeSeconds(s.planning))(s.planning.filterChangeSeconds)],
  ['Meridian flip', s => notIncluded(() => OVERHEAD_SUMMARY.meridianFlipSeconds(s.planning))(s.planning.meridianFlipSeconds)],
  ['Setup before the first window', s => notIncluded(() => OVERHEAD_SUMMARY.setupMinutes(s.planning))(s.planning.setupMinutes)],
  ['Dither settle (kept when off)', s => sec(s.planning.ditherSettleSeconds)],
  ['Refocus duration (kept when off)', s => sec(s.planning.refocusSeconds)],
  ['NPF star-trail tolerance', s => `k = ${s.planning.npfK.toFixed(1)}`],
  ['Dew warning margin', s => dewText(s.planning.dewMarginC, 'celsius')],
  ['Look up place names', s => onOff(s.privacy.placeNameLookup)],
];

const SECTION_TITLES = { appearance: 'Appearance', planning: 'Planning', privacy: 'Privacy', backup: 'Backup & data', about: 'About', restore: 'Restore settings' };

/* ---------- Module ---------- */

export function mountSettings(root, api) {
  const hybrid = (api.variant ?? new URLSearchParams(location.search).get('variant') ?? 'blend') === 'blend';
  const esc = api.esc;
  const storage = api.storage;
  const scenario = SCENARIOS.includes(api.scenario) ? api.scenario : 'ready';
  const media = typeof window.matchMedia === 'function' ? window.matchMedia('(prefers-color-scheme: dark)') : null;
  const S = {
    page: 'root',
    status: 'defaults',
    settings: defaultSettings(),
    loadFailed: scenario === 'error',
    simulateFail: scenario === 'storage-error',
    // Applied now, not stored: { display?: message, privacy?: message } (F21 A5/A6).
    unsaved: {},
    draft: null, initial: '', saveError: '', advancedOpen: false,
    backupError: '', pending: null, restoreError: '',
  };
  const dialogs = new Set();
  let disposed = false;
  let backupReadRevision = 0;

  function load() {
    if (scenario === 'empty') {
      S.status = 'scenario';
      S.settings = defaultSettings();
      return;
    }
    const read = readStore(storage);
    S.status = read.status;
    S.settings = read.settings;
  }

  // Applies `change` to the freshest stored settings, so a section saved in
  // another tab is kept, then writes only this module's key. Pending unsaved
  // sections ride along and are stored too. Memory-only states never write.
  function mutate(change) {
    if (S.simulateFail) throw new PreviewFailure('simulated');
    const pending = Object.fromEntries(Object.keys(S.unsaved).map(k => [k, S.settings[k]]));
    if (MEMORY_ONLY.includes(S.status)) {
      S.settings = change({ ...S.settings, ...pending });
      S.unsaved = {};
      return ' (kept in this tab only)';
    }
    const fresh = readStore(storage);
    if (fresh.status === 'unreadable' || fresh.status === 'unavailable') {
      S.status = fresh.status;
      throw new PreviewFailure(fresh.status);
    }
    const next = change({ ...fresh.settings, ...pending });
    try {
      writeStore(storage, next);
    } catch {
      throw new PreviewFailure('write');
    }
    S.settings = next;
    S.status = 'stored';
    S.unsaved = {};
    return '';
  }

  function failureText(error, action) {
    switch (error?.kind) {
      case 'simulated':
        return `Couldn't ${action}. This preview simulates a storage failure; Try again clears the simulation.`;
      case 'unreadable':
        return `Couldn't ${action}: the stored preview settings can't be read, so they were left unchanged. Try again keeps the change in this tab only.`;
      case 'unavailable':
        return `Couldn't ${action}: browser storage is unavailable. Try again keeps the change in this tab only.`;
      default:
        return `Couldn't ${action}: this browser refused to store it. Your stored preview settings are unchanged.`;
    }
  }

  /* ----- Display helpers ----- */

  const systemTheme = () => (media?.matches ? 'dark' : 'light');
  const resolve = appearance => (appearance === 'system' ? systemTheme() : appearance);

  // What the Theme choice shows: the stored choice while it is what the phone
  // shows; otherwise (the lab toolbar changed it) the theme actually shown.
  function shownAppearance() {
    const stored = S.settings.display.appearance;
    const theme = api.display.theme;
    if (theme === 'field' || (stored === 'system' && !media)) return stored;
    return resolve(stored) === theme ? stored : theme;
  }

  /* ----- Rendering ----- */

  root.innerHTML = '<div class="settings-view"></div>';
  const view = root.firstElementChild;
  const scroller = root.closest('.android-scroll');

  function show(page, focus = null) {
    if (page !== S.page) backupReadRevision += 1;
    S.page = page;
    render(focus);
    if (scroller) scroller.scrollTop = 0;
  }

  function render(focus = null) {
    const page = S.page;
    if (page === 'root') api.setHeader('Settings');
    else if (page === 'planning') api.setHeader('Planning', () => cancelPlanning());
    else if (page === 'restore') api.setHeader(SECTION_TITLES.restore, () => cancelRestore());
    else api.setHeader(SECTION_TITLES[page], () => show('root', `[data-open="${page}"]`));
    view.innerHTML = {
      root: rootView, appearance: appearanceView, planning: planningView, privacy: privacyView,
      backup: backupView, restore: restoreView, about: aboutView,
    }[page]();
    const target = (focus && view.querySelector(focus)) || (page !== 'root' && view.querySelector('[data-focus-start]')) || null;
    target?.focus({ preventScroll: true });
    target?.scrollIntoView?.({ block: 'nearest' });
  }

  // Re-renders the current page in place: same scroll position and focus.
  function rerender() {
    const id = document.activeElement && view.contains(document.activeElement) ? document.activeElement.id : '';
    const top = scroller?.scrollTop;
    view.innerHTML = {
      root: rootView, appearance: appearanceView, planning: planningView, privacy: privacyView,
      backup: backupView, restore: restoreView, about: aboutView,
    }[S.page]();
    if (scroller) scroller.scrollTop = top;
    if (id) document.getElementById(id)?.focus({ preventScroll: true });
  }

  function previewNote() {
    const notice = {
      unreadable: `<div class="workspace-error settings-notice" role="status"><p>The stored preview settings can't be read. They are kept unchanged: defaults are shown and changes stay in this tab only.</p>
        <div class="workspace-actions"><button type="button" class="secondary-button" id="settings-replace" data-replace-store>Replace stored settings with these</button></div></div>`,
      unavailable: '<div class="workspace-error settings-notice" role="status"><p>Browser storage is unavailable here, so changes stay in this tab only.</p></div>',
      scenario: '<p class="settings-note">Empty scenario: nothing stored is shown, so the defaults appear. Changes stay in this tab only; stored preview settings are untouched.</p>',
      defaults: '<p class="settings-note">Nothing saved yet: the app\'s defaults are shown.</p>',
    }[S.status] || '';
    return `<p class="settings-note">Preview settings · saved in this browser.</p>${notice}`;
  }

  function unsavedNotice(section) {
    if (!S.unsaved[section]) return '';
    return `<div class="workspace-error settings-notice" role="alert"><p>${esc(S.unsaved[section])}</p>
      <div class="workspace-actions"><button type="button" class="secondary-button" id="settings-retry-${section}" data-retry-section="${section}">Try again</button></div></div>`;
  }

  const row = (page, symbol, title, summary) => `<button type="button" class="workspace-row settings-row" id="settings-open-${page}" data-open="${page}">
      ${api.icon(symbol)}<span class="settings-row-text"><span class="settings-row-title">${esc(title)}</span><span class="workspace-copy">${esc(summary)}</span></span>${api.icon('next')}
    </button>`;

  function rootView() {
    if (S.loadFailed) {
      return `<div class="workspace-error" role="alert"><p>Couldn't load the settings.</p>
        <p class="workspace-copy">This is the preview's simulated load failure; stored preview settings are untouched.</p>
        <div class="workspace-actions"><button type="button" class="secondary-button" id="settings-retry-load" data-retry-load>Try again</button></div></div>`;
    }
    const s = S.settings, p = s.planning;
    const theme = api.display.theme === 'field' ? 'Red field mode' : APPEARANCES.find(([v]) => v === shownAppearance())?.[1] || 'Light';
    const scale = SCALES.find(([v]) => v === String(api.display.scale))?.[1] || '100%';
    const units = Object.keys(UNITS).map(k => UNITS[k].find(([v]) => v === s.display.units[k])[1]).join(', ');
    return `${previewNote()}
      <section class="settings-group" aria-labelledby="settings-preferences">
        <h2 id="settings-preferences">Preferences</h2>
        ${row('appearance', 'moon', 'Appearance', `${theme} · text ${scale} · ${units}`)}
        ${row('planning', 'target', 'Planning', `${deg(p.minAltitudeDeg)} altitude · ${deg(p.darknessLimitDeg)} Sun · ${pct(p.feasibilityMarginPercent)} margin · ${sec(p.perFrameOverheadSeconds)} between frames`)}
        ${row('privacy', 'pin', 'Privacy', `Place-name lookup ${s.privacy.placeNameLookup ? 'on' : 'off'}`)}
      </section>
      <section class="settings-group" aria-labelledby="settings-data">
        <h2 id="settings-data">Data and about</h2>
        ${row('backup', 'download', 'Backup & data', 'Save or restore these preview settings')}
        ${row('about', 'book', 'About', `${APP.name} ${APP.version} · data sources and licence`)}
      </section>`;
  }

  const radio = (name, id, value, label, checked) => `<label class="choice" for="${id}"><input type="radio" id="${id}" name="${name}" value="${esc(value)}"${checked ? ' checked' : ''}><span>${esc(label)}</span></label>`;

  const switchRow = (id, attr, title, desc, checked) => `<label class="settings-switch" for="${id}">
      <span class="settings-switch-text"><span class="settings-field-title">${esc(title)}</span><span class="field-hint" id="${id}-hint">${esc(desc)}</span></span>
      <input type="checkbox" role="switch" id="${id}" ${attr}${checked ? ' checked' : ''} aria-describedby="${id}-hint">
    </label>`;

  function appearanceView() {
    const d = S.settings.display, field = api.display.theme === 'field', shown = shownAppearance();
    const systemHint = media ? `System follows this device's light or dark setting (now ${systemTheme() === 'dark' ? 'Dark' : 'Light'}).` : '';
    return `<section class="settings-section" aria-labelledby="settings-theme-title">
        <h2 id="settings-theme-title" tabindex="-1" data-focus-start>Theme</h2>
        <fieldset class="segmented" aria-describedby="settings-theme-hint"><legend class="settings-hidden">Theme</legend>
          ${APPEARANCES.filter(([v]) => v !== 'system' || media).map(([v, label]) => radio('settings-appearance', `settings-theme-${v}`, v, label, v === shown)).join('')}
        </fieldset>
        <p class="field-hint" id="settings-theme-hint">${esc(systemHint)}${field ? ' Applies when red field mode is off.' : ''}</p>
        ${switchRow('settings-field', 'data-field-mode', 'Red field mode', 'Red on black only, to keep your night vision. The same switch as the moon button in the app bar.', field)}
      </section>
      <section class="settings-section" aria-labelledby="settings-text-title">
        <h2 id="settings-text-title">Text size</h2>
        <fieldset class="segmented" aria-describedby="settings-text-hint"><legend class="settings-hidden">Text size</legend>
          ${SCALES.map(([v, label]) => radio('settings-scale', `settings-scale-${v.replace('.', '-')}`, v, label, v === String(api.display.scale))).join('')}
        </fieldset>
        <p class="field-hint" id="settings-text-hint">In the app, text follows Android's font size. Here it scales this preview only.</p>
      </section>
      <section class="settings-section" aria-labelledby="settings-units-title">
        <h2 id="settings-units-title">Units</h2>
        <p class="workspace-copy">Shown units only: stored values and calculations stay in °C, km/h and m. In this preview only the dew margin uses them.</p>
        ${Object.entries(UNITS).map(([k, list]) => `<fieldset class="segmented settings-units"><legend>${UNIT_TITLES[k]}</legend>
          ${list.map(([v, label]) => radio(`settings-unit-${k}`, `settings-unit-${k}-${v}`, v, label, d.units[k] === v)).join('')}</fieldset>`).join('')}
      </section>
      ${unsavedNotice('display')}
      <p class="settings-note">Theme and units are kept in preview storage; field mode and text size stay in this page's address, as the lab controls do.</p>`;
  }

  /* ----- Planning (explicit Save) ----- */

  const planningDirty = () => S.page === 'planning' && !!S.draft && JSON.stringify(S.draft) !== S.initial;

  function slider(key, title, help, step, format) {
    const { range: [min, max] } = PLANNING_FIELDS[key], v = S.draft[key], id = `settings-${key}`;
    return `<div class="settings-field">
        <div class="settings-field-head"><label class="settings-field-title" for="${id}">${esc(title)}</label>
          <output id="${id}-value" for="${id}" data-value-of="${key}">${esc(format(v))}</output></div>
        <p class="field-hint" id="${id}-hint">${esc(help)}</p>
        <input type="range" id="${id}" data-plan="${key}" min="${min}" max="${max}" step="${step}" value="${v}" aria-valuetext="${esc(format(v))}" aria-describedby="${id}-hint">
        <div class="settings-range-ends" aria-hidden="true"><span>${esc(format(min))}</span><span>${esc(format(max))}</span></div>
      </div>`;
  }

  function stepper(key, label, step, format) {
    const { range: [min, max] } = PLANNING_FIELDS[key], v = S.draft[key], id = `settings-${key}`;
    return `<div class="settings-stepper" role="group" aria-labelledby="${id}-label">
        <span id="${id}-label">${esc(label)}</span>
        <button type="button" class="secondary-button settings-step" id="${id}-less" data-step="${key}" data-delta="${-step}" aria-label="${esc(label)}: less"${v <= min ? ' disabled' : ''}>−</button>
        <output aria-live="polite" data-value-of="${key}">${esc(format(v))}</output>
        <button type="button" class="secondary-button settings-step" id="${id}-more" data-step="${key}" data-delta="${step}" aria-label="${esc(label)}: more"${v >= max ? ' disabled' : ''}>+</button>
      </div>`;
  }

  function gate(enabledKey, pctKey, title, on, off) {
    const p = S.draft;
    return `<div class="settings-option">
        ${switchRow(`settings-${enabledKey}`, `data-plan-bool="${enabledKey}"`, title, p[enabledKey] ? on(pct(p[pctKey])) : off, p[enabledKey])}
        ${p[enabledKey] ? slider(pctKey, `${title} threshold`, 'An assumption, not physics.', 5, pct) : ''}
      </div>`;
  }

  function overhead(key, title, steppers) {
    const p = S.draft, on = p[key] !== null;
    return `<div class="settings-option">
        ${switchRow(`settings-${key}-on`, `data-overhead="${key}"`, title, on ? OVERHEAD_SUMMARY[key](p) : 'Not included', on)}
        ${on ? `<div class="settings-steppers">${steppers}</div>` : ''}
      </div>`;
  }

  function planningView() {
    const p = S.draft, unit = S.settings.display.units.temperature;
    return `<form class="settings-form" data-planning-form novalidate>
      <p class="settings-intro settings-planning-lead" tabindex="-1" data-focus-start>Plan defaults. Saved snapshots stay unchanged.</p>
      <section class="settings-section settings-budget-first" aria-labelledby="settings-fit">
        <h2 id="settings-fit">Capture budget</h2>
        ${slider('perFrameOverheadSeconds', 'Time between frames', 'Download and delay after each exposure. Measure your rig.', 1, sec)}
        ${slider('feasibilityMarginPercent', 'Fit margin', 'Shows Tight when less than this share of usable time remains.', 1, pct)}
      </section>
      <details class="plan-disclosure settings-scope"><summary>How these defaults apply</summary>
        <p class="workspace-copy">Save updates the current Plan's budget and fit in this prototype: time between frames, fit margin and optional setup. An explicit assumption in the Plan overrides the matching default. A saved plan keeps its recorded values until you explicitly save changes.</p>
        <p class="workspace-copy">Window limits, gates and the other timing/guidance preferences below are stored, but this fixture-based preview does not calculate their effects. They are planning assumptions, not scientific laws.</p>
        <p class="workspace-copy">Time between frames is measured from one exposure's end to the next exposure's start. A camera's start-to-start interval includes the exposure; subtract it first. Dither settling is separate.</p>
      </details>
      <section class="settings-section" aria-labelledby="settings-window">
        <h2 id="settings-window">Imaging window</h2>
        <p class="workspace-copy">Stored preference · the preview's example window stays fixed.</p>
        ${slider('minAltitudeDeg', 'Minimum target altitude', 'Below this the target is not counted as usable. Low altitude means more atmosphere, extinction and poor seeing.', 1, deg)}
        <fieldset class="segmented settings-darkness" aria-describedby="settings-darkness-hint"><legend>Darkness limit (Sun altitude)</legend>
          ${PLANNING_FIELDS.darknessLimitDeg.values.map(v => radio('settings-darkness', `settings-darkness-${-v}`, String(v), deg(v), p.darknessLimitDeg === v)).join('')}
        </fieldset>
        <p class="field-hint" id="settings-darkness-hint">−18° is full astronomical darkness. −15° or −12° give longer windows with a brighter sky background.</p>
      </section>
      <details class="plan-disclosure settings-advanced" data-advanced${S.advancedOpen ? ' open' : ''}>
        <summary id="settings-advanced-summary">Gates and optional times<span data-advanced-summary>${esc(advancedSummary(p))}</span></summary>
        <p class="workspace-copy">Setup changes the prototype's total session time. Other options are saved preferences; their effect needs the app's calculation engine.</p>
        ${gate('moonGateEnabled', 'moonGateMinIlluminationPct', 'Moon gate', v => `Excludes time when the Moon is up and at least ${v} lit.`, 'Off: the Moon never excludes time.')}
        ${gate('cloudGateEnabled', 'cloudGateMaxPct', 'Cloud gate', v => `Excludes forecast hours with more than ${v} cloud. An hour without a forecast is never excluded.`, 'Off: the forecast never excludes time.')}
        <p class="workspace-copy">Optional times are assumptions. Off means not included, not measured as zero. Setup stays outside the imaging window.</p>
        ${overhead('ditherEveryNFrames', 'Dither', p.ditherEveryNFrames === null ? '' : stepper('ditherEveryNFrames', 'Every', 1, v => `${v} lights`) + stepper('ditherSettleSeconds', 'Settle', 5, sec))}
        ${overhead('refocusEveryMinutes', 'Refocus', p.refocusEveryMinutes === null ? '' : stepper('refocusEveryMinutes', 'Every', 10, mins) + stepper('refocusSeconds', 'Takes', 10, sec))}
        ${overhead('filterChangeSeconds', 'Filter change', p.filterChangeSeconds === null ? '' : stepper('filterChangeSeconds', 'Takes', 5, sec))}
        ${overhead('meridianFlipSeconds', 'Meridian flip', p.meridianFlipSeconds === null ? '' : stepper('meridianFlipSeconds', 'Takes', 30, sec))}
        ${overhead('setupMinutes', 'Setup before the first window', p.setupMinutes === null ? '' : stepper('setupMinutes', 'Takes', 5, mins))}
      </details>
      <section class="settings-section" aria-labelledby="settings-guidance">
        <h2 id="settings-guidance">Guidance</h2>
        <p class="workspace-copy">Stored guidance preferences · no change to this preview's fit.</p>
        ${slider('npfK', 'NPF star-trail tolerance (k)', 'For untracked exposures (Michaud NPF rule): 1 = round stars, up to 3 = slightly elongated. Higher allows longer sub-exposures.', 0.5, v => `k = ${v.toFixed(1)}`)}
        ${slider('dewMarginC', 'Dew warning margin', 'Warn when the air temperature is within this margin of the dew point.', 0.5, v => dewText(v, unit))}
      </section>
      ${S.saveError ? `<div class="workspace-error settings-notice" role="alert"><p>${esc(S.saveError)}</p>
        <div class="workspace-actions"><button type="button" class="secondary-button" id="settings-retry-planning" data-retry-planning>Try again</button></div></div>` : ''}
      <div class="settings-savebar">
        <p class="settings-state" data-dirty-state aria-live="polite">${planningDirty() ? 'Changed · not saved' : 'No changes'}</p>
        <div class="workspace-actions">
          <button type="button" class="secondary-button" id="settings-cancel-planning" data-cancel-planning>Cancel</button>
          <button type="submit" class="primary-button" id="settings-save-planning">Save</button>
        </div>
      </div>
    </form>`;
  }

  function openPlanning() {
    S.draft = clone(S.settings.planning);
    S.initial = JSON.stringify(S.draft);
    S.saveError = '';
    S.advancedOpen = false;
    show('planning');
  }

  function leavePlanning(message) {
    S.draft = null;
    S.saveError = '';
    show('root', '[data-open="planning"]');
    if (message) api.announce(message);
  }

  async function cancelPlanning() {
    if (planningDirty()) {
      const discard = await confirmDialog({ title: 'Discard your changes?', message: 'The planning settings stay as they were saved.', confirm: 'Discard', cancel: 'Keep editing' });
      if (!discard || disposed || S.page !== 'planning') return;
    }
    leavePlanning('');
  }

  function savePlanning() {
    if (!planningDirty()) {
      leavePlanning('No changes to save.');
      return;
    }
    const planning = clone(S.draft);
    if (!Object.entries(PLANNING_FIELDS).every(([k, spec]) => validField(spec, planning[k]))) {
      S.saveError = 'A value is outside its allowed range, so nothing was saved.';
      rerender();
      return;
    }
    let note;
    try {
      note = mutate(s => ({ ...s, planning }));
    } catch (error) {
      S.saveError = failureText(error, 'save the planning settings');
      render('[data-retry-planning]');
      api.announce(S.saveError);
      return;
    }
    leavePlanning(note ? `Planning defaults kept in this tab only${note}. The Plan still uses its stored defaults.` : 'Planning defaults saved. The current Plan uses budget defaults unless it overrides them; saved snapshots stay unchanged.');
  }

  // Updates the shown value and dirty state without re-rendering (keeps the
  // slider focused while it is dragged).
  function refreshPlanningText(key) {
    const p = S.draft, unit = S.settings.display.units.temperature;
    const formats = { minAltitudeDeg: deg, feasibilityMarginPercent: pct, perFrameOverheadSeconds: sec, moonGateMinIlluminationPct: pct, cloudGateMaxPct: pct, npfK: v => `k = ${v.toFixed(1)}`, dewMarginC: v => dewText(v, unit) };
    const text = formats[key]?.(p[key]);
    if (text) {
      const out = view.querySelector(`[data-value-of="${key}"]`);
      if (out) out.textContent = text;
      view.querySelector(`[data-plan="${key}"]`)?.setAttribute('aria-valuetext', text);
    }
    if (key === 'moonGateMinIlluminationPct' || key === 'cloudGateMaxPct') {
      const gateKey = key === 'moonGateMinIlluminationPct' ? 'moonGateEnabled' : 'cloudGateEnabled';
      const hint = view.querySelector(`#settings-${gateKey}-hint`);
      if (hint) hint.textContent = gateKey === 'moonGateEnabled'
        ? `Excludes time when the Moon is up and at least ${pct(p[key])} lit.`
        : `Excludes forecast hours with more than ${pct(p[key])} cloud. An hour without a forecast is never excluded.`;
    }
    const state = view.querySelector('[data-dirty-state]');
    if (state) state.textContent = planningDirty() ? 'Changed · not saved' : 'No changes';
    const summary = view.querySelector('[data-advanced-summary]');
    if (summary) summary.textContent = advancedSummary(p);
  }

  /* ----- Privacy ----- */

  function privacyView() {
    return `<section class="settings-section" aria-labelledby="settings-privacy-title">
        <h2 id="settings-privacy-title" tabindex="-1" data-focus-start>Place names</h2>
        ${switchRow('settings-place-names', 'data-place-names', 'Look up place names', 'Optional: the app sends the chosen coordinates to OpenStreetMap Nominatim. Off keeps coordinate labels.', S.settings.privacy.placeNameLookup)}
        <p class="settings-note">This preview stores your choice only. No place-name request is sent.</p>
        ${unsavedNotice('privacy')}
      </section>
      <details class="plan-disclosure settings-section" aria-labelledby="settings-privacy-app">
        <summary id="settings-privacy-app">What leaves the device in the app</summary>
        <p class="workspace-copy">No account, no ads, no analytics and no tracking. Your sites, rigs, targets, plans and results stay on the device. The app sends a position only to fetch the weather (Open-Meteo), to show map tiles (OpenStreetMap) and — if you switch it on here, or when the site editor offers it — to look up a place name (Nominatim). Location permission is asked only when you tap "Use current position".</p>
        <p class="workspace-copy">In this browser prototype, site coordinates can come from an explicit device-position request. Your browser asks permission and may use its own location service. No map, weather or place-name provider is contacted by the preview.</p>
      </details>`;
  }

  /* ----- Backup & data ----- */

  function download(settings) {
    const envelope = {
      kind: BACKUP_KIND,
      version: BACKUP_VERSION,
      createdAtUtc: new Date().toISOString(),
      source: 'Culmina browser prototype',
      note: 'Preview settings only. Not an app backup: no plans, results, sites, rigs or targets.',
      settings,
    };
    const blob = new Blob([JSON.stringify(envelope, null, 2)], { type: 'application/json' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    const d = new Date();
    a.href = url;
    a.download = `culmina-preview-settings-${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}.json`;
    a.hidden = true;
    view.append(a);
    a.click();
    a.remove();
    setTimeout(() => URL.revokeObjectURL(url), 1000);
    return a.download;
  }

  function backupView() {
    return `<p class="settings-intro" tabindex="-1" data-focus-start>Back up this browser prototype, or just its settings. Neither file is an app database backup.</p>
      <section class="settings-section" aria-labelledby="settings-prototype-backup-title"><h2 id="settings-prototype-backup-title">Full prototype backup</h2>
        <p class="workspace-copy">Plan, Logbook, Library and Settings from this browser. Review a file before restoring.</p>
        <div class="workspace-actions"><button type="button" class="secondary-button settings-icon-button" data-prototype-backup>${api.icon('download')}<span>Prototype backup & restore</span></button></div>
      </section>
      <section class="settings-section" aria-labelledby="settings-export-title">
        <h2 id="settings-export-title">Save preview settings</h2>
        <p class="workspace-copy">One JSON file with the settings on these pages: appearance, units, planning and privacy. No plans, Logbook entries or app data.</p>
        <div class="workspace-actions"><button type="button" class="secondary-button settings-icon-button" id="settings-export" data-export>${api.icon('download')}<span>Download settings file</span></button></div>
      </section>
      <section class="settings-section" aria-labelledby="settings-restore-title">
        <h2 id="settings-restore-title">Restore preview settings</h2>
        <p class="workspace-copy">Checked first; nothing changes until you confirm.</p>
        <label class="block-input" for="settings-restore-file">Settings file (.json)
          <input type="file" id="settings-restore-file" data-restore-file accept=".json,application/json"${S.backupError ? ' aria-invalid="true" aria-describedby="settings-restore-error"' : ''}>
        </label>
        ${S.backupError ? `<p class="field-error" id="settings-restore-error" role="alert">${esc(S.backupError)}</p>` : ''}
      </section>
      <details class="plan-disclosure settings-section"><summary>Application backup</summary><p class="workspace-copy">The app backs up its whole database in an .astroplan file, checks a restore and restarts to apply it. Use the app for that file format; this browser handles prototype JSON only.</p></details>`;
  }

  async function pickBackup(file) {
    const revision = ++backupReadRevision;
    S.backupError = '';
    if (!file) return;
    api.announce('Checking settings file. Current settings are unchanged.');
    let problem = '', backup = null;
    if (file.size > MAX_BACKUP_BYTES) {
      problem = 'it is too large to be a preview settings file';
    } else {
      try {
        const checked = checkBackup(await file.text());
        problem = checked.problem || '';
        backup = checked.backup || null;
      } catch {
        problem = 'the file could not be read';
      }
    }
    if (disposed || S.page !== 'backup' || revision !== backupReadRevision) return;
    if (problem) {
      S.backupError = `The file was not applied: ${problem}. Your current preview settings are unchanged.`;
      render('#settings-restore-file');
      api.announce(S.backupError);
      return;
    }
    S.pending = backup;
    S.restoreError = '';
    show('restore');
    api.announce(hybrid && sameSettings(S.settings, backup.settings)
      ? 'File checked. Nothing changed.'
      : 'Settings file checked. Review the changes, then confirm or cancel. Nothing restored yet.');
  }

  function restoreView() {
    const b = S.pending;
    if (!b) return '<p class="workspace-copy" tabindex="-1" data-focus-start>No file is waiting to be restored.</p>';
    const made = new Intl.DateTimeFormat('en-GB', { day: 'numeric', month: 'short', year: 'numeric', hour: '2-digit', minute: '2-digit', hourCycle: 'h23', timeZoneName: 'short' }).format(Date.parse(b.createdAtUtc));
    const changes = COMPARISON.map(([label, f]) => [label, f(S.settings), f(b.settings)]).filter(([, now, next]) => now !== next);
    if (hybrid && sameSettings(S.settings, b.settings)) {
      return `<h2 class="settings-restore-title" tabindex="-1" data-focus-start>Already up to date</h2>
        <p class="workspace-copy">This file matches your current preview settings. Nothing needs to be replaced.</p>
        <p class="settings-note">Made ${esc(made)} by the Culmina browser prototype, file format ${BACKUP_VERSION}. Nothing changed.</p>
        <div class="workspace-actions"><button type="button" class="primary-button" id="settings-restore-cancel" data-restore-cancel>Close</button></div>`;
    }
    return `<h2 class="settings-restore-title" tabindex="-1" data-focus-start>Restore these settings?</h2>
      <p class="workspace-copy">Made ${esc(made)} by the Culmina browser prototype, file format ${BACKUP_VERSION}.</p>
      <section class="settings-section" aria-labelledby="settings-changes">
        <h3 id="settings-changes">What changes</h3>
        ${changes.length ? `<dl class="workspace-facts settings-changes">${changes.map(([label, now, next]) => `<div><dt>${esc(label)}</dt><dd>${esc(now)} → ${esc(next)}</dd></div>`).join('')}</dl>`
          : hybrid ? '<p class="workspace-copy">Stored values differ below the displayed precision. Replacing applies the values in this file.</p>' : '<p class="workspace-copy">Nothing: the file matches your current preview settings.</p>'}
      </section>
      <p class="settings-note">All preview settings are replaced. Saved plans and Logbook entries stay unchanged. Current global defaults update the working Plan budget. This can't be undone here, so download your current settings first if you want to keep them.</p>
      ${S.restoreError ? `<div class="workspace-error settings-notice" role="alert"><p>${esc(S.restoreError)}</p></div>` : ''}
      <div class="workspace-actions">
        <button type="button" class="secondary-button" id="settings-restore-cancel" data-restore-cancel>Cancel</button>
        <button type="button" class="secondary-button" id="settings-restore-first" data-restore-backup-first>Download current first</button>
        <button type="button" class="primary-button" id="settings-restore-apply" data-restore-apply>${S.restoreError ? 'Try again' : 'Replace settings'}</button>
      </div>`;
  }

  function cancelRestore() {
    S.pending = null;
    S.restoreError = '';
    show('backup', '#settings-restore-file');
  }

  function applyRestore() {
    const b = S.pending;
    if (!b) return;
    if (S.restoreError) S.simulateFail = false; // Try again clears the simulation
    const settings = clone(b.settings);
    let note;
    try {
      note = mutate(() => settings);
    } catch (error) {
      S.restoreError = failureText(error, 'restore the settings');
      rerender();
      view.querySelector('[data-restore-apply]')?.focus();
      api.announce(S.restoreError);
      return;
    }
    S.unsaved = {};
    if (api.display.theme !== 'field') api.applyDisplay({ theme: resolve(settings.display.appearance) });
    S.pending = null;
    S.restoreError = '';
    show('backup', '[data-export]');
    api.announce(`Preview settings restored${note}.`);
  }

  /* ----- About ----- */

  const link = (url, label) => `<a class="settings-link" href="${esc(url)}" target="_blank" rel="noopener noreferrer">${esc(label)}</a>`;

  function aboutView() {
    return `<section class="settings-section" aria-labelledby="settings-about-app">
        <h2 id="settings-about-app" tabindex="-1" data-focus-start>${APP.name}</h2>
        <p class="workspace-copy">Version ${APP.version} · Made by ${APP.author}</p>
        <p class="settings-links">${link(APP.reddit, `Reddit: u/${APP.author}`)}${link(APP.github, `GitHub: ${APP.author}`)}</p>
      </section>
      <section class="settings-section" aria-labelledby="settings-about-sources">
        <h2 id="settings-about-sources">Data sources in the app</h2>
        <ul class="settings-sources">
          <li><p>Target catalog: adapted from OpenNGC, by Mattia Verga, CC BY-SA 4.0.</p>${link('https://github.com/mattiaverga/OpenNGC', 'OpenNGC on GitHub')}</li>
          <li><p>Map tiles and place names: © OpenStreetMap contributors, via the OpenStreetMap tile servers and Nominatim.</p>${link('https://www.openstreetmap.org/copyright', 'openstreetmap.org/copyright')}</li>
          <li><p>Weather data by Open-Meteo.com (CC BY 4.0). The model used is shown with each forecast.</p>${link('https://open-meteo.com/', 'open-meteo.com')}</li>
          <li><p>Light-pollution map: lightpollutionmap.app, opened in your browser; nothing is fetched by the app.</p>${link('https://lightpollutionmap.app/', 'lightpollutionmap.app')}</li>
        </ul>
      </section>
      <section class="settings-section" aria-labelledby="settings-about-preview">
        <h2 id="settings-about-preview">In this preview</h2>
        <p class="workspace-copy">Night, Moon, weather and forecast values on these pages are sample fixtures stored with the preview, not live data. No weather, map or place-name service is contacted. Target search uses six example objects from the app's bundled catalogue. Example nights, plans and rigs are illustrative, not measurements.</p>
        <p class="workspace-copy">Preview fonts are bundled locally under the SIL Open Font License.</p>
      </section>
      <section class="settings-section" aria-labelledby="settings-about-licence">
        <h2 id="settings-about-licence">Licence</h2>
        <p class="workspace-copy">${APP.name} ${APP.version} is free software under the GNU General Public License v3.0 (GPL-3.0). You may use, study, share and change it under that licence. The Android build includes Google Play services location, used only when you tap "Use current position", under an additional permission (GPL-3.0 section 7) shown in the app.</p>
        <p class="settings-links">${link(APP.source, 'Source code')}${link(APP.privacy, 'Privacy policy')}</p>
      </section>`;
  }

  /* ----- Immediate sections: display and privacy ----- */

  function saveSection(section, value, message) {
    S.settings = { ...S.settings, [section]: value };
    let note;
    try {
      note = mutate(s => ({ ...s, [section]: value }));
    } catch (error) {
      // Shown now, but not stored (F21 A5/A6); Try again stores it.
      S.unsaved = { ...S.unsaved, [section]: `${section === 'display' ? 'Shown now, but not saved' : 'Applied now, but not saved'}. ${failureText(error, 'save it')}` };
      rerender();
      api.announce(S.unsaved[section]);
      return;
    }
    rerender();
    if (message) api.announce(`${message}${note}.`);
  }

  function retrySection(section) {
    S.simulateFail = false;
    const value = S.settings[section];
    const rest = { ...S.unsaved };
    delete rest[section];
    S.unsaved = rest;
    saveSection(section, value, 'Saved');
    if (!S.unsaved[section]) document.getElementById(section === 'display' ? 'settings-unit-temperature-celsius' : 'settings-place-names')?.focus();
  }

  /* ----- Dialog ----- */

  function confirmDialog({ title, message, confirm, cancel = 'Cancel', destructive = false }) {
    return new Promise(resolvePromise => {
      const dialog = document.createElement('dialog');
      dialog.className = 'settings-dialog';
      dialog.setAttribute('aria-labelledby', 'settings-dialog-title');
      dialog.setAttribute('aria-describedby', 'settings-dialog-message');
      dialog.innerHTML = `<h2 id="settings-dialog-title">${esc(title)}</h2><p id="settings-dialog-message">${esc(message)}</p>
        <div class="workspace-actions">
          <button type="button" class="secondary-button" data-dialog="cancel">${esc(cancel)}</button>
          <button type="button" class="${destructive ? 'secondary-button settings-destructive' : 'primary-button'}" data-dialog="ok">${esc(confirm)}</button>
        </div>`;
      const opener = document.activeElement;
      const finish = ok => {
        if (!dialogs.has(finish)) return;
        dialogs.delete(finish);
        if (dialog.open) dialog.close();
        dialog.remove();
        if (!ok && !disposed) opener?.focus?.();
        resolvePromise(ok);
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
    if ('prototypeBackup' in data) {
      root.dispatchEvent(new CustomEvent('culmina-backup', { bubbles: true, detail: { source: 'settings' } }));
    } else if (data.open === 'planning') {
      openPlanning();
    } else if (data.open) {
      S.backupError = '';
      show(data.open);
    } else if ('retryLoad' in data) {
      S.loadFailed = false;
      load();
      render('[data-open="appearance"]');
      api.announce('Settings loaded.');
    } else if (data.retrySection) {
      retrySection(data.retrySection);
    } else if ('cancelPlanning' in data) {
      await cancelPlanning();
    } else if ('retryPlanning' in data) {
      S.simulateFail = false;
      savePlanning();
    } else if (data.step) {
      const key = data.step, spec = PLANNING_FIELDS[key], delta = Number(data.delta);
      const [min, max] = spec.range;
      const next = Math.min(max, Math.max(min, S.draft[key] + delta));
      S.draft[key] = spec.integer ? Math.round(next) : Number(next.toFixed(3));
      rerender();
      // A limit disables its button: keep focus on the stepper's other button.
      const focused = document.activeElement;
      if (!focused || !view.contains(focused) || focused.disabled) {
        view.querySelector(`[data-step="${key}"]:not([disabled])`)?.focus();
      }
    } else if ('export' in data) {
      const name = download(S.settings);
      api.announce(`Downloaded ${name}. It contains preview settings only.`);
    } else if ('restoreCancel' in data) {
      cancelRestore();
    } else if ('restoreBackupFirst' in data) {
      const name = download(S.settings);
      api.announce(`Downloaded ${name}. You can now replace the settings.`);
      view.querySelector('[data-restore-apply]')?.focus();
    } else if ('restoreApply' in data) {
      applyRestore();
    } else if ('replaceStore' in data) {
      const sure = await confirmDialog({
        title: 'Replace the stored preview settings?',
        message: 'The unreadable preview settings are overwritten with the settings shown now. Nothing else in this browser changes.',
        confirm: 'Replace',
        destructive: true,
      });
      if (!sure || disposed) return;
      try {
        writeStore(storage, S.settings);
        S.status = 'stored';
        S.unsaved = {};
        render('[data-open="appearance"]');
        api.announce('Stored preview settings replaced.');
      } catch {
        api.announce('Browser storage refused the write; the stored settings are unchanged.');
      }
    }
  }

  function onInput(event) {
    const el = event.target;
    if (S.page === 'planning' && S.draft && el.dataset.plan) {
      const key = el.dataset.plan, value = Number(el.value);
      if (validField(PLANNING_FIELDS[key], value)) S.draft[key] = value;
      refreshPlanningText(key);
    }
  }

  function onChange(event) {
    const el = event.target;
    if (el.name === 'settings-appearance') {
      const appearance = el.value;
      if (api.display.theme !== 'field') api.applyDisplay({ theme: resolve(appearance) });
      saveSection('display', { ...S.settings.display, appearance }, `Theme: ${APPEARANCES.find(([v]) => v === appearance)[1]}`);
    } else if (el.name === 'settings-scale') {
      api.applyDisplay({ scale: el.value });
      rerender();
    } else if (el.matches('[data-field-mode]')) {
      api.applyDisplay({ theme: el.checked ? 'field' : resolve(S.settings.display.appearance) });
      rerender();
      api.announce(el.checked ? 'Red field mode on.' : 'Red field mode off.');
    } else if (el.name?.startsWith('settings-unit-')) {
      const kind = el.name.slice('settings-unit-'.length);
      saveSection('display', { ...S.settings.display, units: { ...S.settings.display.units, [kind]: el.value } }, `${UNIT_TITLES[kind]} in ${el.nextElementSibling?.textContent || el.value}`);
    } else if (el.matches('[data-place-names]')) {
      saveSection('privacy', { placeNameLookup: el.checked }, `Place-name lookup ${el.checked ? 'on' : 'off'} (preview: nothing is sent)`);
    } else if (S.page === 'planning' && S.draft) {
      if (el.name === 'settings-darkness') {
        S.draft.darknessLimitDeg = Number(el.value);
        refreshPlanningText('darknessLimitDeg');
      } else if (el.dataset.planBool) {
        S.draft[el.dataset.planBool] = el.checked;
        rerender();
        refreshPlanningText(el.dataset.planBool);
      } else if (el.dataset.overhead) {
        const key = el.dataset.overhead;
        S.draft[key] = el.checked ? OVERHEAD_ON[key] : null;
        rerender();
        refreshPlanningText(key);
      }
    } else if (el.matches('[data-restore-file]')) {
      pickBackup(el.files?.[0]);
    }
  }

  function onSubmit(event) {
    if (!event.target.matches('[data-planning-form]')) return;
    event.preventDefault();
    savePlanning();
  }

  // <details> toggle does not bubble.
  function onToggle(event) {
    if (event.target.matches?.('[data-advanced]')) S.advancedOpen = event.target.open;
  }

  // Another tab changed this module's key: read it again, unless planning is
  // being edited or a restore is waiting (their saves re-read storage first).
  function onStorage(event) {
    if (event.key !== STORAGE_KEY && event.key !== null) return;
    if (scenario === 'empty' || S.loadFailed || S.page === 'planning' || S.page === 'restore') return;
    load();
    S.unsaved = {};
    rerender();
    api.announce('Preview settings updated from another tab.');
  }

  // System appearance follows the device while it is chosen.
  function onSystemTheme() {
    if (S.settings.display.appearance === 'system' && api.display.theme !== 'field') api.applyDisplay({ theme: systemTheme() });
    if (S.page === 'appearance' || S.page === 'root') rerender();
  }

  // The lab toolbar can change theme or text size while a page is open.
  const observer = new MutationObserver(() => {
    if (!disposed && (S.page === 'appearance' || S.page === 'root')) rerender();
  });

  function onBeforeUnload(event) {
    if (planningDirty()) event.preventDefault();
  }

  root.addEventListener('click', onClick);
  root.addEventListener('input', onInput);
  root.addEventListener('change', onChange);
  root.addEventListener('submit', onSubmit);
  root.addEventListener('toggle', onToggle, true);
  window.addEventListener('storage', onStorage);
  window.addEventListener('beforeunload', onBeforeUnload);
  media?.addEventListener?.('change', onSystemTheme);
  observer.observe(document.documentElement, { attributes: true, attributeFilter: ['data-theme', 'data-text-scale'] });

  load();
  render();

  return function cleanup() {
    disposed = true;
    for (const finish of [...dialogs]) finish(false);
    observer.disconnect();
    root.removeEventListener('click', onClick);
    root.removeEventListener('input', onInput);
    root.removeEventListener('change', onChange);
    root.removeEventListener('submit', onSubmit);
    root.removeEventListener('toggle', onToggle, true);
    window.removeEventListener('storage', onStorage);
    window.removeEventListener('beforeunload', onBeforeUnload);
    media?.removeEventListener?.('change', onSystemTheme);
  };
}
