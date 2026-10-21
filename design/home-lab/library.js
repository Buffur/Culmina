// Library tab of Culmina's Android browser prototype: mountLibrary(root, api).
//
// Functional reference (production Flutter, read-only here):
// lib/presentation/screens/library/library_screen.dart (Rigs / Targets / Sites),
// screens/equipment/equipment_selection_screen.dart + equipment_editor.dart +
// add_rig_panel.dart, shared/equipment_form_input.dart, shared/rig_input_text.dart,
// domain/models/equipment_limits.dart (ranges, resolveAperture), camera_class.dart,
// tracking_type.dart; screens/target/target_selection_screen.dart,
// shared/target_form_input.dart, core/utils/astro_math.dart (RA/Dec parsing and
// formatting), domain/models/target_types.dart, astro_target.dart (userEdit);
// screens/sites/sites_screen.dart + site_editor_screen.dart,
// shared/coordinate_input.dart, shared/site_form_input.dart.
//
// Rigs, your targets and sites are browser preview records kept only under
// culmina-library-preview-v1. This module never reads or writes the Plan
// preview (culmina-plan-preview-v1), navigation checkpoints, the Logbook
// preview or any application database. Explicit file selection reads JSON on
// this device; position access requires an explicit request and browser consent.
// No map, geocoding or other provider is contacted by this module.

import {targetSample, searchTargets, catalogObjectCount, rigs as planRigs} from './plan-model.js?v=20261020-hybrid7';

const STORAGE_KEY = 'culmina-library-preview-v1';
const PAYLOAD_KIND = 'culmina-library-preview';
const PAYLOAD_VERSION = 1;
const SCENARIOS = ['ready', 'empty', 'error', 'storage-error'];
const MEMORY_ONLY = ['unreadable', 'unavailable', 'scenario'];
const RECORD_ID = /^(example|local)-[a-z0-9-]{1,64}$/;
const MAX_TEXT = 200; // prototype guard only
const MAX_NOTES = 4000; // prototype guard only

// CameraClass (camera_class.dart) and TrackingType (tracking_type.dart).
const CAMERA_CLASSES = [
  ['phone', 'Phone'],
  ['dslrMirrorless', 'DSLR or mirrorless'],
  ['astroColour', 'Astro camera (colour)'],
  ['astroMono', 'Astro camera (mono)'],
  ['unknown', 'Unknown'],
];
const CLASS_LABEL = Object.fromEntries(CAMERA_CLASSES);
const offersNoiseReduction = c => c === 'dslrMirrorless' || c === 'unknown';
const TRACKING = [
  ['untracked', 'Untracked (fixed tripod)'],
  ['tracked', 'Tracked (unguided mount)'],
  ['guided', 'Guided'],
  ['unknown', 'Unknown'],
];
const TRACKING_LABEL = Object.fromEntries(TRACKING);
// CaptureFormat labels (equipment_editor.dart captureFormatLabel).
const CAPTURE_FORMATS = [
  ['dngUncompressed16', 'Uncompressed DNG, 16-bit'],
  ['fits16', 'FITS, 16-bit integer'],
  ['fits32float', 'FITS, 32-bit float'],
  ['compressedRaw', 'Compressed RAW (CR3, NEF, ARW …)'],
  ['jpegHeic', 'JPEG or HEIC'],
];
const FORMAT_LABEL = Object.fromEntries(CAPTURE_FORMATS);
// EquipmentLimits (ADR-011 §4): input sanity bounds, not physics.
const LIMITS = {
  focalRatio: [0.5, 32], apertureMm: [1, 2000], focalLengthMm: [1, 20000], pixelUm: [0.5, 30],
  sensorMm: [1, 100], resolutionPx: [100, 30000], maxExposureS: [1, 3600], rawFileSizeMB: [0.1, 1000], rotationDeg: [-360, 360],
};
// RigInputText.reason: why each required input is asked for.
const REASONS = {
  resolution: 'Needed for the pixel-size check and the storage estimate',
  pixel: 'Needed for the image scale and the exposure guide (NPF)',
  sensor: 'Needed for the field of view and framing',
  focal: 'Needed for the field of view, image scale and exposure guide (NPF)',
  ratio: 'Needed for the exposure guide (NPF)',
};
// TargetTypes.selectable: fixed-coordinate types only for a new target.
const TARGET_TYPES = ['Galaxy', 'Nebula', 'Globular Cluster', 'Open Cluster', 'Star', 'Other'];
const MOVING_TYPES = ['Planet', 'Moon', 'Comet', 'Asteroid'];
const MOVING_WARNING = 'Fixed coordinates — this object moves; positions are not tracked.';

// Catalogue values for the six sample objects, as shipped in
// assets/catalog/catalog_v2.json (164 OpenNGC-derived objects): J2000 degrees,
// apparent size in arcmin, V magnitude (null = not in the catalogue) and the
// OpenNGC row. `catalogName` is the record's own name where the sample shows
// an alias (plan-model.js keeps "Orion Nebula" for M42).
const CATALOGUE_VALUES = {
  'M27': { raDeg: 299.9015833, decDeg: 22.7210278, sizeArcmin: 6.7, vMag: 7.4, openNgc: 'NGC6853', catalogName: 'Dumbbell Nebula' },
  'M31': { raDeg: 10.6847917, decDeg: 41.2690556, sizeArcmin: 177.83, vMag: 3.44, openNgc: 'NGC0224', catalogName: 'Andromeda Galaxy' },
  'M33': { raDeg: 23.4620417, decDeg: 30.6602222, sizeArcmin: 62.09, vMag: 5.79, openNgc: 'NGC0598', catalogName: 'Triangulum Galaxy' },
  'M42': { raDeg: 83.8186667, decDeg: -5.3896667, sizeArcmin: 90.0, vMag: 4.0, openNgc: 'NGC1976', catalogName: 'Great Orion Nebula' },
  'M45': { raDeg: 56.8691667, decDeg: 24.1052778, sizeArcmin: 150.0, vMag: 1.2, openNgc: 'Mel022', catalogName: 'Pleiades' },
  'NGC 7000': { raDeg: 314.8214167, decDeg: 44.5287778, sizeArcmin: 120.0, vMag: null, openNgc: 'NGC7000', catalogName: 'North America Nebula' },
};
const CATALOGUE = targetSample.filter(t => CATALOGUE_VALUES[t.id]).map(t => Object.freeze({
  ...t, key: `catalogue:${t.id}`, bundled: true, ...CATALOGUE_VALUES[t.id],
}));

// Kept across remounts within the page.
const ui = { query: { rigs: '', targets: '', sites: '' }, undo: null, undoError: '' };
const NAVIGATION_KEY = 'culmina-library-navigation-v1';

/* ---------- Example records (fixtures, not measurements) ---------- */

const EXAMPLE_SOURCE = 'Example rig copied from the Plan preview’s fixtures (plan-model.js)';

function exampleRig(key) {
  const r = planRigs[key];
  const optics = key === 'astro' ? 'Illustrative estimate (the 72 mm f/5.6 refractor), not a measurement'
    : r.focalLengthMm !== null ? 'Example: only the lens focal length in its name is recorded' : 'Not recorded';
  const camera = key === 'astro' ? 'Example: the app’s shipped example camera, values verified from the maker' : 'Not recorded';
  return {
    id: `example-rig-${key}`, example: true, name: r.name, manufacturer: null, cameraModel: r.cameraModel,
    cameraClass: r.cameraClass, noiseReduction: false,
    resolutionPx: r.resolutionPx ? [...r.resolutionPx] : null, pixelUm: r.pixelUm, sensorMm: r.sensorMm ? [...r.sensorMm] : null,
    focalLengthMm: r.focalLengthMm, focalRatio: r.focalRatio, apertureMm: r.apertureMm,
    tracking: r.tracking ?? 'unknown', maxExposureS: null, rawFileSizeMB: null, captureFormat: null, rotationDeg: null,
    provenance: { record: EXAMPLE_SOURCE, camera, optics },
  };
}

// The example sites of the Plan/Logbook previews (logbook.js coordinates;
// zone from night-model.js). Values not in those fixtures stay unknown.
function exampleSites() {
  const source = 'Example site from the Plan and Logbook preview fixtures';
  return [
    { id: 'example-site-kyiv', example: true, name: 'Kyiv outskirts', latDeg: 50.4, lonDeg: 30.6, elevationM: null, zone: 'Europe/Kyiv',
      bortle: null, bortleSource: null, sqm: null, sqmSource: null, notes: null, provenance: source },
    { id: 'example-site-rural', example: true, name: 'Rural site', latDeg: 50.8, lonDeg: 30.95, elevationM: 160, zone: 'Europe/Kyiv',
      bortle: 4, bortleSource: 'Example fixture value', sqm: null, sqmSource: null, notes: null, provenance: source },
  ];
}

function exampleData() {
  return { rigs: ['dslr', 'phone', 'astro', 'unknown'].map(exampleRig), targets: [], sites: exampleSites() };
}

/* ---------- Isolated local persistence ---------- */

const isString = v => typeof v === 'string';
const optString = v => v === null || isString(v);
const optNumber = v => v === null || Number.isFinite(v);
const optPair = v => v === null || (Array.isArray(v) && v.length === 2 && v.every(Number.isFinite));
const validId = v => isString(v) && RECORD_ID.test(v);

function validRig(r) {
  return !!r && validId(r.id) && typeof r.example === 'boolean' && isString(r.name) && optString(r.manufacturer) && optString(r.cameraModel) &&
    Object.hasOwn(CLASS_LABEL, r.cameraClass) && typeof r.noiseReduction === 'boolean' && optPair(r.resolutionPx) && optPair(r.sensorMm) &&
    ['pixelUm', 'focalLengthMm', 'focalRatio', 'apertureMm', 'maxExposureS', 'rawFileSizeMB', 'rotationDeg'].every(k => optNumber(r[k])) &&
    Object.hasOwn(TRACKING_LABEL, r.tracking) && (r.captureFormat === null || Object.hasOwn(FORMAT_LABEL, r.captureFormat)) &&
    !!r.provenance && ['record', 'camera', 'optics'].every(k => isString(r.provenance[k]));
}

function validTarget(t) {
  return !!t && validId(t.id) && isString(t.catalogId) && isString(t.name) && (TARGET_TYPES.includes(t.type) || MOVING_TYPES.includes(t.type)) &&
    Number.isFinite(t.raDeg) && t.raDeg >= 0 && t.raDeg < 360 && Number.isFinite(t.decDeg) && Math.abs(t.decDeg) <= 90 &&
    optNumber(t.sizeArcmin) && optNumber(t.magnitude) && t.source === 'user';
}

function validSite(s) {
  return !!s && validId(s.id) && typeof s.example === 'boolean' && isString(s.name) &&
    Number.isFinite(s.latDeg) && Math.abs(s.latDeg) <= 90 && Number.isFinite(s.lonDeg) && Math.abs(s.lonDeg) <= 180 &&
    optNumber(s.elevationM) && optString(s.zone) && (s.bortle === null || (Number.isInteger(s.bortle) && s.bortle >= 1 && s.bortle <= 9)) &&
    optString(s.bortleSource) && optNumber(s.sqm) && optString(s.sqmSource) && optString(s.notes) && isString(s.provenance);
}

const uniqueIds = list => new Set(list.map(x => x.id)).size === list.length;

function validPayload(v) {
  return v?.kind === PAYLOAD_KIND && v.version === PAYLOAD_VERSION &&
    Array.isArray(v.rigs) && v.rigs.every(validRig) && uniqueIds(v.rigs) &&
    Array.isArray(v.targets) && v.targets.every(validTarget) && uniqueIds(v.targets) &&
    Array.isArray(v.sites) && v.sites.every(validSite) && uniqueIds(v.sites);
}

// Shared with the checked full-prototype backup. Accepts JSON text or a parsed envelope.
export function validateLibraryPayload(raw) {
  try { return validPayload(typeof raw === 'string' ? JSON.parse(raw) : raw); }
  catch { return false; }
}

// status: 'stored' (our key, valid), 'examples' (no key yet), 'unreadable'
// (malformed payload, kept untouched), 'unavailable' (storage threw).
function readStore(storage) {
  let raw;
  try {
    raw = storage.getItem(STORAGE_KEY);
  } catch {
    return { status: 'unavailable', data: exampleData() };
  }
  if (raw === null) return { status: 'examples', data: exampleData() };
  try {
    const value = JSON.parse(raw);
    if (validPayload(value)) return { status: 'stored', data: { rigs: value.rigs, targets: value.targets, sites: value.sites } };
  } catch { /* malformed JSON: reported, never overwritten */ }
  return { status: 'unreadable', data: exampleData() };
}

function writeStore(storage, data) {
  storage.setItem(STORAGE_KEY, JSON.stringify({ kind: PAYLOAD_KIND, version: PAYLOAD_VERSION, ...data }));
}

class PreviewFailure extends Error {
  constructor(kind) {
    super(kind);
    this.kind = kind;
  }
}

function newId() {
  return `local-${Date.now().toString(36)}-${Math.random().toString(36).slice(2, 8)}`;
}

/* ---------- Parsing and validation (mirrors of the production inputs) ---------- */

// EquipmentFormInput.parse / CoordinateInput.parse: a decimal, comma accepted;
// null when empty, NaN when it does not parse (never a silent 0).
function number(text) {
  const s = String(text ?? '').trim().replace(/,/g, '.');
  if (!s) return null;
  if (!/^[+-]?(\d+\.?\d*|\.\d+)(e[+-]?\d+)?$/i.test(s)) return NaN;
  const v = Number(s);
  return Number.isFinite(v) ? v : NaN;
}

const fmt = v => (Number.isInteger(v) ? String(v) : String(v));
const rangeMessage = ([min, max], unit) => `Must be ${fmt(min)}–${fmt(max)}${unit ? ` ${unit}` : ''}`;
const inRange = (v, [min, max]) => Number.isFinite(v) && v >= min && v <= max;

function requiredNumber(text, range, unit) {
  const v = number(text);
  if (v === null) return 'Required';
  if (Number.isNaN(v)) return 'Enter a number';
  return inRange(v, range) ? null : rangeMessage(range, unit);
}

function optionalNumber(text, range, unit) {
  const v = number(text);
  if (v === null) return null;
  if (Number.isNaN(v)) return 'Enter a number';
  return inRange(v, range) ? null : rangeMessage(range, unit);
}

function validateResolution(text) {
  const s = String(text ?? '').trim();
  if (!s) return 'Required';
  if (!/^\d+$/.test(s)) return 'Enter whole pixels, e.g. 6248';
  return inRange(Number(s), LIMITS.resolutionPx) ? null : rangeMessage(LIMITS.resolutionPx, 'px');
}

// resolveAperture (equipment_limits.dart, ADR-011 §4).
function resolveAperture(focal, ratio, diameter) {
  if (diameter !== null) {
    if (!inRange(diameter, LIMITS.apertureMm)) return { problem: 'Diameter must be 1–2000 mm' };
    const derived = focal / diameter;
    if (ratio !== null && Math.abs(derived - ratio) / ratio > 0.01) {
      return { problem: 'Focal length ÷ diameter does not match the focal ratio (within 1 %)' };
    }
    if (!inRange(derived, LIMITS.focalRatio)) return { problem: 'Focal ratio must be f/0.5–f/32 — check the focal length and diameter' };
    return { ratio: derived, diameter };
  }
  if (ratio === null) return { problem: 'Enter the focal ratio (f/) or the diameter (mm)' };
  if (!inRange(ratio, LIMITS.focalRatio)) return { problem: 'Focal ratio must be f/0.5–f/32 — check the focal length and diameter' };
  return { ratio, diameter: null };
}

// EquipmentDraft.sensorSizeText: resolution × pixel size.
function sensorText(w, h, pixel) {
  const rw = /^\d+$/.test(String(w).trim()) ? Number(String(w).trim()) : null;
  const rh = /^\d+$/.test(String(h).trim()) ? Number(String(h).trim()) : null;
  const p = number(pixel);
  if (rw === null || rh === null || !(p > 0)) return null;
  return [(rw * p / 1000).toFixed(2), (rh * p / 1000).toFixed(2)];
}

// AstroMath.parseRightAscension / parseDeclination / format*.
function sexagesimalFields(text, separators) {
  const parts = text.replace(separators, ' ').trim().split(/\s+/).filter(Boolean);
  if (!parts.length || parts.length > 3) return null;
  if (!parts.every(p => /^\d+(\.\d+)?$/.test(p))) return null;
  for (let i = 0; i < parts.length - 1; i++) if (!/^\d+$/.test(parts[i])) return null;
  return parts;
}

function sexagesimal(fields) {
  const v = fields.map(Number);
  for (let i = 1; i < v.length; i++) if (v[i] >= 60) return null;
  let total = v[0];
  if (v.length > 1) total += v[1] / 60;
  if (v.length > 2) total += v[2] / 3600;
  return total;
}

function parseRightAscension(input) {
  const text = String(input).trim().toLowerCase();
  if (!text) return null;
  const degrees = /^(\d+(?:\.\d+)?)\s*(?:°|deg|d)$/u.exec(text);
  if (degrees) {
    const value = Number(degrees[1]);
    return value < 360 ? value : null;
  }
  const fields = sexagesimalFields(text.replace(/[sˢ]$/u, ''), /[hʰmᵐ:\s]/gu);
  if (!fields) return null;
  const hours = sexagesimal(fields);
  return hours === null || hours >= 24 ? null : hours * 15;
}

function parseDeclination(input) {
  let text = String(input).trim().toLowerCase();
  if (!text) return null;
  let negative = false;
  if (text.startsWith('-') || text.startsWith('\u2212')) {
    negative = true;
    text = text.slice(1);
  } else if (text.startsWith('+')) {
    text = text.slice(1);
  }
  const fields = sexagesimalFields(text.replace(/[s"\u2033]$/u, ''), /[°d'\u2032m:\s]/gu);
  if (!fields) return null;
  const degrees = sexagesimal(fields);
  if (degrees === null || degrees > 90) return null;
  return negative ? -degrees : degrees;
}

const two = n => String(n).padStart(2, '0');

function formatRightAscension(degrees) {
  let tenths = Math.round((((degrees % 360) + 360) % 360) / 15 * 36000);
  if (tenths >= 24 * 36000) tenths -= 24 * 36000;
  const h = Math.floor(tenths / 36000), m = Math.floor((tenths % 36000) / 600), s = (tenths % 600) / 10;
  return `${two(h)}h${two(m)}m${s < 10 ? '0' : ''}${s.toFixed(1)}s`;
}

function formatDeclination(degrees) {
  const seconds = Math.round(Math.abs(degrees) * 3600);
  const sign = degrees < 0 && seconds > 0 ? '\u2212' : '+';
  return `${sign}${two(Math.floor(seconds / 3600))}°${two(Math.floor((seconds % 3600) / 60))}\u2032${two(seconds % 60)}\u2033`;
}

function validateRightAscension(text) {
  if (!String(text ?? '').trim()) return 'Right ascension is required (hours, or degrees with °).';
  return parseRightAscension(text) === null ? 'Use hours: 05h35m17s, 5:35:17 or 5.588 (or degrees: 83.82°)' : null;
}

function validateDeclination(text) {
  if (!String(text ?? '').trim()) return 'Declination is required (degrees).';
  return parseDeclination(text) === null ? 'Use −05°23′28″, -5:23:28 or -5.391 (within ±90°)' : null;
}

function validateAngularSize(text) {
  const v = number(text);
  if (v === null) return null;
  if (Number.isNaN(v)) return 'Enter arcminutes, e.g. 85';
  return v <= 0 || v > 3000 ? 'Must be above 0 and at most 3000′' : null;
}

function validateMagnitude(text) {
  const v = number(text);
  if (v === null) return null;
  if (Number.isNaN(v)) return 'Enter a magnitude, e.g. 4.0';
  return v < -30 || v > 30 ? 'Must be between −30 and 30' : null;
}

function validateCoordinate(text, min, max, name) {
  const v = number(text);
  if (v === null) return `${name} is required`;
  if (Number.isNaN(v)) return 'Enter decimal degrees, e.g. 46.05';
  return v < min || v > max ? `${name} must be between ${min} and ${max}` : null;
}

function validateElevation(text) {
  const v = number(text);
  if (v === null) return null;
  if (Number.isNaN(v)) return 'Enter metres, e.g. 295';
  return v < -500 || v > 9000 ? 'Elevation must be between -500 and 9000 m' : null;
}

function validateSqm(text) {
  const v = number(text);
  if (v === null) return null;
  if (Number.isNaN(v)) return 'Enter mag/arcsec², e.g. 21.2';
  return v < 15 || v > 23 ? 'SQM must be between 15 and 23' : null;
}

function validZone(zone) {
  try {
    new Intl.DateTimeFormat('en-GB', { timeZone: zone });
    return true;
  } catch {
    return false;
  }
}

function zoneOptions(current) {
  let list = [];
  try {
    list = Intl.supportedValuesOf('timeZone');
  } catch { /* older engines: the fallback below */ }
  const browserZone = Intl.DateTimeFormat().resolvedOptions().timeZone;
  return [...new Set([...list, browserZone, 'Europe/Kyiv', 'UTC', ...(current ? [current] : [])])].filter(validZone).sort();
}

/* ---------- Wording and units ---------- */

const NOT_RECORDED = 'Not recorded';
const trimNumber = (v, digits = 6) => String(Number(v.toFixed(digits)));
const textOf = (v, digits = 6) => (v === null || v === undefined ? '' : trimNumber(v, digits));
const signed = (v, digits) => `${v < 0 ? '−' : ''}${Math.abs(v).toFixed(digits)}`;

function coordinates(lat, lon) {
  return `${signed(lat, 5)}°, ${signed(lon, 5)}°`;
}

function rigSubtitle(r) {
  const parts = [CLASS_LABEL[r.cameraClass] === 'Unknown' ? 'Camera type unknown' : CLASS_LABEL[r.cameraClass]];
  if (r.manufacturer) parts.push(r.manufacturer);
  if (r.cameraModel) parts.push(r.cameraModel);
  if (r.resolutionPx) parts.push(`${r.resolutionPx[0]}×${r.resolutionPx[1]} px`);
  if (r.pixelUm !== null) parts.push(`${trimNumber(r.pixelUm)} µm`);
  if (r.focalLengthMm !== null) parts.push(`${trimNumber(r.focalLengthMm)} mm`);
  if (r.focalRatio !== null) parts.push(`f/${trimNumber(r.focalRatio, 2)}`);
  if (r.resolutionPx === null && r.pixelUm === null && r.focalLengthMm === null) parts.push('sensor and optics not recorded');
  return parts.join(' · ');
}

const targetLabel = t => {
  const designation = t.catalogId ?? t.id;
  return designation && t.name !== designation ? `${t.name} (${designation})` : t.name;
};
const localDate = () => new Intl.DateTimeFormat('en-GB', { day: 'numeric', month: 'short', year: 'numeric' }).format(new Date());

/* ---------- Module ---------- */

export function mountLibrary(root, api) {
  const esc = api.esc;
  const hybrid = api.variant === 'blend';
  const storage = api.storage;
  const scenario = SCENARIOS.includes(api.scenario) ? api.scenario : 'ready';
  const S = {
    view: 'root', id: null,
    edit: null, // {kind, id, from, draft, shown, initial, baseline, errors, saveError, saveMissing, moreOpen}
    loadFailed: scenario === 'error',
    simulateFail: scenario === 'storage-error',
    status: 'examples', data: { rigs: [], targets: [], sites: [] },
    deleteError: '',
  };
  const dialogs = new Set();
  let disposed = false;
  let navigationTimer;
  const scrollPositions = {};
  try {
    const nav = JSON.parse(sessionStorage.getItem(NAVIGATION_KEY));
    const allowed = ['root', 'rigs', 'targets', 'sites', 'rig', 'target', 'catalogue', 'site'];
    if (nav?.version === 1 && allowed.includes(nav.view) && (nav.id === null || typeof nav.id === 'string')) {
      S.view = nav.view;
      S.id = nav.id;
      for (const key of ['rigs', 'targets', 'sites']) if (typeof nav.query?.[key] === 'string') ui.query[key] = nav.query[key].slice(0, MAX_TEXT);
      for (const [key, value] of Object.entries(nav.scroll ?? {})) if (allowed.includes(key) && Number.isFinite(value) && value >= 0) scrollPositions[key] = value;
    }
  } catch { /* Navigation is optional; a form draft is never persisted here. */ }

  function rememberNavigation() {
    if (S.view === 'edit') return;
    try { sessionStorage.setItem(NAVIGATION_KEY, JSON.stringify({ version: 1, view: S.view, id: S.id, query: ui.query, scroll: scrollPositions })); }
    catch { /* Browsing still works when session storage is unavailable. */ }
  }

  function load() {
    if (scenario === 'empty') {
      S.status = 'scenario';
      S.data = { rigs: [], targets: [], sites: [] };
      return;
    }
    const read = readStore(storage);
    S.status = read.status;
    S.data = read.data;
  }

  const COLLECTION = { rig: 'rigs', target: 'targets', site: 'sites' };
  const find = (kind, id) => S.data[COLLECTION[kind]].find(x => x.id === id);
  const findCatalogue = id => CATALOGUE.find(t => t.key === id);
  const selector = (attr, value) => `[${attr}="${CSS.escape(value)}"]`;

  // Applies `change` to the freshest stored data, so an edit made in another
  // tab is never dropped, then writes only this module's key. Memory-only
  // states never write (a malformed payload stays as it is).
  function mutate(change) {
    if (S.simulateFail) throw new PreviewFailure('simulated');
    if (MEMORY_ONLY.includes(S.status)) {
      S.data = change(S.data);
      return ' (kept in this tab only)';
    }
    const fresh = readStore(storage);
    if (fresh.status === 'unreadable' || fresh.status === 'unavailable') {
      S.status = fresh.status;
      throw new PreviewFailure(fresh.status);
    }
    const next = change(fresh.data);
    try {
      writeStore(storage, next);
    } catch {
      throw new PreviewFailure('write');
    }
    S.data = next;
    S.status = 'stored';
    return '';
  }

  function failureText(error, action) {
    switch (error?.kind) {
      case 'simulated':
        return `Couldn't ${action}. This preview simulates a storage failure; nothing changed and your input is kept. Try again clears the simulation.`;
      case 'unreadable':
        return `Couldn't ${action}: the stored Library preview data can't be read, so it was left unchanged. Try again keeps the change in this tab only.`;
      case 'unavailable':
        return `Couldn't ${action}: browser storage is unavailable. Try again keeps the change in this tab only.`;
      default:
        return `Couldn't ${action}: this browser refused to store it. Nothing changed and your input is kept.`;
    }
  }

  /* ----- Rendering ----- */

  root.innerHTML = '<div class="library-view"></div>';
  const view = root.firstElementChild;
  const scroller = root.closest('.android-scroll');

  function show(next, { id = S.id, focus = null } = {}) {
    if (S.view !== 'edit' && scroller) scrollPositions[S.view] = scroller.scrollTop;
    rememberNavigation();
    S.view = next;
    S.id = id;
    render(focus);
    if (scroller) scroller.scrollTop = next === 'edit' ? 0 : scrollPositions[next] ?? 0;
    if (focus) view.querySelector(focus)?.scrollIntoView({ block: 'nearest' });
    rememberNavigation();
  }

  const LIST_OF = { rig: 'rigs', target: 'targets', catalogue: 'targets', site: 'sites' };
  const LIST_TITLE = { rigs: 'Rigs', targets: 'Targets', sites: 'Sites' };

  function render(focus = null) {
    const v = S.view;
    if (v === 'root') {
      api.setHeader('Library');
      view.innerHTML = rootView();
    } else if (v === 'rigs' || v === 'targets' || v === 'sites') {
      api.setHeader(LIST_TITLE[v], () => show('root', { focus: selector('data-open-list', v) }));
      view.innerHTML = listView(v);
      renderResults();
    } else if (v === 'rig' || v === 'target' || v === 'catalogue' || v === 'site') {
      const record = v === 'catalogue' ? findCatalogue(S.id) : find(v, S.id);
      const title = !record ? LIST_TITLE[LIST_OF[v]] : v === 'rig' || v === 'site' ? record.name : targetLabel(record);
      const backTo = LIST_OF[v];
      api.setHeader(title, () => show(backTo, { focus: selector('data-open', `${v}:${S.id}`) }));
      view.innerHTML = record ? detailView(v, record) : missingView(backTo);
    } else if (v === 'edit') {
      const e = S.edit;
      const words = { rig: ['Add rig', 'Edit rig'], target: ['Add target', 'Edit target'], site: ['New site', 'Edit site'] }[e.kind];
      api.setHeader(words[e.id ? 1 : 0], () => cancelEdit());
      view.innerHTML = editView();
    }
    const target = (focus && view.querySelector(focus)) || (S.view !== 'root' && !LIST_TITLE[S.view] && view.querySelector('[data-focus-start]')) || null;
    target?.focus({ preventScroll: true });
  }

  function previewNote() {
    const notice = {
      unreadable: `<div class="workspace-error" role="status"><p>The stored Library preview data can't be read. It is kept unchanged: the example records are shown and changes stay in this tab only.</p>
        <div class="workspace-actions"><button type="button" class="secondary-button" data-replace-store>Replace stored data with these records</button></div></div>`,
      unavailable: '<div class="workspace-error" role="status"><p>Browser storage is unavailable here, so changes stay in this tab only.</p></div>',
      scenario: '<p class="library-note">Empty scenario: no rigs, sites or added targets are shown. Stored preview data is untouched; the bundled catalogue sample stays.</p>',
    }[S.status] || '';
    return `<p class="library-note">Example library · saved in this browser. Your plan stays unchanged.</p>${notice}`;
  }

  function rootView() {
    const sites = S.data.sites.length;
    const rows = [
      ['rigs', 'camera', 'Rigs', 'Your cameras with their lenses or telescopes'],
      ['targets', 'target', 'Targets', 'The catalogue and the targets you added'],
      ['sites', 'pin', 'Sites', hybrid && S.loadFailed ? 'Count unavailable · choose the planning site in Plan' : hybrid && S.status !== 'stored' ? `${sites} example sites · choose the planning site in Plan` : `${sites} saved · the site used for planning is chosen in the Plan`],
    ];
    return `${hybrid && S.loadFailed ? loadFailureView('Library') : previewNote()}
      <nav class="library-root" aria-label="Library">
        ${rows.map(([key, symbol, title, caption]) => `<button type="button" class="workspace-row library-row" data-open-list="${key}">
          ${api.icon(symbol)}<span class="library-row-text"><span class="library-row-title">${title}</span><span class="workspace-copy">${esc(caption)}</span></span>${api.icon('next')}
        </button>`).join('')}
      </nav>
      <p class="library-note library-footnote">Progress by target lives in the Logbook.</p>`;
  }

  function loadFailureView(list) {
    return `<div class="workspace-error" role="alert"><p>Couldn't load the ${list}.</p>
      <p class="workspace-copy">This is the preview's simulated load failure; stored records are untouched.</p>
      <div class="workspace-actions"><button type="button" class="secondary-button" data-retry-load>Try again</button></div></div>`;
  }

  function listView(list) {
    if (S.loadFailed) return loadFailureView(list);
    const placeholders = { rigs: 'Name, maker or model', targets: 'Designation or name, e.g. M31 or Andromeda', sites: 'Name, time zone or notes' };
    const add = { rigs: ['rig', 'Add rig'], targets: ['target', 'Add target'], sites: ['site', 'Add site'] }[list];
    const extra = {
      rigs: `<details class="library-disclosure"><summary>Adding a rig from a photo</summary>
          <p class="workspace-copy">In the app, Add rig offers “From a photo”: a JPEG, HEIC or DNG file (or a FITS sub-frame) is read on the device and its values are proposed for you to confirm; other RAW files (CR3, NEF, ARW …) are not read, and nothing is guessed. ${hybrid ? 'In this preview, From a photo demonstrates the review with labelled sample values; image bytes are not parsed. Import rig values from JSON is a separate local file-reading workflow. Manual entry remains available.' : 'This browser preview reads no files, so a rig is entered by hand here.'}</p></details>`,
      targets: `<p class="library-note">Catalogue: a sample of ${CATALOGUE.length} objects from the app's ${catalogObjectCount}-object bundled catalogue (OpenNGC-derived). Search here covers this sample and the targets you added, not the whole catalogue or any online service.</p>`,
      sites: '<p class="library-note">In the app a site can also take the current position or a map point. This preview makes no location, map or place-name requests: type the coordinates. Adding a site here never makes it the site used for planning.</p>',
    }[list];
    const storageWarning = hybrid && ['unreadable', 'unavailable'].includes(S.status);
    return `${hybrid ? storageWarning ? previewNote() : '' : previewNote() + extra}
      <div class="workspace-toolbar">
        <div class="library-search-field">
          <label class="block-input library-search"><span class="library-hidden">Search ${list}</span>
            <input type="search" data-search="${list}" value="${esc(ui.query[list])}" placeholder="${placeholders[list]}" autocomplete="off" enterkeyhint="search">
          </label>
          <span class="library-search-mark">${api.icon('search')}</span>
        </div>
      </div>
      <div class="workspace-actions library-add"><button type="button" class="primary-button" data-add="${add[0]}">${api.icon('plus')}<span>${add[1]}</span></button></div>
      <p class="library-count" data-result-count aria-live="polite"></p>
      <div data-results></div>${hybrid ? `<details class="library-disclosure"><summary>Sources and preview limits</summary>${storageWarning ? '' : previewNote()}${extra}</details>` : ''}`;
  }

  function matchesText(q, values) {
    const lower = q.trim().toLowerCase();
    return !lower || values.some(v => !!v && v.toLowerCase().includes(lower));
  }

  // Updates only the results, so the search field keeps its caret and IME state.
  function renderResults() {
    const box = view.querySelector('[data-results]');
    if (!box) return;
    const list = S.view, q = ui.query[list];
    let html = undoView(list), shown = 0, total = 0;
    const row = (open, title, caption, extra = '') => `<li><button type="button" class="workspace-row library-row" data-open="${esc(open)}">
      <span class="library-row-text"><span class="library-row-title">${esc(title)}</span><span class="workspace-copy">${esc(caption)}</span>${extra}</span></button></li>`;
    if (list === 'rigs') {
      const rigs = S.data.rigs.filter(r => matchesText(q, [r.name, r.manufacturer, r.cameraModel, CLASS_LABEL[r.cameraClass]]));
      total = S.data.rigs.length;
      shown = rigs.length;
      if (!total) html += '<div class="workspace-empty"><p>No rigs yet. Add your camera with its lens or telescope.</p></div>';
      else if (rigs.length) html += `<ul class="library-list">${rigs.map(r => row(`rig:${r.id}`, r.name, rigSubtitle(r), r.example ? '<span class="library-caption">Example rig</span>' : '')).join('')}</ul>`;
    } else if (list === 'sites') {
      const sites = S.data.sites.filter(s => matchesText(q, [s.name, s.zone, s.notes]));
      total = S.data.sites.length;
      shown = sites.length;
      if (!total) html += '<div class="workspace-empty"><p>No saved sites yet. Add one with “Add site”.</p></div>';
      else if (sites.length) html += `<ul class="library-list">${sites.map(s => row(`site:${s.id}`, s.name, `${coordinates(s.latDeg, s.lonDeg)} · ${s.zone ?? 'zone unknown'}`, s.example ? '<span class="library-caption">Example site</span>' : '')).join('')}</ul>`;
    } else {
      // TargetSearch over this sample and your targets: exact designation,
      // designation prefix, then name substring.
      const own = S.data.targets.map(t => ({ ...t, id: t.catalogId, key: t.id, aliasIds: [], aliasNames: t.name !== t.catalogId ? [t.name] : [] }));
      const ownFound = searchTargets(q, own), catFound = searchTargets(q, CATALOGUE);
      total = own.length + CATALOGUE.length;
      shown = ownFound.length + catFound.length;
      html += `<section class="library-group" aria-labelledby="library-own"><h2 id="library-own">Your targets</h2>
        ${!own.length ? '<p class="workspace-copy">None added yet. Add a target with its J2000 coordinates.</p>'
          : ownFound.length ? `<ul class="library-list">${ownFound.map(t => row(`target:${t.key}`, targetLabel({ ...t, catalogId: t.id }), MOVING_TYPES.includes(t.type) ? `${t.type} · ${MOVING_WARNING}` : t.type)).join('')}</ul>`
          : '<p class="workspace-copy">None of your targets match.</p>'}</section>
        <section class="library-group" aria-labelledby="library-catalogue"><div class="library-group-head"><h2 id="library-catalogue">Catalogue sample</h2>
        <p class="library-caption">${CATALOGUE.length} of ${catalogObjectCount} bundled objects · read-only</p></div>
        ${catFound.length ? `<ul class="library-list">${catFound.map(t => row(`catalogue:${t.key}`, t.name !== t.id ? `${t.name} (${t.id})` : t.id, t.type)).join('')}</ul>`
          : '<p class="workspace-copy">No sample object matches. The app searches all bundled objects.</p>'}</section>`;
    }
    if (list !== 'targets' && total && !shown) {
      html += `<div class="workspace-empty"><p>Nothing matches “${esc(q.trim())}”.</p>
        <div class="workspace-actions"><button type="button" class="secondary-button" data-clear-search>Clear search</button></div></div>`;
    }
    box.innerHTML = html;
    const counter = view.querySelector('[data-result-count]');
    if (counter) counter.textContent = q.trim() ? `${shown} of ${total} shown` : '';
  }

  function undoView(list) {
    const u = ui.undo;
    if (!u || u.list !== list) return '';
    return `<div class="library-undo" role="status">
      <p>Deleted “${esc(u.title)}”.</p>
      <div class="workspace-actions"><button type="button" class="secondary-button" data-undo>Undo</button>
      <button type="button" class="quiet-button" data-dismiss-undo>Dismiss</button></div>
      ${ui.undoError ? `<p class="field-error" role="alert">${esc(ui.undoError)}</p>` : ''}</div>`;
  }

  const facts = rows => `<dl class="workspace-facts library-facts">${rows.map(([k, v, note]) =>
    `<div><dt>${esc(k)}</dt><dd>${esc(v)}${note ? `<span class="library-caption">${esc(note)}</span>` : ''}</dd></div>`).join('')}</dl>`;
  const orNot = (v, unit = '', digits = 6) => (v === null || v === undefined ? NOT_RECORDED : `${trimNumber(v, digits)}${unit}`);

  function missingView(list) {
    return `<div class="workspace-empty"><p data-focus-start tabindex="-1">This record no longer exists.</p>
      <div class="workspace-actions"><button type="button" class="secondary-button" data-back-list="${list}">Back to ${LIST_TITLE[list]}</button></div></div>`;
  }

  const SNAPSHOT_NOTE = 'Editing here never selects a record in the Plan or rewrites a saved plan or Logbook snapshot.';

  // Logbook rule (owner, 2026-10-21): the main action right after the header; Delete last.
  function editAction(kind, record, noun) {
    return `<div class="workspace-actions library-record-actions library-edit-action">
        <button type="button" class="primary-button" data-edit="${kind}:${esc(record.id)}">${api.icon('edit')}<span>Edit ${noun}</span></button></div>`;
  }

  function actionsView(kind, record, noun) {
    return `<section class="library-section library-delete">
      <div class="workspace-actions library-record-actions">
        <button type="button" class="secondary-button library-destructive" data-delete="${kind}:${esc(record.id)}">${api.icon('trash')}<span>Delete ${noun}</span></button>
      </div>
      ${S.deleteError ? `<div class="workspace-error" role="alert"><p>${esc(S.deleteError)}</p>
        <div class="workspace-actions"><button type="button" class="secondary-button" data-retry-delete="${kind}:${esc(record.id)}">Try again</button></div></div>` : ''}
    </section>`;
  }

  function detailView(kind, x) {
    if (kind === 'rig') {
      const sensor = x.sensorMm ? `${trimNumber(x.sensorMm[0], 2)} × ${trimNumber(x.sensorMm[1], 2)} mm` : NOT_RECORDED;
      const cameraRows = [
        ['Camera type', CLASS_LABEL[x.cameraClass]],
        ...(x.manufacturer ? [['Manufacturer', x.manufacturer]] : []),
        ...(x.cameraModel ? [['Model', x.cameraModel]] : []),
        ...(x.resolutionPx ? [['Resolution', `${x.resolutionPx[0]} × ${x.resolutionPx[1]} px`]] : []),
        ...(x.pixelUm !== null ? [['Pixel size', orNot(x.pixelUm, ' µm')]] : []),
        ...(x.sensorMm ? [['Sensor size', sensor]] : []),
      ];
      const opticsRows = [
        ...(x.focalLengthMm !== null ? [['Effective focal length', orNot(x.focalLengthMm, ' mm')]] : []),
        ...(x.focalRatio !== null ? [['Focal ratio', `f/${trimNumber(x.focalRatio, 2)}`]] : []),
        ...(x.apertureMm !== null ? [['Aperture diameter', orNot(x.apertureMm, ' mm')]] : []),
        ['Tracking', TRACKING_LABEL[x.tracking]],
      ];
      return `<section class="library-detail" aria-labelledby="library-detail-title">
          <h2 id="library-detail-title" class="library-hidden" tabindex="-1" data-focus-start>${esc(x.name)}</h2>
          <p class="library-caption">${x.example ? 'Example rig · not a measurement' : 'Your rig · editable'}</p>
          <p class="workspace-copy">${esc(SNAPSHOT_NOTE)}</p>
          ${editAction('rig', x, 'rig')}
        </section>
        <section class="library-section" aria-labelledby="library-camera"><h2 id="library-camera">Camera</h2>
          ${facts(cameraRows)}
          ${!x.resolutionPx && x.pixelUm === null && !x.sensorMm ? '<p class="workspace-copy">Sensor values are not recorded.</p>' : ''}
        </section>
        <section class="library-section" aria-labelledby="library-optics"><h2 id="library-optics">Optics</h2>
          ${facts(opticsRows)}
          ${x.focalLengthMm === null && x.focalRatio === null && x.apertureMm === null ? '<p class="workspace-copy">Optics values are not recorded.</p>' : ''}
        </section>
        <details class="library-disclosure library-full-record"><summary>Full rig record and sources<span class="library-caption">All values, including unknowns</span></summary>
        <section class="library-section"><h3>Camera</h3>
          ${facts([
            ['Camera type', CLASS_LABEL[x.cameraClass], x.cameraClass === 'unknown' ? 'The app does not work out sensor facts from the type.' : ''],
            ['Manufacturer', x.manufacturer || NOT_RECORDED],
            ['Model', x.cameraModel || NOT_RECORDED],
            ...(offersNoiseReduction(x.cameraClass) ? [['In-camera noise reduction', x.noiseReduction ? 'On: a dark as long as each light' : 'Off']] : []),
            ['Resolution', x.resolutionPx ? `${x.resolutionPx[0]} × ${x.resolutionPx[1]} px` : NOT_RECORDED],
            ['Pixel size', orNot(x.pixelUm, ' µm')],
            ['Sensor size', sensor],
          ])}
          <p class="library-caption">Camera specs: ${esc(x.provenance.camera)}</p>
        </section>
        <section class="library-section"><h3>Optics</h3>
          ${facts([
            ['Effective focal length', orNot(x.focalLengthMm, ' mm')],
            ['Focal ratio', x.focalRatio === null ? NOT_RECORDED : `f/${trimNumber(x.focalRatio, 2)}`, x.focalRatio !== null && x.apertureMm !== null ? 'From focal length ÷ diameter' : ''],
            ['Aperture diameter', orNot(x.apertureMm, ' mm')],
            ['Tracking (default for plans)', TRACKING_LABEL[x.tracking], 'A plan may override it.'],
          ])}
          <p class="library-caption">Optics: ${esc(x.provenance.optics)}</p>
        </section>
        <section class="library-section"><h3>Optional records</h3>
          ${facts([
            ['Maximum sub-exposure', orNot(x.maxExposureS, ' s')],
            ['Average RAW file size', orNot(x.rawFileSizeMB, ' MB'), 'A measured size; empty leaves the storage estimate theoretical.'],
            ['Capture format', x.captureFormat ? FORMAT_LABEL[x.captureFormat] : NOT_RECORDED],
            ['Rotation', orNot(x.rotationDeg, '°')],
          ])}
          <p class="library-caption">Record: ${esc(x.provenance.record)}</p>
        </section></details>
        ${actionsView('rig', x, 'rig')}`;
    }
    if (kind === 'catalogue') {
      return `<section class="library-detail" aria-labelledby="library-detail-title">
          <h2 id="library-detail-title" tabindex="-1" data-focus-start>Catalogue record</h2>
          <p class="library-caption">Bundled catalogue · read-only</p>
          ${facts([
            ['Designation', x.id],
            ...(x.catalogName !== x.name ? [['Catalogue name', x.catalogName]] : []),
            ['Also known as', [...x.aliasIds, ...x.aliasNames.filter(n => n !== x.name)].join(', ') || 'None recorded'],
            ['Object type', x.type],
            ['Right ascension (J2000)', formatRightAscension(x.raDeg)],
            ['Declination (J2000)', formatDeclination(x.decDeg)],
            ['Apparent size (arcmin)', orNot(x.sizeArcmin, '′')],
            ['Magnitude (V)', orNot(x.vMag), x.vMag === null ? 'Not in the catalogue; never estimated.' : ''],
            ['Source', `OpenNGC row ${x.openNgc}, via the app’s bundled catalogue`],
          ])}
          <p class="workspace-copy">For different values, add your own target. The bundled record stays unchanged.</p>
        </section>`;
    }
    if (kind === 'target') {
      return `<section class="library-detail" aria-labelledby="library-detail-title">
          <h2 id="library-detail-title" tabindex="-1" data-focus-start>Your target</h2>
          <p class="library-caption">Editable · J2000 coordinates</p>
          <p class="workspace-copy">${esc(SNAPSHOT_NOTE)}</p>
          ${editAction('target', x, 'target')}
          ${facts([
            ...(x.catalogId !== x.name ? [['Catalogue id', x.catalogId, 'Kept from when the target was added.']] : []),
            ['Object type', x.type, MOVING_TYPES.includes(x.type) ? MOVING_WARNING : ''],
            ['Right ascension (J2000)', formatRightAscension(x.raDeg)],
            ['Declination (J2000)', formatDeclination(x.decDeg)],
            ['Apparent size (arcmin)', orNot(x.sizeArcmin, '′')],
            ['Magnitude', orNot(x.magnitude)],
          ])}
        </section>
        ${actionsView('target', x, 'target')}`;
    }
    // site
    return `<section class="library-detail" aria-labelledby="library-detail-title">
        <h2 id="library-detail-title" class="library-hidden" tabindex="-1" data-focus-start>${esc(x.name)}</h2>
        <p class="library-caption">${esc(x.example ? x.provenance : 'Added in this browser preview')}</p>
        <p class="workspace-copy">${esc(SNAPSHOT_NOTE)}</p>
        ${editAction('site', x, 'site')}
        ${facts([
          ['Latitude', `${signed(x.latDeg, 5)}°`, 'Decimal degrees, north positive'],
          ['Longitude', `${signed(x.lonDeg, 5)}°`, 'Decimal degrees, east positive'],
          ['Time zone', x.zone ?? 'Unknown — night uses mean solar time'],
        ])}
        <details class="library-disclosure"><summary>Site details<span class="library-caption">Elevation, sky darkness and notes</span></summary>
        ${facts([
          ['Elevation', x.elevationM === null ? 'Unknown' : `${trimNumber(x.elevationM, 1)} m above sea level`],
          ['Bortle class', x.bortle === null ? 'Unknown' : `Bortle ${x.bortle}`, x.bortle !== null && x.bortleSource ? `Source: ${x.bortleSource}` : ''],
          ['SQM', x.sqm === null ? 'Unknown' : `${trimNumber(x.sqm, 2)} mag/arcsec²`, x.sqm !== null && x.sqmSource ? `Source: ${x.sqmSource}` : ''],
          ['Notes', x.notes || 'None'],
        ])}
        <p class="workspace-copy">Bortle and SQM are never converted into each other.</p></details>
      </section>
      ${actionsView('site', x, 'site')}`;
  }

  /* ----- Editors ----- */

  function rigDraft(r) {
    const draft = r ? {
      name: r.name, manufacturer: r.manufacturer ?? '', cameraModel: r.cameraModel ?? '', cameraClass: r.cameraClass,
      noiseReduction: r.noiseReduction, resW: r.resolutionPx ? String(r.resolutionPx[0]) : '', resH: r.resolutionPx ? String(r.resolutionPx[1]) : '',
      pixel: textOf(r.pixelUm), focal: textOf(r.focalLengthMm), ratio: textOf(r.focalRatio, 2), diameter: textOf(r.apertureMm),
      tracking: r.tracking, maxExposure: textOf(r.maxExposureS), rawSize: textOf(r.rawFileSizeMB), captureFormat: r.captureFormat ?? '', rotation: textOf(r.rotationDeg),
    } : {
      name: '', manufacturer: '', cameraModel: '', cameraClass: '', noiseReduction: false, resW: '', resH: '', pixel: '', focal: '', ratio: '', diameter: '',
      tracking: 'unknown', maxExposure: '', rawSize: '', captureFormat: '', rotation: '',
    };
    return draft;
  }

  function targetDraft(t) {
    return t ? { name: t.name, type: t.type, ra: formatRightAscension(t.raDeg), dec: formatDeclination(t.decDeg), size: textOf(t.sizeArcmin), mag: textOf(t.magnitude) }
      : { name: '', type: TARGET_TYPES[0], ra: '', dec: '', size: '', mag: '' };
  }

  function siteDraft(s) {
    return s ? { name: s.name, lat: s.latDeg.toFixed(5), lon: s.lonDeg.toFixed(5), elevation: textOf(s.elevationM, 1), zone: s.zone ?? '', bortle: s.bortle === null ? '' : String(s.bortle), sqm: textOf(s.sqm), notes: s.notes ?? '' }
      // A new site's zone defaults to this browser's zone, as the app uses the
      // device zone: a pre-filled choice, not a change.
      : { name: '', lat: '', lon: '', elevation: '', zone: validZone(Intl.DateTimeFormat().resolvedOptions().timeZone) ? Intl.DateTimeFormat().resolvedOptions().timeZone : '', bortle: '', sqm: '', notes: '' };
  }

  const dirty = () => S.view === 'edit' && !!S.edit && JSON.stringify(S.edit.draft) !== S.edit.initial;

  function openEditor(kind, id, from) {
    const record = id ? find(kind, id) : null;
    if (id && !record) return;
    const draft = kind === 'rig' ? rigDraft(record) : kind === 'target' ? targetDraft(record) : siteDraft(record);
    S.edit = {
      kind, id, from, draft, shown: { ...draft }, initial: JSON.stringify(draft), baseline: record ? JSON.stringify(record) : null,
      errors: {}, saveError: '', saveMissing: false, moreOpen: false, metadataOpen: false, metadata: null, metadataError: '', metadataBusy: false,
      locationOpen: false, locationBusy: false, locationMessage: '', zoneFromBrowser: kind === 'site' && !id && !!draft.zone,
    };
    S.deleteError = '';
    show('edit');
  }

  function leaveEditor(message, savedId = null) {
    const e = S.edit;
    S.edit = null;
    const list = COLLECTION[e.kind];
    if (savedId) {
      show(e.kind, { id: savedId });
    } else if (e.from === 'detail' && find(e.kind, e.id)) {
      show(e.kind, { id: e.id, focus: '[data-edit]' });
    } else {
      show(list, { focus: '[data-add]' });
    }
    if (message) api.announce(message);
  }

  async function cancelEdit() {
    if (dirty()) {
      const e = S.edit;
      const label = e.draft.name.trim() || (e.kind === 'rig' ? 'this rig' : e.kind === 'target' ? 'this target' : 'this site');
      const choice = await choiceDialog({
        title: 'Unsaved changes',
        message: `Your changes to “${label}” are not saved.`,
        buttons: [['cancel', 'Cancel', 'secondary'], ['discard', 'Discard', 'secondary'], ['save', 'Save', 'primary']],
      });
      if (disposed || S.view !== 'edit' || S.edit !== e) return;
      if (choice === 'save') {
        save();
        return;
      }
      if (choice !== 'discard') return;
    }
    leaveEditor('');
  }

  function fieldError(key) {
    const e = S.edit.errors[key];
    return e ? `<span class="field-error" id="library-error-${key}">${esc(e)}</span>` : '';
  }

  function described(key, hint) {
    const ids = [hint ? `library-hint-${key}` : '', S.edit.errors[key] ? `library-error-${key}` : ''].filter(Boolean).join(' ');
    return `${S.edit.errors[key] ? ' aria-invalid="true"' : ''}${ids ? ` aria-describedby="${ids}"` : ''}`;
  }

  function input(key, label, { hint = '', mode = 'text', readonly = false, placeholder = '' } = {}) {
    const d = S.edit.draft;
    return `<label class="block-input">${esc(label)}
      <input type="text" data-field="${key}" value="${esc(d[key])}"${mode !== 'text' ? ` inputmode="${mode}"` : ''}${placeholder ? ` placeholder="${esc(placeholder)}"` : ''} autocomplete="off"${readonly ? ' readonly' : ''}${described(key, hint)}>
      ${hint ? `<span class="field-hint" id="library-hint-${key}">${esc(hint)}</span>` : ''}${fieldError(key)}</label>`;
  }

  function saveBar(label) {
    const e = S.edit;
    return `${e.saveError ? `<div class="workspace-error" role="alert"><p>${esc(e.saveError)}</p>
        <div class="workspace-actions">${e.saveMissing ? `<button type="button" class="secondary-button" data-back-list="${COLLECTION[e.kind]}">Back to ${LIST_TITLE[COLLECTION[e.kind]]}</button>` : '<button type="button" class="secondary-button" data-retry-save>Try again</button>'}</div></div>` : ''}
      <div class="workspace-actions library-form-actions">
        <button type="button" class="secondary-button" data-cancel-edit>Cancel</button>
        <button type="submit" class="primary-button">${label}</button>
      </div>`;
  }

  function editView() {
    const e = S.edit;
    if (e.id && !find(e.kind, e.id) && !e.saveMissing) return missingView(COLLECTION[e.kind]);
    if (e.kind === 'rig') return rigForm();
    if (e.kind === 'target') return targetForm();
    return siteForm();
  }

  function rigForm() {
    const e = S.edit, d = e.draft, isNew = !e.id, record = e.id ? find('rig', e.id) : null;
    const sensor = derivedSensor();
    const diameterSet = !!d.diameter.trim();
    return `<form class="workspace-form library-form" data-edit-form novalidate>
      <p class="workspace-copy" tabindex="-1" data-focus-start>${isNew ? 'Add the camera, sensor and optics. Unknown values are never guessed.' : 'Untouched values stay as recorded.'}${record?.example ? ' Example rig: missing values remain unknown.' : ''}</p>
      ${input('name', 'Rig name', { placeholder: 'e.g. DSLR rig' })}
      <fieldset class="library-choices"${described('cameraClass', 'x')}><legend>${isNew ? 'What takes the pictures?' : 'Camera type'}</legend>
        <div class="library-class-options">
        ${CAMERA_CLASSES.map(([value, label]) => `<label class="library-choice"><input type="radio" name="library-class" value="${value}"${d.cameraClass === value ? ' checked' : ''}><span>${value === 'unknown' ? 'Not sure (Unknown)' : label}</span></label>`).join('')}
        </div>
        <span class="field-hint" id="library-hint-cameraClass">${d.cameraClass === 'unknown' ? 'The type stays Unknown. The app does not work out sensor facts from it; you can set it later.' : 'Chosen by you, never inferred from a name. It decides the capture settings a plan offers (ISO or gain, binning).'}</span>
        ${fieldError('cameraClass')}
      </fieldset>
      ${offersNoiseReduction(d.cameraClass) ? `<label class="library-check"><input type="checkbox" data-field-check="noiseReduction"${d.noiseReduction ? ' checked' : ''}><span>In-camera noise reduction<span class="field-hint">Long-exposure noise reduction: the camera takes a dark as long as each light. The plan counts that time.</span></span></label>` : ''}
      ${metadataView()}
      <fieldset class="workspace-form"><legend class="library-legend">Camera sensor</legend>
        <div class="library-pair">${input('resW', 'Resolution width (px)', { mode: 'numeric', placeholder: '6248' })}${input('resH', 'Resolution height (px)', { mode: 'numeric', placeholder: '4176' })}</div>
        <p class="field-hint">${esc(REASONS.resolution)}</p>
        ${input('pixel', 'Pixel size (µm)', { mode: 'decimal', hint: `Square pixels: one value. ${REASONS.pixel}`, placeholder: '3.76' })}
        <div class="library-derived"><span class="library-derived-label">Sensor size (mm)</span>
          <output data-sensor${e.errors.sensor ? ' aria-describedby="library-error-sensor"' : ''}>${esc(sensor ? `${sensor[0]} × ${sensor[1]} mm` : 'Not recorded until resolution and pixel size are entered')}</output>
          <span class="field-hint">Auto-calculated from resolution × pixel size. ${esc(REASONS.sensor)}</span>${fieldError('sensor')}</div>
      </fieldset>
      <fieldset class="workspace-form"><legend class="library-legend">Optics</legend>
        ${input('focal', 'Effective focal length (mm)', { mode: 'decimal', hint: REASONS.focal })}
        <div class="library-pair">${input('ratio', 'Focal ratio (f/)', { mode: 'decimal', readonly: diameterSet, hint: diameterSet ? 'From focal length ÷ diameter' : REASONS.ratio })}${input('diameter', 'Aperture diameter (mm, optional)', { mode: 'decimal' })}</div>
        ${fieldError('aperture')}
        <label class="block-input">Tracking (default for plans)
          <select data-field="tracking">${TRACKING.map(([value, label]) => `<option value="${value}"${d.tracking === value ? ' selected' : ''}>${label}</option>`).join('')}</select>
          <span class="field-hint">A plan may override it.</span></label>
      </fieldset>
      <details class="library-disclosure" data-more${e.moreOpen ? ' open' : ''}><summary>More (optional)<span class="library-caption">${esc(moreSummary())}</span></summary>
        <div class="workspace-form">
          <div class="library-pair">${input('manufacturer', 'Manufacturer (optional)', { placeholder: 'e.g. ZWO' })}${input('cameraModel', 'Model (optional)', { placeholder: 'e.g. ASI2600MC' })}</div>
          ${input('maxExposure', 'Maximum sub-exposure (s)', { mode: 'decimal', hint: 'Optional — your mount/guiding limit' })}
          ${input('rawSize', 'Average RAW file size (MB)', { mode: 'decimal', hint: 'Optional: makes the storage estimate real' })}
          <label class="block-input">Capture format (optional)
            <select data-field="captureFormat"><option value="">Not set</option>${CAPTURE_FORMATS.map(([value, label]) => `<option value="${value}"${d.captureFormat === value ? ' selected' : ''}>${esc(label)}</option>`).join('')}</select>
            <span class="field-hint">Gives a theoretical file size when no file is measured; compressed formats have none.</span></label>
          ${input('rotation', 'Rotation (°)', { mode: 'decimal' })}
        </div>
      </details>
      ${saveBar('Save rig')}
    </form>`;
  }

  function moreSummary() {
    const d = S.edit.draft;
    const set = [
      d.maxExposure.trim() && `maximum ${d.maxExposure.trim()} s`,
      d.rawSize.trim() && `RAW ${d.rawSize.trim()} MB`,
      d.captureFormat && FORMAT_LABEL[d.captureFormat],
      d.rotation.trim() && `rotation ${d.rotation.trim()}°`,
    ].filter(Boolean);
    return set.length ? set.join(' · ') : 'Manufacturer, model, RAW size and other records';
  }

  function metadataView() {
    const e = S.edit, review = e.metadata?.kind === 'photo' ? null : e.metadata;
    return `${hybrid ? photoMetadataView() : ''}<details class="library-disclosure library-import" data-metadata${e.metadataOpen ? ' open' : ''}>
      <summary>${hybrid ? 'Import rig values from JSON' : 'Read local metadata'}<span class="library-caption">Review JSON values before applying</span></summary>
      <p class="workspace-copy">This browser reads plain JSON only, on this device. Photo/RAW/HEIC/FITS header extraction requires the app. You can always enter values by hand.</p>
      <label class="block-input">Metadata file (.json)<input type="file" data-metadata-file accept=".json,application/json"${e.metadataBusy ? ' disabled' : ''}></label>
      ${e.metadataBusy ? '<p class="workspace-copy" role="status">Reading local file…</p>' : ''}
      ${hybrid && e.metadataBusy && e.metadataSaveError ? `<p class="field-error" role="alert">${esc(e.metadataSaveError)}</p>` : ''}
      ${e.metadataError ? `<p class="field-error" role="alert">${esc(e.metadataError)}</p>` : ''}
      ${review ? `<section class="library-metadata-review" aria-labelledby="library-metadata-title"><h3 id="library-metadata-title" tabindex="-1">Review ${esc(review.name)}</h3>
        <p class="workspace-copy">JSON values, not verified hardware specifications. ${hybrid ? 'Select fields, choose Apply checked values, then Save rig. Cancel review to keep the current draft values.' : 'Check the fields to replace in this draft. Save rig is still required.'}</p>
        ${review.rows.map((r, i) => `<label class="library-check library-import-choice"><input type="checkbox" data-metadata-choice="${i}"${r.selected ? ' checked' : ''}><span>${esc(r.label)}<span class="library-caption">${esc(e.draft[r.key] || 'Unknown')} → ${esc(r.value)}</span></span></label>`).join('')}
        <p class="library-caption">Camera type stays your choice. Absent fields stay unchanged. When aperture diameter is entered, focal ratio is derived from focal length ÷ diameter.</p>
        ${hybrid && e.metadataSaveError ? `<p class="field-error" role="alert">${esc(e.metadataSaveError)}</p>` : ''}<div class="workspace-actions"><button type="button" class="secondary-button" data-metadata-cancel>Cancel review</button><button type="button" class="primary-button" data-metadata-apply>Apply checked values</button></div>
      </section>` : ''}
      <details class="library-import-format"><summary>Supported JSON fields</summary><p class="workspace-copy">An object with manufacturer, cameraModel, resolutionPx: [width, height], pixelUm, focalLengthMm, focalRatio, apertureMm, maxExposureS or rawFileSizeMB. Units match the form. Other fields are not imported. A nested metadata object is also accepted.</p></details>
    </details>`;
  }

  // A labelled walkthrough of the existing native import, not a photo parser.
  // A chosen capture's bytes are never opened; file name/extension alone only
  // selects a supported-format example. JSON import below remains a real read.
  function photoMetadataView() {
    const e = S.edit, review = e.metadata?.kind === 'photo' ? e.metadata : null;
    return `<details class="library-disclosure library-import" data-photo-metadata${e.photoOpen ? ' open' : ''}>
      <summary>From a photo<span class="library-caption">Example walkthrough · review before applying</span></summary>
      <p class="workspace-copy">The app reads DNG, JPEG, HEIC and FITS headers on this device. This browser walkthrough uses labelled sample values; it does not read your photo or upload it.</p>
      <label class="block-input">Capture file (example walkthrough)<input type="file" data-photo-file accept=".dng,.jpg,.jpeg,.heic,.heif,.fits,.fit,.fts,.cr3,.nef,.arw"></label>
      <label class="block-input">Example reading<select data-photo-outcome><option value="complete"${e.photoOutcome === 'complete' || !e.photoOutcome ? ' selected' : ''}>Available fields</option><option value="partial"${e.photoOutcome === 'partial' ? ' selected' : ''}>Missing fields</option><option value="unreadable"${e.photoOutcome === 'unreadable' ? ' selected' : ''}>Unreadable header</option></select></label>
      <div class="workspace-actions"><button type="button" class="secondary-button" data-photo-example>Review a sample DNG</button></div>
      ${e.photoError ? `<p class="field-error" role="alert">${esc(e.photoError)}</p>` : ''}
      ${review ? `<section class="library-metadata-review" aria-labelledby="library-photo-title"><h3 id="library-photo-title" tabindex="-1">Review example ${esc(review.format)} reading</h3>
        <p class="workspace-copy">${esc(review.name)} · sample values, not extracted from this file. Select fields, choose Apply checked values, then Save rig. Cancel review to keep the current draft values.</p>
        ${review.rows.map((r, i) => `<label class="library-check library-import-choice"><input type="checkbox" data-metadata-choice="${i}"${r.selected ? ' checked' : ''}><span>${esc(r.label)}<span class="library-caption">${esc(e.draft[r.key] || 'Unknown')} → ${esc(r.value)}</span></span></label>`).join('')}
        <p class="library-caption">${review.partial ? 'Missing in this example: pixel size, focal length and focal ratio. ' : ''}Absent fields stay unchanged. Camera class stays your choice. Exposure and ISO/gain belong to a capture block, not a rig.</p>
        ${e.metadataSaveError ? `<p class="field-error" role="alert">${esc(e.metadataSaveError)}</p>` : ''}<div class="workspace-actions"><button type="button" class="secondary-button" data-metadata-cancel>Cancel review</button><button type="button" class="primary-button" data-metadata-apply>Apply checked values</button></div></section>` : ''}
    </details>`;
  }

  function readPhotoExample(file = null) {
    const e = S.edit;
    if (!hybrid || e?.kind !== 'rig') return;
    const name = file?.name || 'Bundled sample.dng';
    e.metadataToken = {};
    e.metadataBusy = false;
    e.metadataOpen = false;
    e.photoOpen = true;
    e.photoError = '';
    e.metadataError = '';
    e.metadataSaveError = '';
    e.metadata = null;
    const extension = name.split('.').pop().toLowerCase();
    const format = {dng:'DNG',jpg:'JPEG',jpeg:'JPEG',heic:'HEIC',heif:'HEIC',fits:'FITS',fit:'FITS',fts:'FITS'}[extension];
    if (!format) e.photoError = 'This format is not read by the app. DNG, JPEG, HEIC and FITS are supported. Your draft is unchanged; choose another file or enter values by hand.';
    else if (e.photoOutcome === 'unreadable') e.photoError = 'Example: the header could not be read. Your draft is unchanged. Choose another file or enter values by hand.';
    else {
      const partial = e.photoOutcome === 'partial';
      const values = [['manufacturer','Manufacturer','Example manufacturer'],['cameraModel','Camera model',format === 'FITS' ? 'Example astro camera' : 'Example camera'],['resW','Resolution width (px)',format === 'FITS' ? '3008' : '6000'],['resH','Resolution height (px)',format === 'FITS' ? '3008' : '4000'],...(!partial ? [['pixel','Pixel size (µm)','3.76'],['focal','Focal length (mm)','400'],['ratio','Focal ratio','5']] : [])];
      e.metadata = {kind:'photo',name,format,partial,rows:values.map(([key,label,value])=>({key,label,value,selected:!e.draft[key].trim()}))};
    }
    rerenderKeeping(e.metadata ? '#library-photo-title' : '[data-photo-metadata] > summary');
    view.querySelector('#library-photo-title')?.scrollIntoView({block:'start'});
    // The local error has role=alert; don't duplicate it in the visible banner.
    if (e.metadata) api.announce('Example photo reading ready. Nothing applied or saved.');
  }

  async function readMetadata(file) {
    if (!file || S.edit?.kind !== 'rig') return;
    const e = S.edit, token = {};
    e.metadataToken = token;
    e.metadata = null;
    e.metadataError = '';
    e.metadataSaveError = '';
    e.metadataOpen = true;
    e.metadataBusy = true;
    rerenderKeeping('[data-metadata] > summary');
    try {
      if (!/\.json$/i.test(file.name)) throw Error('This browser cannot extract photo or RAW metadata. Choose plain JSON, or enter the values by hand.');
      if (file.size > 256 * 1024) throw Error('Choose a metadata JSON file smaller than 256 KB. Your draft is unchanged.');
      const parsed = JSON.parse(await file.text());
      const values = parsed?.metadata ?? parsed;
      if (!values || typeof values !== 'object' || Array.isArray(values)) throw Error('The metadata must be a JSON object. Your draft is unchanged.');
      const rows = [];
      const add = (key, label, value, validate) => {
        if (value === null || value === undefined) return;
        if (!['string', 'number'].includes(typeof value) || (typeof value === 'number' && !Number.isFinite(value))) throw Error(`${label} has an unsupported value. Your draft is unchanged.`);
        const text = String(value).trim(), problem = validate(text);
        if (problem) throw Error(`${label}: ${problem}. Your draft is unchanged.`);
        rows.push({ key, label, value: text, selected: !e.draft[key].trim() });
      };
      for (const [key, label] of [['manufacturer', 'Manufacturer'], ['cameraModel', 'Camera model']]) {
        add(key, label, values[key], v => !v || v.length > MAX_TEXT ? `enter 1–${MAX_TEXT} characters` : null);
      }
      if (values.resolutionPx !== null && values.resolutionPx !== undefined) {
        if (!Array.isArray(values.resolutionPx) || values.resolutionPx.length !== 2) throw Error('Resolution must be [width, height] in pixels. Your draft is unchanged.');
        add('resW', 'Resolution width (px)', values.resolutionPx[0], validateResolution);
        add('resH', 'Resolution height (px)', values.resolutionPx[1], validateResolution);
      }
      for (const [source, key, label, range, unit] of [
        ['pixelUm', 'pixel', 'Pixel size (µm)', LIMITS.pixelUm, 'µm'],
        ['focalLengthMm', 'focal', 'Focal length (mm)', LIMITS.focalLengthMm, 'mm'],
        ['focalRatio', 'ratio', 'Focal ratio', LIMITS.focalRatio, ''],
        ['apertureMm', 'diameter', 'Aperture diameter (mm)', LIMITS.apertureMm, 'mm'],
        ['maxExposureS', 'maxExposure', 'Maximum exposure (s)', LIMITS.maxExposureS, 's'],
        ['rawFileSizeMB', 'rawSize', 'RAW size (MB)', LIMITS.rawFileSizeMB, 'MB'],
      ]) add(key, label, values[source], v => requiredNumber(v, range, unit));
      if (!rows.length) throw Error('No supported rig fields were found. See Supported JSON fields, or enter values by hand.');
      if (disposed || S.edit !== e || e.metadataToken !== token) return;
      e.metadata = { name: file.name, rows };
    } catch (error) {
      if (disposed || S.edit !== e || e.metadataToken !== token) return;
      e.metadataError = error instanceof SyntaxError ? 'This file is not valid JSON. Your draft is unchanged; choose another file or enter values by hand.' : error.message;
    }
    if (disposed || S.edit !== e || e.metadataToken !== token) return;
    e.metadataBusy = false;
    rerenderKeeping(e.metadata ? '#library-metadata-title' : '[data-metadata] > summary');
    if (e.metadata) view.querySelector('#library-metadata-title')?.scrollIntoView({ block: 'start' });
    if (e.metadata || !hybrid) api.announce(e.metadata ? 'Metadata ready to review. Nothing applied or saved.' : e.metadataError);
  }

  function applyMetadata() {
    const e = S.edit, rows = e?.metadata?.rows.filter(r => r.selected) ?? [];
    if (!rows.length) { api.announce('Check at least one value to apply, or cancel the review.'); return; }
    for (const r of rows) {
      e.draft[r.key] = r.value;
      delete e.errors[r.key];
    }
    e.metadataSource = e.metadata.name;
    e.metadataSourceKind = e.metadata.kind === 'photo' ? 'Example photo walkthrough' : 'Reviewed local JSON metadata';
    e.metadataKeys = [...new Set([...(e.metadataKeys ?? []), ...rows.map(r => r.key)])];
    e.metadata = null;
    e.metadataOpen = false;
    e.metadataSaveError = '';
    if (hybrid) e.photoOpen = false;
    if (rows.some(r => ['manufacturer', 'cameraModel', 'maxExposure', 'rawSize'].includes(r.key))) e.moreOpen = true;
    rerenderKeeping(selector('data-field', rows[0].key));
    refreshRigDerived();
    api.announce('Checked metadata values applied to this draft. Review the form, then Save rig.');
  }

  // The sensor size shown: derived from the typed values; an untouched pair
  // keeps the stored size (never re-derived behind the user's back).
  function derivedSensor() {
    const e = S.edit, d = e.draft, sh = e.shown;
    const record = e.id ? find('rig', e.id) : null;
    if (record?.sensorMm && d.resW === sh.resW && d.resH === sh.resH && d.pixel === sh.pixel) {
      return record.sensorMm.map(v => v.toFixed(2));
    }
    return sensorText(d.resW, d.resH, d.pixel);
  }

  function targetForm() {
    const e = S.edit, d = e.draft, record = e.id ? find('target', e.id) : null;
    const types = [...TARGET_TYPES, ...(record && !TARGET_TYPES.includes(record.type) ? [record.type] : [])];
    const match = d.name.trim() ? searchTargets(d.name.trim(), CATALOGUE)[0] : null;
    const duplicate = match && searchTargets(d.name.trim(), CATALOGUE).length && [match.id, match.name, ...match.aliasIds, ...match.aliasNames].some(n => n.toLowerCase() === d.name.trim().toLowerCase());
    return `<form class="workspace-form library-form" data-edit-form novalidate>
      <p class="workspace-copy" tabindex="-1" data-focus-start>${record ? `Catalogue id: ${esc(record.catalogId)}. ` : ''}Coordinates are J2000. ${hybrid && !record ? 'Enter the new target’s coordinates. Optional fields left empty stay unknown until Save target.' : 'Values you leave untouched keep exactly what is stored.'}</p>
      ${input('name', 'Name', { placeholder: 'e.g. Andromeda Galaxy', hint: duplicate ? `The catalogue sample already has ${match.id} (${match.name}); a target you add stays separate from it.` : '' })}
      <label class="block-input">Object type
        <select data-field="type">${types.map(t => `<option value="${esc(t)}"${d.type === t ? ' selected' : ''}>${esc(t)}</option>`).join('')}</select>
        ${MOVING_TYPES.includes(d.type) ? `<span class="field-hint">${MOVING_WARNING}</span>` : '<span class="field-hint">New targets have fixed coordinates; moving objects are not offered.</span>'}</label>
      ${input('ra', 'Right ascension (J2000)', { placeholder: '05h35m17s, 5:35:17 or 5.588 h', hint: 'Hours 0–24 (a bare number is hours), or degrees with °: 83.82°' })}
      ${input('dec', 'Declination (J2000)', { placeholder: '−05°23′28″, -5:23:28 or -5.39', hint: 'Degrees, −90 to +90' })}
      ${input('size', 'Apparent size (arcmin, optional)', { mode: 'decimal', hint: 'Above 0, at most 3000′. Empty is unknown.' })}
      ${input('mag', 'Magnitude (optional)', { mode: 'decimal', hint: '−30 to 30. Empty is unknown.' })}
      ${saveBar('Save target')}
    </form>`;
  }

  function siteForm() {
    const e = S.edit, d = e.draft, record = e.id ? find('site', e.id) : null;
    const zones = zoneOptions(d.zone);
    const sourceCaption = (value, stored, source) => (record && value === stored && source ? `Source: ${source}` : '');
    const bortleNote = sourceCaption(d.bortle, record?.bortle === null || !record ? '' : String(record.bortle), record?.bortleSource);
    const sqmNote = sourceCaption(d.sqm, textOf(record?.sqm ?? null), record?.sqmSource);
    return `<form class="workspace-form library-form" data-edit-form novalidate>
      <p class="workspace-copy" tabindex="-1" data-focus-start>Save a place; choose it separately in the Plan.</p>
      ${input('name', 'Name')}
      ${locationView()}
      <fieldset class="workspace-form"><legend class="library-legend">Coordinates and time zone</legend>
      <div class="library-pair">${input('lat', 'Latitude (°)', { mode: 'decimal', hint: 'North + · −90 to 90' })}
      ${input('lon', 'Longitude (°)', { mode: 'decimal', hint: 'East + · −180 to 180' })}</div>
      <label class="block-input">Time zone
        <select data-field="zone"${described('zone', 'x')}><option value="">Unknown — night uses mean solar time</option>${zones.map(z => `<option value="${esc(z)}"${d.zone === z ? ' selected' : ''}>${esc(z)}</option>`).join('')}</select>
        <span class="field-hint" id="library-hint-zone">${e.zoneFromBrowser && d.zone === e.shown.zone ? 'Browser zone pre-filled: verify it for this site. ' : ''}Used for local dates, times and daylight-saving changes.</span>${fieldError('zone')}</label></fieldset>
      <details class="library-disclosure" data-more${e.moreOpen ? ' open' : ''}><summary>More (optional)<span class="library-caption">Elevation, sky darkness and notes</span></summary>
        <div class="workspace-form">
          ${input('elevation', 'Elevation (m, optional)', { mode: 'decimal', hint: 'Above sea level, −500 to 9000 m. Empty stays unknown.' })}
          <label class="block-input">Bortle class
            <select data-field="bortle"><option value="">Unknown</option>${Array.from({ length: 9 }, (_, i) => `<option value="${i + 1}"${d.bortle === String(i + 1) ? ' selected' : ''}>Bortle ${i + 1}</option>`).join('')}</select>
            ${bortleNote ? `<span class="field-hint">${esc(bortleNote)}</span>` : ''}</label>
          ${input('sqm', 'SQM (mag/arcsec²)', { mode: 'decimal', hint: sqmNote || 'Empty = unknown. 15 to 23.' })}
          <p class="field-hint">Bortle and SQM are never converted into each other. No sky-darkness service is contacted.</p>
          <label class="block-input">Notes (optional)<textarea rows="3" data-field="notes"${described('notes', '')}>${esc(d.notes)}</textarea>${fieldError('notes')}</label>
        </div>
      </details>
      ${saveBar('Save site')}
    </form>`;
  }

  function locationView() {
    const e = S.edit, position = e.locationCandidate;
    return `<details class="library-disclosure library-location" data-location${e.locationOpen ? ' open' : ''}><summary>Use device position<span class="library-caption">Permission required · manual entry always available</span></summary>
      <p class="workspace-copy">Only request this if the device is at your observing site. Your browser may use its location service. Culmina contacts no map or place-name provider.</p>
      <button type="button" class="secondary-button" data-request-position${e.locationBusy ? ' disabled' : ''}>${e.locationBusy ? 'Getting position…' : 'Request current position'}</button>
      ${e.locationMessage ? `<p class="workspace-copy" role="status">${esc(e.locationMessage)}</p>` : ''}
      ${position ? `<section class="library-position-review"><h3 tabindex="-1" id="library-position-title">Use these coordinates?</h3>
        <p>${esc(coordinates(position.lat, position.lon))}</p><p class="library-caption">${Number.isFinite(position.accuracy) ? `Reported accuracy ±${Math.round(position.accuracy)} m. ` : ''}Check the site and time zone. Nothing has changed yet.</p>
        <div class="workspace-actions"><button type="button" class="secondary-button" data-position-cancel>Cancel</button><button type="button" class="primary-button" data-position-apply>Use in this draft</button></div></section>` : ''}
      <p class="library-caption">Map tiles are unavailable offline in this preview. Enter latitude/longitude below; no simulated map selection is saved.</p>
    </details>`;
  }

  function requestPosition() {
    const e = S.edit;
    if (!e || e.kind !== 'site' || e.locationBusy) return;
    e.locationOpen = true;
    e.locationMessage = '';
    e.locationCandidate = null;
    if (!navigator.geolocation) {
      e.locationMessage = 'Device location is unavailable. Enter the coordinates below instead.';
      rerenderKeeping('[data-location] > summary');
      return;
    }
    e.locationBusy = true;
    rerenderKeeping('[data-request-position]');
    navigator.geolocation.getCurrentPosition(position => {
      if (disposed || S.edit !== e || S.view !== 'edit') return;
      e.locationBusy = false;
      const { latitude: lat, longitude: lon, accuracy } = position.coords;
      if (!Number.isFinite(lat) || Math.abs(lat) > 90 || !Number.isFinite(lon) || Math.abs(lon) > 180) {
        e.locationMessage = 'The device returned unusable coordinates. Enter them below instead.';
      } else e.locationCandidate = { lat, lon, accuracy };
      rerenderKeeping(e.locationCandidate ? '#library-position-title' : '[data-location] > summary');
      if (e.locationCandidate || !hybrid) api.announce(e.locationCandidate ? 'Position ready to review. Draft unchanged.' : e.locationMessage);
    }, error => {
      if (disposed || S.edit !== e || S.view !== 'edit') return;
      e.locationBusy = false;
      e.locationMessage = `${error.code === 1 ? 'Location permission was denied.' : error.code === 3 ? 'The location request timed out.' : 'A device position is unavailable.'} Your coordinates are unchanged. Enter them below or try again.`;
      rerenderKeeping('[data-request-position]');
      if (!hybrid) api.announce(e.locationMessage);
    }, { enableHighAccuracy: false, timeout: 10000, maximumAge: 0 });
  }

  /* ----- Validation and save ----- */

  // An untouched field keeps the stored value exactly.
  const keep = (key, stored, parse) => (S.edit.id && S.edit.draft[key] === S.edit.shown[key] ? stored : parse(S.edit.draft[key]));
  const parsedOrNull = text => number(text);

  function validateRig() {
    const d = S.edit.draft, errors = {};
    if (!d.name.trim()) errors.name = 'Rig name is required.';
    else if (d.name.trim().length > MAX_TEXT) errors.name = `At most ${MAX_TEXT} characters in this preview.`;
    for (const k of ['manufacturer', 'cameraModel']) if (d[k].trim().length > MAX_TEXT) errors[k] = `At most ${MAX_TEXT} characters in this preview.`;
    if (!d.cameraClass) errors.cameraClass = 'Choose the camera type first.';
    const rw = validateResolution(d.resW), rh = validateResolution(d.resH);
    if (rw) errors.resW = rw;
    if (rh) errors.resH = rh;
    const px = requiredNumber(d.pixel, LIMITS.pixelUm, 'µm');
    if (px) errors.pixel = px;
    if (!rw && !rh && !px) {
      const s = derivedSensor().map(Number);
      if (!s.every(v => inRange(v, LIMITS.sensorMm))) errors.sensor = `Sensor size ${rangeMessage(LIMITS.sensorMm, 'mm').toLowerCase()} per side: check the resolution and pixel size`;
    }
    const fl = requiredNumber(d.focal, LIMITS.focalLengthMm, 'mm');
    if (fl) errors.focal = fl;
    const dia = optionalNumber(d.diameter, LIMITS.apertureMm, 'mm');
    if (dia) errors.diameter = dia;
    if (!d.diameter.trim()) {
      const ra = requiredNumber(d.ratio, LIMITS.focalRatio, '');
      if (ra) errors.ratio = ra;
    }
    if (!fl && !dia && !errors.ratio) {
      const res = resolveAperture(number(d.focal), number(d.ratio), number(d.diameter));
      if (res.problem) errors.aperture = res.problem;
    }
    const more = [['maxExposure', LIMITS.maxExposureS, 's'], ['rawSize', LIMITS.rawFileSizeMB, 'MB'], ['rotation', LIMITS.rotationDeg, '°']];
    for (const [k, range, unit] of more) {
      const m = optionalNumber(d[k], range, unit);
      if (m) errors[k] = m;
    }
    return errors;
  }

  function buildRig() {
    const e = S.edit, d = e.draft, sh = e.shown, old = e.id ? find('rig', e.id) : null;
    const changed = keys => !old || keys.some(k => d[k] !== sh[k]);
    const cameraChanged = changed(['resW', 'resH', 'pixel']);
    const opticsChanged = changed(['focal', 'ratio', 'diameter']);
    const focal = keep('focal', old?.focalLengthMm ?? null, parsedOrNull);
    let ratio, diameter;
    if (old && !opticsChanged) {
      ratio = old.focalRatio;
      diameter = old.apertureMm;
    } else {
      const res = resolveAperture(focal, number(d.ratio), number(d.diameter));
      ratio = res.ratio;
      diameter = res.diameter;
    }
    const resolutionPx = old && !changed(['resW', 'resH']) ? old.resolutionPx : [Number(d.resW.trim()), Number(d.resH.trim())];
    const pixelUm = keep('pixel', old?.pixelUm ?? null, parsedOrNull);
    const sensorMm = old && !cameraChanged && old.sensorMm ? old.sensorMm : sensorText(d.resW, d.resH, d.pixel).map(Number);
    const entered = 'Entered in this browser preview';
    const sourceFor = keys => e.metadataKeys?.some(k => keys.includes(k))
      ? `${e.metadataSourceKind || 'Reviewed local JSON metadata'}: ${e.metadataSource}; any later edits are user-entered` : entered;
    return {
      id: e.id ?? newId(), example: old?.example ?? false, name: d.name.trim(),
      manufacturer: d.manufacturer.trim() || null, cameraModel: d.cameraModel.trim() || null,
      cameraClass: d.cameraClass, noiseReduction: d.noiseReduction,
      resolutionPx, pixelUm, sensorMm, focalLengthMm: focal, focalRatio: ratio, apertureMm: diameter, tracking: d.tracking,
      maxExposureS: keep('maxExposure', old?.maxExposureS ?? null, parsedOrNull),
      rawFileSizeMB: keep('rawSize', old?.rawFileSizeMB ?? null, parsedOrNull),
      captureFormat: d.captureFormat || null,
      rotationDeg: keep('rotation', old?.rotationDeg ?? null, parsedOrNull),
      provenance: {
        record: old?.provenance.record ?? 'Added in this browser preview',
        camera: cameraChanged ? sourceFor(['resW', 'resH', 'pixel']) : old.provenance.camera,
        optics: opticsChanged ? sourceFor(['focal', 'ratio', 'diameter']) : old.provenance.optics,
      },
    };
  }

  function validateTarget() {
    const d = S.edit.draft, errors = {};
    if (!d.name.trim()) errors.name = 'Target name is required.';
    else if (d.name.trim().length > MAX_TEXT) errors.name = `At most ${MAX_TEXT} characters in this preview.`;
    const ra = validateRightAscension(d.ra), dec = validateDeclination(d.dec), size = validateAngularSize(d.size), mag = validateMagnitude(d.mag);
    if (ra) errors.ra = ra;
    if (dec) errors.dec = dec;
    if (size) errors.size = size;
    if (mag) errors.mag = mag;
    return errors;
  }

  // AstroTarget.userEdit: a new target's catalogue id is its name and its
  // source is `user`; an edit keeps the catalogue id.
  function buildTarget() {
    const e = S.edit, d = e.draft, old = e.id ? find('target', e.id) : null;
    return {
      id: e.id ?? newId(), catalogId: old?.catalogId ?? d.name.trim(), name: d.name.trim(), type: d.type,
      raDeg: keep('ra', old?.raDeg, parseRightAscension), decDeg: keep('dec', old?.decDeg, parseDeclination),
      sizeArcmin: keep('size', old?.sizeArcmin ?? null, parsedOrNull), magnitude: keep('mag', old?.magnitude ?? null, parsedOrNull), source: 'user',
    };
  }

  function validateSite() {
    const d = S.edit.draft, errors = {};
    if (!d.name.trim()) errors.name = 'Name is required';
    else if (d.name.trim().length > MAX_TEXT) errors.name = `At most ${MAX_TEXT} characters in this preview.`;
    const lat = validateCoordinate(d.lat, -90, 90, 'Latitude'), lon = validateCoordinate(d.lon, -180, 180, 'Longitude');
    const el = validateElevation(d.elevation), sqm = validateSqm(d.sqm);
    if (lat) errors.lat = lat;
    if (lon) errors.lon = lon;
    if (el) errors.elevation = el;
    if (sqm) errors.sqm = sqm;
    if (d.zone && !validZone(d.zone)) errors.zone = 'This browser does not know that time zone.';
    if (d.notes.length > MAX_NOTES) errors.notes = `At most ${MAX_NOTES} characters in this preview.`;
    return errors;
  }

  function buildSite() {
    const e = S.edit, d = e.draft, sh = e.shown, old = e.id ? find('site', e.id) : null;
    const bortle = d.bortle ? Number(d.bortle) : null;
    const sqm = keep('sqm', old?.sqm ?? null, parsedOrNull);
    const stamp = `Entered in this preview · ${localDate()}`;
    return {
      id: e.id ?? newId(), example: old?.example ?? false, name: d.name.trim(),
      latDeg: keep('lat', old?.latDeg, parsedOrNull), lonDeg: keep('lon', old?.lonDeg, parsedOrNull),
      elevationM: keep('elevation', old?.elevationM ?? null, parsedOrNull), zone: d.zone || null,
      bortle, bortleSource: bortle === null ? null : old && d.bortle === sh.bortle ? old.bortleSource : stamp,
      sqm, sqmSource: sqm === null ? null : old && d.sqm === sh.sqm ? old.sqmSource : stamp,
      notes: d.notes.trim() || null,
      provenance: e.appliedPosition?.lat === d.lat && e.appliedPosition?.lon === d.lon ? `Device coordinates confirmed in this browser · ${localDate()}`
        : old && d.lat === sh.lat && d.lon === sh.lon ? old.provenance : `Coordinates entered in this browser · ${localDate()}`,
    };
  }

  const FIRST_FOCUS = { aperture: 'focal', sensor: 'pixel' };

  function save() {
    const e = S.edit;
    if (!e) return;
    if (hybrid && e.kind === 'rig' && (e.metadata || e.metadataBusy)) {
      e.metadataSaveError = 'Apply checked values or Cancel review before Save rig. Nothing has been saved.';
      if (e.metadata?.kind === 'photo') e.photoOpen = true;
      else e.metadataOpen = true;
      rerenderKeeping(e.metadata ? '[data-metadata-apply]' : '[data-metadata] > summary');
      view.querySelector('[data-metadata-apply]')?.scrollIntoView({block:'center'});
      return;
    }
    e.errors = e.kind === 'rig' ? validateRig() : e.kind === 'target' ? validateTarget() : validateSite();
    const first = Object.keys(e.errors)[0];
    if (first) {
      e.saveError = '';
      if (['manufacturer', 'cameraModel', 'maxExposure', 'rawSize', 'rotation', 'sqm', 'elevation', 'notes'].some(k => e.errors[k])) e.moreOpen = true;
      const key = FIRST_FOCUS[first] ?? first;
      render(key === 'cameraClass' ? '[name="library-class"]' : selector('data-field', key));
      api.announce('Check the highlighted fields.');
      return;
    }
    const record = e.kind === 'rig' ? buildRig() : e.kind === 'target' ? buildTarget() : buildSite();
    const list = COLLECTION[e.kind];
    let note;
    try {
      note = mutate(data => {
        const items = data[list];
        if (e.id) {
          const current = items.find(x => x.id === e.id);
          if (!current) throw new PreviewFailure('missing');
          // A form opened on a record that changed since writes nothing.
          if (JSON.stringify(current) !== e.baseline) throw new PreviewFailure('stale');
          return { ...data, [list]: items.map(x => (x.id === e.id ? record : x)) };
        }
        return { ...data, [list]: [...items, record] };
      });
    } catch (error) {
      e.saveMissing = false;
      if (error.kind === 'missing') {
        load();
        e.saveMissing = true;
        e.saveError = 'This record no longer exists, so nothing was saved.';
      } else if (error.kind === 'stale') {
        load();
        e.saveError = 'This record changed in another tab since you opened the form. Nothing was saved; your edits are kept. Cancel to see the stored record.';
        e.baseline = JSON.stringify(find(e.kind, e.id));
      } else {
        e.saveError = failureText(error, `save the ${e.kind}`);
      }
      const scroll = scroller?.scrollTop;
      render(e.saveMissing ? '[data-back-list]' : '[data-retry-save]');
      if (scroller && scroll !== undefined) scroller.scrollTop = scroll;
      view.querySelector('[data-retry-save],[data-back-list]')?.scrollIntoView({ block: 'nearest' });
      api.announce(e.saveError);
      return;
    }
    leaveEditor(`${e.kind[0].toUpperCase()}${e.kind.slice(1)} saved${note}.`, record.id);
  }

  /* ----- Delete and Undo ----- */

  const titleOf = (kind, x) => (kind === 'target' ? targetLabel(x) : x.name);

  async function deleteRecord(kind, id, { confirmFirst = true } = {}) {
    const x = find(kind, id);
    if (!x) return;
    if (confirmFirst) {
      const choice = await choiceDialog({
        title: `Delete this ${kind}?`,
        message: `“${titleOf(kind, x)}” is deleted from your ${COLLECTION[kind]} in this preview. Saved plans keep what they recorded. Undo is offered right after.`,
        buttons: [['cancel', 'Cancel', 'secondary'], ['ok', 'Delete', 'destructive']],
      });
      if (choice !== 'ok' || disposed || S.view !== kind || S.id !== id) return;
    }
    const list = COLLECTION[kind];
    let removed = null, index = -1, note;
    try {
      note = mutate(data => {
        index = data[list].findIndex(y => y.id === id);
        removed = index < 0 ? null : data[list][index];
        return { ...data, [list]: data[list].filter(y => y.id !== id) };
      });
    } catch (error) {
      S.deleteError = failureText(error, `delete the ${kind}`);
      render('[data-retry-delete]');
      api.announce(S.deleteError);
      return;
    }
    S.deleteError = '';
    // One Undo at a time, as a newer message replaces the older one.
    ui.undo = removed && { list, record: removed, index, title: titleOf(kind, removed) };
    ui.undoError = '';
    show(list, { focus: ui.undo ? '[data-undo]' : null });
    api.announce(`${kind[0].toUpperCase()}${kind.slice(1)} deleted${note}.${ui.undo ? ' Undo is available.' : ''}`);
  }

  // Puts back exactly the deleted record, by its id, at its earlier place.
  function undoDelete() {
    const u = ui.undo;
    if (!u) return;
    let note;
    try {
      note = mutate(data => {
        const items = data[u.list];
        if (items.some(y => y.id === u.record.id)) return data;
        const at = Math.min(u.index, items.length);
        return { ...data, [u.list]: [...items.slice(0, at), u.record, ...items.slice(at)] };
      });
    } catch (error) {
      ui.undoError = failureText(error, 'restore it');
      renderResults();
      view.querySelector('[data-undo]')?.focus();
      api.announce(ui.undoError);
      return;
    }
    ui.undo = null;
    ui.undoError = '';
    renderResults();
    const kind = Object.keys(COLLECTION).find(k => COLLECTION[k] === u.list);
    (view.querySelector(selector('data-open', `${kind}:${u.record.id}`)) || view.querySelector('[data-search]'))?.focus();
    api.announce(`Restored${note}.`);
  }

  /* ----- Dialog ----- */

  function choiceDialog({ title, message, buttons }) {
    return new Promise(resolve => {
      const dialog = document.createElement('dialog');
      dialog.className = 'library-dialog';
      dialog.setAttribute('aria-labelledby', 'library-dialog-title');
      dialog.setAttribute('aria-describedby', 'library-dialog-message');
      const cls = { primary: 'primary-button', secondary: 'secondary-button', destructive: 'secondary-button library-destructive' };
      dialog.innerHTML = `<h2 id="library-dialog-title">${esc(title)}</h2><p id="library-dialog-message">${esc(message)}</p>
        <div class="workspace-actions library-dialog-actions">${buttons.map(([value, label, kind]) => `<button type="button" class="${cls[kind]}" data-dialog="${value}">${esc(label)}</button>`).join('')}</div>`;
      const opener = document.activeElement;
      const finish = value => {
        if (!dialogs.has(finish)) return;
        dialogs.delete(finish);
        if (dialog.open) dialog.close();
        dialog.remove();
        if ((value === null || value === 'cancel') && !disposed) opener?.focus?.();
        resolve(value);
      };
      dialog.addEventListener('click', event => {
        const button = event.target.closest('[data-dialog]');
        if (button) finish(button.dataset.dialog);
      });
      dialog.addEventListener('cancel', event => {
        event.preventDefault();
        finish(null);
      });
      dialogs.add(finish);
      view.append(dialog);
      dialog.showModal();
      dialog.querySelector('[data-dialog]').focus();
    });
  }

  /* ----- Events ----- */

  const split = value => {
    const at = value.indexOf(':');
    return [value.slice(0, at), value.slice(at + 1)];
  };

  async function onClick(event) {
    const el = event.target.closest('button');
    if (!el || !view.contains(el) || el.closest('dialog')) return;
    const data = el.dataset;
    if ('photoExample' in data) {
      readPhotoExample();
    } else if ('metadataApply' in data) {
      applyMetadata();
    } else if ('metadataCancel' in data && S.edit) {
      const photoReview = S.edit.metadata?.kind === 'photo';
      S.edit.metadata = null;
      S.edit.metadataError = '';
      S.edit.metadataSaveError = '';
      S.edit.metadataOpen = false;
      S.edit.photoOpen = false;
      rerenderKeeping(photoReview ? '[data-photo-metadata] > summary' : '[data-metadata] > summary');
      api.announce('Metadata review cancelled. Draft unchanged.');
    } else if ('requestPosition' in data) {
      requestPosition();
    } else if ('positionCancel' in data && S.edit) {
      S.edit.locationCandidate = null;
      rerenderKeeping('[data-request-position]');
      api.announce('Position cancelled. Coordinates unchanged.');
    } else if ('positionApply' in data && S.edit?.locationCandidate) {
      const e = S.edit, point = e.locationCandidate;
      e.draft.lat = point.lat.toFixed(5);
      e.draft.lon = point.lon.toFixed(5);
      e.appliedPosition = { lat: e.draft.lat, lon: e.draft.lon };
      delete e.errors.lat;
      delete e.errors.lon;
      e.locationCandidate = null;
      e.locationOpen = false;
      e.locationMessage = '';
      rerenderKeeping('[data-field="lat"]');
      api.announce('Device coordinates applied to this draft. Verify the time zone, then Save site.');
    } else if (data.openList) {
      S.deleteError = '';
      show(data.openList, { focus: '[data-search]' });
    } else if (data.open) {
      const [kind, id] = split(data.open);
      S.deleteError = '';
      show(kind, { id });
    } else if (data.add) {
      openEditor(data.add, null, 'list');
    } else if (data.edit) {
      const [kind, id] = split(data.edit);
      openEditor(kind, id, 'detail');
    } else if (data.delete) {
      const [kind, id] = split(data.delete);
      await deleteRecord(kind, id);
    } else if (data.retryDelete) {
      S.simulateFail = false;
      const [kind, id] = split(data.retryDelete);
      await deleteRecord(kind, id, { confirmFirst: false });
    } else if ('retrySave' in data) {
      S.simulateFail = false;
      save();
    } else if ('cancelEdit' in data) {
      await cancelEdit();
    } else if (data.backList) {
      S.edit = null;
      show(data.backList);
    } else if ('retryLoad' in data) {
      S.loadFailed = false;
      load();
      render(S.view === 'root' ? '[data-open-list]' : '[data-search]');
      api.announce('Library loaded.');
    } else if ('clearSearch' in data) {
      ui.query[S.view] = '';
      render('[data-search]');
    } else if ('undo' in data) {
      undoDelete();
    } else if ('dismissUndo' in data) {
      ui.undo = null;
      ui.undoError = '';
      renderResults();
      view.querySelector('[data-search]')?.focus();
    } else if ('replaceStore' in data) {
      const choice = await choiceDialog({
        title: 'Replace the stored preview data?',
        message: 'The unreadable Library preview payload is overwritten with the records shown now. Nothing else in this browser changes.',
        buttons: [['cancel', 'Cancel', 'secondary'], ['ok', 'Replace', 'destructive']],
      });
      if (choice !== 'ok' || disposed) return;
      try {
        writeStore(storage, S.data);
        S.status = 'stored';
        render();
        api.announce('Stored preview data replaced.');
      } catch {
        api.announce('Browser storage refused the write; the stored data is unchanged.');
      }
    }
  }

  // Live-updates derived rig values without re-rendering the typed field.
  function refreshRigDerived() {
    const e = S.edit, d = e.draft;
    if (['focal', 'diameter'].some(k => d[k] !== e.lastDerivedFrom?.[k])) {
      const focal = number(d.focal), diameter = number(d.diameter);
      const ratioInput = view.querySelector('[data-field="ratio"]');
      if (focal > 0 && diameter > 0) {
        d.ratio = (focal / diameter).toFixed(2);
        if (ratioInput) ratioInput.value = d.ratio;
      }
      if (ratioInput) {
        const set = !!d.diameter.trim();
        ratioInput.readOnly = set;
        const hint = view.querySelector('#library-hint-ratio');
        if (hint) hint.textContent = set ? 'From focal length ÷ diameter' : REASONS.ratio;
      }
      e.lastDerivedFrom = { focal: d.focal, diameter: d.diameter };
    }
    const out = view.querySelector('[data-sensor]');
    if (out) {
      const s = derivedSensor();
      out.textContent = s ? `${s[0]} × ${s[1]} mm` : 'Not recorded until resolution and pixel size are entered';
    }
    const summary = view.querySelector('[data-more] > summary > .library-caption');
    if (summary) summary.textContent = moreSummary();
  }

  function clearError(el, key) {
    const e = S.edit;
    if (!e.errors[key]) return;
    delete e.errors[key];
    el.removeAttribute('aria-invalid');
    const hint = view.querySelector(`#library-hint-${CSS.escape(key)}`);
    if (hint) el.setAttribute('aria-describedby', hint.id);
    else el.removeAttribute('aria-describedby');
    view.querySelector(`#library-error-${CSS.escape(key)}`)?.remove();
  }

  function onInput(event) {
    const el = event.target;
    if (el.matches('[data-search]')) {
      ui.query[el.dataset.search] = el.value;
      renderResults();
      rememberNavigation();
      return;
    }
    if (S.view !== 'edit' || !S.edit) return;
    const key = el.dataset.field;
    if (!key || el.tagName === 'SELECT') return;
    S.edit.draft[key] = el.value;
    clearError(el, key);
    if (S.edit.kind === 'rig') {
      if (['resW', 'resH', 'pixel'].includes(key) && S.edit.errors.sensor) {
        delete S.edit.errors.sensor;
        view.querySelector('#library-error-sensor')?.remove();
      }
      if (['focal', 'ratio', 'diameter'].includes(key) && S.edit.errors.aperture) {
        delete S.edit.errors.aperture;
        view.querySelector('#library-error-aperture')?.remove();
      }
      refreshRigDerived();
    } else if (S.edit.kind === 'site' && key === 'sqm') {
      const summary = view.querySelector('[data-more] > summary > .library-caption');
      const d = S.edit.draft;
      if (summary) summary.textContent = [d.bortle && `Bortle ${d.bortle}`, d.sqm.trim() && `SQM ${d.sqm.trim()}`].filter(Boolean).join(' · ') || 'Elevation, sky darkness and notes';
    }
  }

  function rerenderKeeping(focus) {
    const scroll = scroller?.scrollTop;
    render(focus);
    if (scroller && scroll !== undefined) scroller.scrollTop = scroll;
  }

  function onChange(event) {
    const el = event.target;
    if (S.view !== 'edit' || !S.edit) return;
    const e = S.edit;
    if (el.matches('[data-photo-file]')) {
      if (el.files?.[0]) readPhotoExample(el.files[0]);
    } else if (el.matches('[data-photo-outcome]')) {
      e.photoOutcome = el.value;
    } else if (el.matches('[data-metadata-file]')) {
      readMetadata(el.files?.[0]);
    } else if (el.dataset.metadataChoice !== undefined && e.metadata) {
      e.metadata.rows[Number(el.dataset.metadataChoice)].selected = el.checked;
    } else if (el.name === 'library-class') {
      e.draft.cameraClass = el.value;
      delete e.errors.cameraClass;
      rerenderKeeping(`[name="library-class"][value="${el.value}"]`);
    } else if (el.dataset.fieldCheck) {
      e.draft[el.dataset.fieldCheck] = el.checked;
    } else if (el.tagName === 'SELECT' && el.dataset.field) {
      e.draft[el.dataset.field] = el.value;
      delete e.errors[el.dataset.field];
      // The type warning, zone caption and summaries follow the choice.
      rerenderKeeping(selector('data-field', el.dataset.field));
    }
  }

  function onSubmit(event) {
    if (!event.target.matches('[data-edit-form]')) return;
    event.preventDefault();
    save();
  }

  // <details> toggle does not bubble.
  function onToggle(event) {
    if (S.edit && event.target.matches?.('[data-more]')) S.edit.moreOpen = event.target.open;
    if (S.edit && event.target.matches?.('[data-metadata]')) S.edit.metadataOpen = event.target.open;
    if (S.edit && event.target.matches?.('[data-photo-metadata]')) S.edit.photoOpen = event.target.open;
    if (S.edit && event.target.matches?.('[data-location]')) S.edit.locationOpen = event.target.open;
  }

  // Another tab changed this module's key: read it again, unless a record is
  // being edited (its Save then checks the record for changes first).
  function onStorage(event) {
    if (event.key !== STORAGE_KEY && event.key !== null) return;
    if (scenario === 'empty' || S.view === 'edit') return;
    load();
    render();
    api.announce('Library preview updated from another tab.');
  }

  function onBeforeUnload(event) {
    if (dirty()) event.preventDefault();
  }

  function onScroll() {
    if (S.view === 'edit') return;
    scrollPositions[S.view] = scroller.scrollTop;
    clearTimeout(navigationTimer);
    navigationTimer = setTimeout(rememberNavigation, 150);
  }

  root.addEventListener('click', onClick);
  root.addEventListener('input', onInput);
  root.addEventListener('change', onChange);
  root.addEventListener('submit', onSubmit);
  root.addEventListener('toggle', onToggle, true);
  window.addEventListener('storage', onStorage);
  window.addEventListener('beforeunload', onBeforeUnload);
  scroller?.addEventListener('scroll', onScroll, { passive: true });

  load();
  render();
  if (scroller) scroller.scrollTop = scrollPositions[S.view] ?? 0;

  return function cleanup() {
    if (S.view !== 'edit' && scroller) scrollPositions[S.view] = scroller.scrollTop;
    rememberNavigation();
    clearTimeout(navigationTimer);
    disposed = true;
    for (const finish of [...dialogs]) finish(null);
    root.removeEventListener('click', onClick);
    root.removeEventListener('input', onInput);
    root.removeEventListener('change', onChange);
    root.removeEventListener('submit', onSubmit);
    root.removeEventListener('toggle', onToggle, true);
    window.removeEventListener('storage', onStorage);
    window.removeEventListener('beforeunload', onBeforeUnload);
    scroller?.removeEventListener('scroll', onScroll);
  };
}
