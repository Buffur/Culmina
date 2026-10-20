# Settings module — 2026-10-20

Current Hybrid behaviour is documented in [the subsequent implementation and QA](../../../docs/design/HYBRID_IMPLEMENTATION_2026_10_20.md). This dated record describes the earlier tabs baseline; its separate-Plan/backup limitations are superseded where explicitly implemented there.

Scope: the Android browser prototype. `settings.js` exports `mountSettings(root, api)`; `settings.css` scopes styling to `.settings-view`. The CLI worker wrote JavaScript and then hit a session limit. Parent work supplied CSS/report, fixed initial focus, connected the shell and performed the browser checks; the interrupted worker is not labelled successful.

Functional sources read are recorded in [the CLI summary](tabs-2026-10-20/claude-settings-result.json): SettingsScreen, DisplaySettingsSection, BackupSection, PlanningPreferences, DisplayUnits, FieldModeButton, AboutScreen and AppIdentity. Parent source inspection confirmed planning defaults/ranges and UI units against the current implementation.

Implemented pages: Appearance, Planning, Privacy, Backup & data, About. Appearance offers System/Light/Dark, separate field mode, lab text size and stored display units. System follows `matchMedia`; text size remains a preview control. Planning includes altitude, Sun darkness limit, margin, frame interval, existing Moon/cloud gates, optional dither/refocus/filter/flip/setup timing, NPF and dew-margin assumptions. Save/Cancel and dirty guard are explicit. Defaults/ranges follow the model; they are not universal scientific thresholds. These settings do not rewrite or recalculate the separate Plan preview.

Only key: `culmina-settings-preview-v1`, `{kind, version, savedAtUtc, settings}`. Reads/writes handle invalid/denied storage. Failed Save retains changes and exposes Retry. Place-name lookup stores a local preference and contacts no provider. About identifies application source data rather than claiming live forecasts here.

Backup is an actual Blob/JSON download of these preview settings only. Restore checks file size/type/schema/version/ranges, previews changes, and applies only after Replace settings. It does not parse or restore a native `.astroplan` database. Invalid input preserves current values.

Executed browser checks: planning Save/Cancel, persisted values, theme and field toggling, 200% appearance/planning, privacy preference, actual download, malformed restore refusal, no mutation before confirmation, valid confirmed restore, storage failure/Retry, corrupt/denied stores, missing design resource Retry and preserved plan/checkpoint. All five subpages (Planning with advanced disclosure) were measured at 200% in three themes. [Integrated evidence](TABS_PREVIEW.md) records exact checks and limits.
