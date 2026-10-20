# Read-Only Integration Review: Culmina Android Prototype

**Review Mode**: Static source-code analysis only (no browser/runtime execution, no tool/command invocation, no file edits).  
**Target Files**: `night-ui.js`, `workspace.js`, `night.css`.  
**Baseline Constraints**: 412px Android container, isolated local storage, fixed UTC24h model/cursor/bracket unchanged, presentation-only sky gradient, field mode stays pure red, single summary headline + provenance/link on Home with no expanded meteorology.

---

## 1. Concrete Bug Findings

### Bug 1: Top-level Unhandled `await fetch` Crashes Workspace Initialization
* **Severity**: Critical
* **Source**: `workspace.js`
* **Function / Scope**: Top-level module execution (`const config = await fetch(...)`)
* **Mechanism**: 
  ```javascript
  const config = await fetch('./tokens.json', {cache: 'no-store'}).then(r => {
    if (!r.ok) throw Error('Design tokens unavailable');
    return r.json();
  });
  ```
  Top-level `await` halts module evaluation. If `./tokens.json` fails to load (offline Android device, HTTP error, or local `file://` context), the promise rejection is unhandled. The module execution halts before registering tabs, event listeners, or rendering the shell. The user is left on a blank, unrecoverable screen with no fallback token set or error banner.

---

### Bug 2: Unhandled Storage Exception on Access & Broken `storage-error` Simulation Harness
* **Severity**: High
* **Source**: `workspace.js`
* **Function**: `storage` initialization & `navigate(next)`
* **Mechanism**:
  1. The storage fallback object is defined as:
     ```javascript
     let storage;
     try { storage = window.localStorage; }
     catch { storage = { getItem(){ throw Error('Browser storage is unavailable'); }, ... }; }
     ```
     When `localStorage` is disabled or restricted (e.g., Android WebView incognito / third-party storage partitioning), calling `storage.getItem(...)` inside any mounted tab throws synchronously. If tabs do not wrap every single storage access in `try/catch`, tab rendering crashes completely.
  2. In `navigate()`, `{ storage, scenario: $('#workspace-scenario').value }` is passed to the tab, but `storage` remains bound to `window.localStorage` even when the user selects `scenario = 'storage-error'`. The harness never passes the mock throwing storage, making local storage failure scenarios untestable in the prototype harness.

---

### Bug 3: Missing Browser History (`popstate`) Integration & Broken Navigation Stack
* **Severity**: High
* **Source**: `workspace.js`
* **Function**: `updateURL()` and `navigate(next)`
* **Mechanism**:
  `updateURL()` uses `history.replaceState()`, never pushing history entries. There is no `window.addEventListener('popstate', ...)` handler. When an Android user taps the hardware or OS gesture Back button:
  1. The browser exits Culmina entirely instead of popping an inner tab or sub-view.
  2. When a tab invokes `setHeader(title, backFunction)`, it sets an internal `back` callback and hides `#workspace-nav`. However, if the user switches scenarios or reloads, `back` is cleared without notifying the active sub-view lifecycle.
  3. If a tab returns an asynchronous or non-function cleanup handle, `cleanup?.()` will either fail silently or throw `TypeError: cleanup is not a function` on subsequent navigation.

---

### Bug 4: Potential `TypeError` Crash in `applyDisplay` When Toggling Field Mode
* **Severity**: High
* **Source**: `workspace.js`
* **Function**: `applyDisplay(patch)`
* **Mechanism**:
  ```javascript
  for (const [k, v] of Object.entries(config.themes[display.theme])) root.style.setProperty('--' + k, v);
  ```
  `night.css` notes that Field Mode tokens are defined in CSS (`:root[data-theme=field]`) as prototype overrides. If `tokens.json` does not include a `"field"` key under `config.themes`, `config.themes['field']` evaluates to `undefined`. `Object.entries(undefined)` throws a fatal `TypeError`, crashing `applyDisplay()` whenever the user taps `#workspace-field`.

---

### Bug 5: Stale / Unavailable Weather Data Masquerading as Valid Forecast
* **Severity**: Medium
* **Source**: `night-ui.js`
* **Function**: `weatherWidgetSummary(night, summary)`
* **Mechanism**:
  ```javascript
  const status = summary.unavailable ? 'Forecast unavailable' : summary.status;
  return {
    headline: pieces.length ? pieces.join(' · ') : 'Measurements incomplete',
    detail: `${/offline|stale|partial|gap/i.test(status) ? status + ' · ' : ''}Example forecast · during dark time`
  };
  ```
  If `summary.unavailable === true`, but cached or leftover slots exist such that `d.any` is true:
  1. `status` becomes `'Forecast unavailable'`.
  2. The regex `/offline|stale|partial|gap/i.test('Forecast unavailable')` evaluates to `false`!
  3. The detail string outputs `'Example forecast · during dark time'` with temperature and wind numbers displayed in the headline, completely concealing the fact that the forecast is unavailable.

---

### Bug 6: Dropped Link Affordance in Home Weather Detail on Available Forecast
* **Severity**: Medium
* **Source**: `night-ui.js`
* **Function**: `weatherWidgetSummary(night, summary)`
* **Mechanism**:
  The frozen requirement states: *"Weather on Home must have only one summary plus provenance and link, no expanded meteorology"*.
  When data is missing or loading, the detail string explicitly includes navigation guidance: `· open Weather`. However, when forecast data is valid, the return value becomes:
  ```javascript
  detail: `${...}Example forecast · during dark time`
  ```
  The link affordance / text (`open Weather`) is omitted, leaving the user with provenance but no clear link indication to the detailed Weather tab.

---

### Bug 7: Preceding-Hour Overlap Falsely Attributes Headline to "During Dark Time"
* **Severity**: Medium
* **Source**: `night-ui.js`
* **Function**: `weatherDigest(night, summary)` & `weatherWidgetSummary(night, summary)`
* **Mechanism**:
  In `weatherDigest`, `any` is defined as `now.length > 0 || before.length > 0`.
  If there are no dark-time rows (`now.length === 0`), but there is a preceding-interval row (`before.length > 0`, e.g., 30 min before dark):
  `d.any` is `true`, while `d.tempMin` and `d.windMax` remain `null`. `weatherWidgetSummary` bypasses the `!d.any` check and returns:
  `headline: 'Measurements incomplete', detail: 'Example forecast · during dark time'`.
  This claims dark-time attribution when zero valid measurements existed within the dark window.

---

### Bug 8: Division by Zero / `NaN` Gradient on Degenerate Interval
* **Severity**: Low
* **Source**: `night-ui.js`
* **Function**: `skyGradient(night)`
* **Mechanism**:
  ```javascript
  const at = t => f3((t - night.start) / (night.end - night.start) * 100);
  ```
  If `night.end <= night.start` (polar day/night edge cases or unit test fixtures with zero duration), `(night.end - night.start)` is `0`, causing `at(k.t)` to return `NaN`. The resulting CSS string contains `var(--sky-day) NaN%`, which invalidates the CSS `background` property and causes the sky track to render transparent or broken.

---

### Bug 9: Viewport Height Instability with Mobile Virtual Keyboard and Scrolling
* **Severity**: Low
* **Source**: `workspace.js`
* **Function**: `fitPhone()`
* **Mechanism**:
  `const top = phone.getBoundingClientRect().top; phone.style.height = Math.max(280, Math.min(852, innerHeight - top - 12)) + 'px';`
  On Android browsers, opening the soft keyboard shrinks `innerHeight`, causing the phone preview to clamp to the `280px` minimum. Additionally, because `top` is relative to the viewport, scrolling the outer host document alters `top` dynamically, triggering recalculations that jitter the phone height.

---

## 2. Review Against Frozen Integration Criteria

| Criterion | Status | Evaluation |
| :--- | :--- | :--- |
| **Home Weather Headline Truth** | ⚠️ Needs Fix | Violates truth when `summary.unavailable` is true but cached rows exist (Bug 5). Drops `open Weather` link text on valid data (Bug 6). |
| **Continuous Sky Ramp vs. Ephemeris** | ✅ Passed | Interpolation knots and `color-mix(in oklab, ...)` are strictly visual. The underlying dark bracket, cursor intervals, and `night-model` time facts remain uncorrupted. |
| **Fixed UTC24h Model & Cursor** | ✅ Passed | Cursor bounds and 5-minute quantization steps map accurately across 0–24h. |
| **Field Mode Integrity** | ⚠️ At Risk | CSS tokens properly use red-on-black (`#660000` to `#000`), but `workspace.js` risks throwing if `tokens.json` lacks a `field` definition (Bug 4). |
| **412px Phone Shell & Navigation** | ⚠️ Needs Fix | Module lacks `popstate` support for Android back gestures (Bug 3). |
| **Isolated Local Storage** | ⚠️ Needs Fix | Storage failures throw unhandled errors without graceful in-memory fallback (Bug 2). |
| **No Native Edits** | ✅ Passed | All logic is purely web-based ES modules and CSS. |

---

## 3. Recommendation: Temp + Wind vs. Cloud Headline (No Universal Score)

### Problem
A universal "observing score" (e.g., "7/10 Poor") obscures critical conditions, while a pure temperature/wind headline ignores cloud cover—the single most decisive factor for astronomical observation.

### Proposed Headline Pattern
Preserve factual reporting by structuring the single headline hierarchically based on **cloud gating**:

1. **When Cloud Data is Available**:
   * **Overcast / Blocked**: If minimum cloud cover throughout the dark period exceeds 80%:  
     `Overcast (80–100% cloud) · 8 °C`
   * **Clear / Favorable**: If clear intervals exist:  
     `Clear (0–10% cloud) · 11–13 °C · wind to 14 km/h`
   * **Partly Cloudy / Variable**:  
     `Variable clouds (20–70%) · 12 °C · wind to 18 km/h`

2. **When Cloud Data is Missing / Null**:
   * Preserve missing-data truth without guessing or assuming clear skies:  
     `11–13 °C · wind to 14 km/h (cloud unmeasured)`

3. **When All Data is Incomplete**:
   * Report exactly what is missing:  
     `Measurements incomplete`

This provides immediate astronomical utility on the Home tab without generating an arbitrary composite score.
