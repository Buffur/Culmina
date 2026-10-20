// Checked backup of browser-prototype records only. This is deliberately not
// the native .astroplan database/manifest format and never touches its data.
import {planStorageKey, navigationDraftKey, validPlan, readNavigationDraft} from './plan-model.js?v=20261020-hybrid7';
import {validateLibraryPayload} from './library.js?v=20261020-hybrid7';
import {validateLogbookPayload} from './logbook.js?v=20261020-hybrid7';
import {validateSettingsPayload} from './settings.js?v=20261020-hybrid7';

const KIND = 'culmina-browser-preview-backup';
const MAX_BYTES = 4 * 1024 * 1024;
export const previewBackupKeys = Object.freeze([
  planStorageKey, navigationDraftKey, 'culmina-library-preview-v1', 'culmina-logbook-preview-v1', 'culmina-settings-preview-v1',
]);
const exactKeys = (o, keys) => !!o && typeof o === 'object' && !Array.isArray(o) &&
  Object.keys(o).length === keys.length && keys.every(k => Object.hasOwn(o, k));
const rawRecords = storage => Object.fromEntries(previewBackupKeys.map(key => [key, storage.getItem(key)]));

function validRecord(key, raw) {
  if (raw === null) return true;
  if (typeof raw !== 'string') return false;
  try {
    if (key === planStorageKey) {
      const value = JSON.parse(raw);
      return value?.kind === 'planning-lab-v2'
        ? validPlan(value.active) && Array.isArray(value.archive) && value.archive.every(validPlan)
        : validPlan(value);
    }
    if (key === navigationDraftKey) return !!readNavigationDraft({getItem: () => raw});
    if (key === 'culmina-library-preview-v1') return validateLibraryPayload(raw);
    if (key === 'culmina-logbook-preview-v1') return validateLogbookPayload(raw);
    if (key === 'culmina-settings-preview-v1') return validateSettingsPayload(raw);
  } catch { return false; }
  return false;
}

export function validatePreviewBackup(value) {
  try {
    const v = typeof value === 'string' ? JSON.parse(value) : value;
    return exactKeys(v, ['kind', 'version', 'createdAtUtc', 'records']) && v.kind === KIND && v.version === 1 &&
      typeof v.createdAtUtc === 'string' && Number.isFinite(Date.parse(v.createdAtUtc)) &&
      exactKeys(v.records, previewBackupKeys) && previewBackupKeys.every(key => validRecord(key, v.records[key]));
  } catch { return false; }
}

export function capturePreviewBackup(storage) {
  const backup = {kind: KIND, version: 1, createdAtUtc: new Date().toISOString(), records: rawRecords(storage)};
  if (!validatePreviewBackup(backup)) throw new Error('Some saved prototype data cannot be read. It was left unchanged; backup is unavailable until that data is repaired.');
  return backup;
}

// Synchronous, stale-guarded restore with an explicit rollback outcome. Web
// Storage has no multi-key transaction: a refused rollback is reported as a
// partial restore, never success. Unknown storage keys are never touched.
export function restorePreviewBackup(storage, backup, baseline) {
  if (!validatePreviewBackup(backup) || !exactKeys(baseline, previewBackupKeys) ||
    !previewBackupKeys.every(key => baseline[key] === null || typeof baseline[key] === 'string')) return {ok: false, kind: 'invalid'};
  try {
    if (previewBackupKeys.some(key => storage.getItem(key) !== baseline[key])) return {ok: false, kind: 'stale'};
  } catch { return {ok: false, kind: 'unavailable'}; }
  const attempted = [];
  try {
    for (const key of previewBackupKeys) {
      if (backup.records[key] === baseline[key]) continue;
      attempted.push(key);
      if (backup.records[key] === null) storage.removeItem(key);
      else storage.setItem(key, backup.records[key]);
    }
    return {ok: true};
  } catch {
    let rollbackComplete = true;
    for (const key of attempted.reverse()) {
      try {
        if (baseline[key] === null) storage.removeItem(key);
        else storage.setItem(key, baseline[key]);
      } catch { rollbackComplete = false; }
    }
    return {ok: false, kind: 'write', rollbackComplete};
  }
}

function counts(backup) {
  const parsed = key => backup.records[key] === null ? null : JSON.parse(backup.records[key]);
  const plan = parsed(planStorageKey), library = parsed('culmina-library-preview-v1'), logbook = parsed('culmina-logbook-preview-v1');
  return [
    ['Saved plans', plan ? plan.kind === 'planning-lab-v2' ? 1 + plan.archive.length : 1 : 0],
    ['Working draft', backup.records[navigationDraftKey] === null ? 'Not stored' : 'Included'],
    ['Library records', library ? library.rigs.length + library.targets.length + library.sites.length : 0],
    ['Logbook entries', logbook?.entries.length || 0],
    ['Settings', backup.records['culmina-settings-preview-v1'] === null ? 'Default / not stored' : 'Included'],
  ];
}

export function mountBackupTools({storage, phone, announce = () => {}}) {
  if (!document.querySelector('[data-preview-backup-style]')) {
    const link = document.createElement('link');
    link.rel = 'stylesheet'; link.href = new URL('./preview-backup.css', import.meta.url).href;
    link.dataset.previewBackupStyle = ''; document.head.append(link);
  }
  let panel = null, previousFocus = null, reviewed = null, baseline = null, originals = [], fileRevision = 0;
  const esc = text => String(text).replace(/[&<>"']/g, c => ({'&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;'}[c]));

  function close() {
    if (!panel) return;
    fileRevision++;
    panel.remove(); panel = null; reviewed = null; baseline = null;
    for (const [node, inert] of originals) node.inert = inert;
    originals = []; previousFocus?.focus?.({preventScroll: true});
  }
  function status(message, error = false) {
    const box = panel?.querySelector('[data-backup-status]');
    if (!box) return;
    box.textContent = message; box.classList.toggle('preview-backup-error', error);
    if (error) { box.tabIndex = -1; box.focus(); }
    announce(message);
  }
  function downloadCurrent() {
    let url = null;
    try {
      const backup = capturePreviewBackup(storage), body = JSON.stringify(backup, null, 2);
      if (new Blob([body]).size > MAX_BYTES) throw new Error('The saved prototype exceeds the 4 MB preview-backup limit. No data changed.');
      url = URL.createObjectURL(new Blob([body], {type: 'application/json;charset=utf-8'}));
      const link = document.createElement('a'); link.href = url; link.download = `culmina-browser-preview-${backup.createdAtUtc.slice(0, 10)}.json`;
      panel.append(link); link.click(); link.remove(); status('Current browser prototype backup download requested.');
    } catch (error) { status(error.message || 'Browser storage could not be read. Nothing changed.', true); }
    finally { if (url) setTimeout(() => URL.revokeObjectURL(url), 1000); }
  }
  function summary(backup) {
    return `<dl class="preview-backup-facts">${counts(backup).map(([label, value]) => `<div><dt>${esc(label)}</dt><dd>${esc(value)}</dd></div>`).join('')}</dl>`;
  }
  function renderReview() {
    const content = panel.querySelector('[data-backup-content]');
    content.innerHTML = `<h3 data-backup-review tabindex="-1">Review before restoring</h3>
      <p>Created ${esc(new Date(reviewed.createdAtUtc).toLocaleString('en-GB'))}. This replaces the five listed browser-prototype records, including the working draft.</p>
      ${summary(reviewed)}
      <p>“Not stored” restores an absent record: the corresponding preview shows its defaults or examples. Other browser keys stay unchanged.</p>
      <p>Keep a copy of your current data before replacing it.</p>
      <button type="button" class="secondary-button" data-backup-download>Download current data first</button>
      <div class="preview-backup-actions"><button type="button" class="secondary-button" data-backup-cancel>Cancel restore</button><button type="button" class="primary-button" data-backup-confirm>Confirm restore</button></div>
      <p class="preview-backup-status" data-backup-status role="status" aria-live="polite">File checked. Nothing has been restored.</p>`;
    content.scrollTop = 0; content.querySelector('[data-backup-review]').focus();
  }
  function renderStart() {
    fileRevision++;
    reviewed = null; baseline = null;
    panel.querySelector('[data-backup-content]').innerHTML = `<p>Back up saved plans, the working draft, Library, Logbook and Settings stored by this browser prototype.</p>
      <p class="preview-backup-boundary">Browser preview JSON only. This does not read or restore a native Culmina database or .astroplan backup.</p>
      <p>Files may contain site coordinates and private notes. Review them before sharing. No file is uploaded.</p>
      <button type="button" class="primary-button" data-backup-download>Download prototype backup</button>
      <section><h3>Restore prototype data</h3><p>Choose a backup from this prototype. The file is checked before you review and confirm any replacement. Maximum 4 MB.</p>
      <label class="preview-backup-file">Choose JSON file<input type="file" accept="application/json,.json" data-backup-file></label></section>
      <p class="preview-backup-status" data-backup-status role="status" aria-live="polite"></p>`;
  }
  async function checkFile(file) {
    if (!file || !panel) return;
    const revision = ++fileRevision;
    if (file.size > MAX_BYTES) { status('Choose a JSON backup no larger than 4 MB. Nothing changed.', true); return; }
    status('Checking file…');
    try {
      const value = JSON.parse(await file.text());
      if (!panel || revision !== fileRevision) return;
      if (!validatePreviewBackup(value)) throw new Error('This is not a valid browser-prototype backup. Check the file; no data changed.');
      baseline = rawRecords(storage); reviewed = value; renderReview();
    } catch (error) { if (panel && revision === fileRevision) status(error.message || 'Could not read the file. Choose it again; nothing changed.', true); }
  }
  function confirmRestore() {
    if (!reviewed || !baseline) return;
    const result = restorePreviewBackup(storage, reviewed, baseline);
    if (result.ok) {
      reviewed = null; baseline = null;
      panel.querySelector('[data-backup-content]').innerHTML = '<h3 tabindex="-1" data-backup-complete>Prototype data restored</h3><p>The checked browser records were replaced. Reload to display the restored data and settings.</p><button type="button" class="primary-button" data-backup-reload>Reload restored preview</button><p class="preview-backup-status" data-backup-status role="status">Native application data was not changed.</p>';
      panel.querySelector('[data-backup-complete]').focus(); announce('Browser prototype data restored. Reload to display it.');
    } else if (result.kind === 'stale') {
      status('Current prototype data changed after the file review. Cancel and choose the file again to review against the latest data. Nothing was restored.', true);
      panel.querySelector('[data-backup-confirm]').disabled = true;
    } else if (result.kind === 'write' && !result.rollbackComplete) {
      status('Restore stopped and the browser also refused part of the rollback. Some prototype records may have changed. Keep this page open, download the current data if possible, and check each tab before retrying.', true);
      panel.querySelector('[data-backup-confirm]').disabled = true;
    } else {
      status(result.kind === 'write' ? 'The browser refused the restore. The previous data was put back. You can retry or cancel.' : 'Restore could not proceed. Your stored data was not changed.', true);
    }
  }
  function open() {
    if (panel) return;
    previousFocus = document.activeElement;
    originals = [...phone.children].map(node => [node, node.inert]);
    for (const [node] of originals) node.inert = true;
    panel = document.createElement('section'); panel.className = 'preview-backup-screen';
    panel.setAttribute('role', 'dialog'); panel.setAttribute('aria-modal', 'true'); panel.setAttribute('aria-labelledby', 'preview-backup-title');
    panel.innerHTML = '<header><button type="button" class="icon-button" aria-label="Back to Settings" data-backup-close><svg viewBox="0 0 24 24" aria-hidden="true"><path d="M20 12H4m7-7-7 7 7 7"/></svg></button><h2 id="preview-backup-title">Prototype backup</h2></header><div class="preview-backup-content" data-backup-content></div>';
    phone.append(panel); renderStart();
    panel.addEventListener('click', event => {
      const button = event.target.closest('button'); if (!button) return;
      if (button.hasAttribute('data-backup-close')) close();
      else if (button.hasAttribute('data-backup-download')) downloadCurrent();
      else if (button.hasAttribute('data-backup-cancel')) {renderStart(); panel.querySelector('[data-backup-file]').focus();}
      else if (button.hasAttribute('data-backup-confirm')) confirmRestore();
      else if (button.hasAttribute('data-backup-reload')) location.reload();
    });
    panel.addEventListener('change', event => { if (event.target.matches('[data-backup-file]')) checkFile(event.target.files[0]); });
    panel.addEventListener('keydown', event => {
      if (event.key === 'Escape') {event.preventDefault(); close(); return;}
      if (event.key !== 'Tab') return;
      const targets = [...panel.querySelectorAll('button,input,[tabindex="0"]')].filter(el => !el.disabled && el.getClientRects().length);
      const first = targets[0], last = targets.at(-1);
      if (!targets.includes(document.activeElement)) {event.preventDefault(); (event.shiftKey ? last : first)?.focus();}
      else if (event.shiftKey && document.activeElement === first) {event.preventDefault(); last?.focus();}
      else if (!event.shiftKey && document.activeElement === last) {event.preventDefault(); first?.focus();}
    });
    panel.querySelector('[data-backup-close]').focus();
  }
  phone.addEventListener('culmina-backup', open);
  return () => {phone.removeEventListener('culmina-backup', open); close();};
}
