# Artifact retention list — 2026-11-06

Each top-level build and .audit entry from the scan snapshot is listed below. The machine-readable classification records matched source paths by scope; named data references do not alone establish active consumption. Original movements are in the manifest.

## Archived confirmed obsolete smoke batch

- `build/refinement-shot-smoke` — October 28 fixture renders; no named active/script consumer; mapped in manifest.

## Excluded runtime or generated, retained

- `build/76d47982dbbd449c0d550f888f059262` — Explicit cache, runtime, vendor, or staged generated output; not a cleanup candidate.
- `build/android_file_picker` — Explicit cache, runtime, vendor, or staged generated output; not a cleanup candidate.
- `build/app` — Explicit cache, runtime, vendor, or staged generated output; not a cleanup candidate.
- `build/flutter_timezone` — Explicit cache, runtime, vendor, or staged generated output; not a cleanup candidate.
- `build/geolocator_android` — Explicit cache, runtime, vendor, or staged generated output; not a cleanup candidate.
- `build/instruction-tools-venv` — Explicit cache, runtime, vendor, or staged generated output; not a cleanup candidate.
- `build/integration_test` — Explicit cache, runtime, vendor, or staged generated output; not a cleanup candidate.
- `build/jni` — Explicit cache, runtime, vendor, or staged generated output; not a cleanup candidate.
- `build/jni_flutter` — Explicit cache, runtime, vendor, or staged generated output; not a cleanup candidate.
- `build/native_assets` — Explicit cache, runtime, vendor, or staged generated output; not a cleanup candidate.
- `build/package_info_plus` — Explicit cache, runtime, vendor, or staged generated output; not a cleanup candidate.
- `build/reports` — Explicit cache, runtime, vendor, or staged generated output; not a cleanup candidate.
- `build/shared_preferences_android` — Explicit cache, runtime, vendor, or staged generated output; not a cleanup candidate.
- `build/share_plus` — Explicit cache, runtime, vendor, or staged generated output; not a cleanup candidate.
- `build/test_cache` — Explicit cache, runtime, vendor, or staged generated output; not a cleanup candidate.
- `build/unit_test_assets` — Explicit cache, runtime, vendor, or staged generated output; not a cleanup candidate.
- `build/url_launcher_android` — Explicit cache, runtime, vendor, or staged generated output; not a cleanup candidate.

## Retained active references

- `build/.last_build_id` — Named in active project input: .gitignore.
- `build/design-rules-web` — Named in active project input: design/reference/README.md, design/reference/app-map-20261028/index.html (and others).
- `build/figma-audit-fixes-20261106` — Named in active project input: design/figma/REDESIGN_RUN.md.
- `build/figma-consolidation-20261104` — Named in active project input: design/figma/research/consolidation_2026-11-04.md.
- `build/figma-remaining-20261105` — Named in active project input: design/figma/REDESIGN_RUN.md.
- `build/figma-ssot-audit-20261104` — Named in active project input: design/figma/research/ssot_audit_2026-11-04.md.
- `build/figma-tab-groups-20261106` — Named in active project input: design/figma/REDESIGN_RUN.md.
- `build/figma-transfer-20261029` — Named in active project input: design/reference/README.md, design/reference/figma-transfer-20261029/archive.json (and others).
- `build/planning-context-20261030` — Named in active project input: docs/PLANNING_CONTEXT_2026-10-30.md.
- `build/skill-evals` — Named in active project input: tool/skill_evals/README.md.
- `build/source-audit-20261028` — Named in active project input: design/reference/REVIEW.md, design/reference/design-rules-web/index.html (and others).
- `build/ui-renders` — Named in active project input: AGENTS.md, design/reference/app-map-20261028/design-catalog.json (and others).

## Retained audit entrypoints and evidence

- `.audit/active_processes.json` — Audit index, report, historical evidence, or runtime pointer; preserve internal references.
- `.audit/app-map-20261028` — Audit index, report, historical evidence, or runtime pointer; preserve internal references.
- `.audit/atlas` — Audit index, report, historical evidence, or runtime pointer; preserve internal references.
- `.audit/audit_progress.md` — Audit index, report, historical evidence, or runtime pointer; preserve internal references.
- `.audit/logs` — Audit index, report, historical evidence, or runtime pointer; preserve internal references.
- `.audit/reports` — Audit index, report, historical evidence, or runtime pointer; preserve internal references.

## Retained data references or unresolved

- `build/53d97955e5631c59a4129c481e9004a1.cache.dill.track.dill` — Named in build data: build/equipment-release-tests.log; role and transitive consumers are unresolved.
- `build/figma-moon-20261104` — Named in build data: build/figma-moon-20261104/audit.json; retained because role and transitive consumers are unresolved.
- `build/figma-pilot-longreads` — Named in build data: build/doc-compaction-20261104/git-before.patch; role and transitive consumers are unresolved.
- `build/figma-polish-20261104` — Named in build data: build/figma-polish-20261104/verification.json; retained because role and transitive consumers are unresolved.
- `build/figma-review-03-06-20261105` — Named in build data: build/figma-stage-c-batch1-20261105/editor-spec.json; retained because role and transitive consumers are unresolved.
- `build/figma-stage-c-batch1-20261105` — Named in build data: build/figma-remaining-20261105/specs-24-27.json, build/phase2-completion/package2-states.json; retained because role and transitive consumers are unresolved.
- `build/flutter_driver_commands_0.log` — Named in build data: build/doc-compaction-20261104/log-inventory.json; retained because role and transitive consumers are unresolved.
- `build/scoped-analysis.log` — Named in build data: build/archive-before-analyzer.json, build/doc-compaction-20261104/log-inventory.json; retained because role and transitive consumers are unresolved.
- `build/startup-final.log` — Named in build data: build/phase2-completion/package3-states.json, build/phase2-completion/package4-startup-states.json; retained because role and transitive consumers are unresolved.
- `build/weather-tests.log` — Named in build data: build/archive-before-analyzer.json, build/doc-compaction-20261104/log-inventory.json; retained because role and transitive consumers are unresolved.

## Retained recent/current evidence

- `build/figma-parity-20261029` — Current or November 6 delivery, baseline, verification, or active output.
- `build/figma-parity-analyze-delivery-final.log` — Current or November 6 delivery, baseline, verification, or active output.
- `build/figma-parity-analyze-delivery.log` — Current or November 6 delivery, baseline, verification, or active output.
- `build/figma-parity-analyze-final.log` — Current or November 6 delivery, baseline, verification, or active output.
- `build/figma-parity-analyze-verified.log` — Current or November 6 delivery, baseline, verification, or active output.
- `build/figma-parity-analyze.log` — Current or November 6 delivery, baseline, verification, or active output.
- `build/figma-parity-delivery-receipt.json` — Current or November 6 delivery, baseline, verification, or active output.
- `build/figma-parity-delivery-receipt.py` — Current or November 6 delivery, baseline, verification, or active output.
- `build/figma-parity-delivery-report.md` — Current or November 6 delivery, baseline, verification, or active output.
- `build/figma-parity-final-night-a11y.log` — Current or November 6 delivery, baseline, verification, or active output.
- `build/figma-parity-final-renders` — Current or November 6 delivery, baseline, verification, or active output.
- `build/figma-parity-final-renders.log` — Current or November 6 delivery, baseline, verification, or active output.
- `build/figma-parity-final-weather` — Current or November 6 delivery, baseline, verification, or active output.
- `build/figma-parity-large-renders.log` — Current or November 6 delivery, baseline, verification, or active output.
- `build/figma-parity-longread` — Current or November 6 delivery, baseline, verification, or active output.
- `build/figma-parity-longread-home.log` — Current or November 6 delivery, baseline, verification, or active output.
- `build/figma-parity-longread-plan.log` — Current or November 6 delivery, baseline, verification, or active output.
- `build/figma-parity-longread-weather_charts.log` — Current or November 6 delivery, baseline, verification, or active output.
- `build/figma-parity-native` — Current or November 6 delivery, baseline, verification, or active output.
- `build/figma-parity-palette-renders.log` — Current or November 6 delivery, baseline, verification, or active output.
- `build/figma-parity-phone-field.png` — Current or November 6 delivery, baseline, verification, or active output.
- `build/figma-parity-phone-final.png` — Current or November 6 delivery, baseline, verification, or active output.
- `build/figma-parity-phone-light.png` — Current or November 6 delivery, baseline, verification, or active output.
- `build/figma-parity-phone-observed-final.png` — Current or November 6 delivery, baseline, verification, or active output.
- `build/figma-parity-phone-run-final.log` — Current or November 6 delivery, baseline, verification, or active output.
- `build/figma-parity-phone-run.log` — Current or November 6 delivery, baseline, verification, or active output.
- `build/figma-parity-phone-settings.png` — Current or November 6 delivery, baseline, verification, or active output.
- `build/figma-parity-phone-window-final.xml` — Current or November 6 delivery, baseline, verification, or active output.
- `build/figma-parity-phone.png` — Current or November 6 delivery, baseline, verification, or active output.
- `build/figma-parity-recovery` — Current or November 6 delivery, baseline, verification, or active output.
- `build/figma-parity-renders.log` — Current or November 6 delivery, baseline, verification, or active output.
- `build/figma-parity-selected-weather` — Current or November 6 delivery, baseline, verification, or active output.
- `build/figma-parity-source-manifest-delivery.json` — Current or November 6 delivery, baseline, verification, or active output.
- `build/figma-parity-source-manifest-final.json` — Current or November 6 delivery, baseline, verification, or active output.
- `build/figma-parity-source-manifest-verified.json` — Current or November 6 delivery, baseline, verification, or active output.
- `build/figma-parity-source-manifest.json` — Current or November 6 delivery, baseline, verification, or active output.
- `build/figma-parity-targeted-final.log` — Current or November 6 delivery, baseline, verification, or active output.
- `build/figma-parity-tests-clean-interrupted.log` — Current or November 6 delivery, baseline, verification, or active output.
- `build/figma-parity-tests-clean.log` — Current or November 6 delivery, baseline, verification, or active output.
- `build/figma-parity-tests-delivery.log` — Current or November 6 delivery, baseline, verification, or active output.
- `build/figma-parity-tests-final.log` — Current or November 6 delivery, baseline, verification, or active output.
- `build/figma-parity-tests-gate.log` — Current or November 6 delivery, baseline, verification, or active output.
- `build/figma-parity-tests-verified.log` — Current or November 6 delivery, baseline, verification, or active output.
- `build/figma-parity-tests.log` — Current or November 6 delivery, baseline, verification, or active output.
- `build/figma-parity-tracking-fallback-test.log` — Current or November 6 delivery, baseline, verification, or active output.
- `build/figma-parity-weather-large.log` — Current or November 6 delivery, baseline, verification, or active output.
- `build/figma-parity-weather-longread` — Current or November 6 delivery, baseline, verification, or active output.
- `build/figma-parity-weather-longread.log` — Current or November 6 delivery, baseline, verification, or active output.
- `build/figma-parity-weather-viewport.log` — Current or November 6 delivery, baseline, verification, or active output.
- `build/figma-parity-window.xml` — Current or November 6 delivery, baseline, verification, or active output.
- `build/final-repository-check` — Current or November 6 delivery, baseline, verification, or active output.
- `build/phase1-analyze-final.log` — Current or November 6 delivery, baseline, verification, or active output.
- `build/phase1-analyze.log` — Current or November 6 delivery, baseline, verification, or active output.
- `build/phase1-anchor-tests.log` — Current or November 6 delivery, baseline, verification, or active output.
- `build/phase1-final-fixes-tests.log` — Current or November 6 delivery, baseline, verification, or active output.
- `build/phase1-full-tests.log` — Current or November 6 delivery, baseline, verification, or active output.
- `build/phase1-phone-final.xml` — Current or November 6 delivery, baseline, verification, or active output.
- `build/phase1-phone-plan.png` — Current or November 6 delivery, baseline, verification, or active output.
- `build/phase1-phone-target.png` — Current or November 6 delivery, baseline, verification, or active output.
- `build/phase1-phone-target.xml` — Current or November 6 delivery, baseline, verification, or active output.
- `build/phase1-phone.png` — Current or November 6 delivery, baseline, verification, or active output.
- `build/phase1-phone.xml` — Current or November 6 delivery, baseline, verification, or active output.
- `build/phase1-relevant-tests.log` — Current or November 6 delivery, baseline, verification, or active output.
- `build/phase1-renders` — Current or November 6 delivery, baseline, verification, or active output.
- `build/phase1-renders.log` — Current or November 6 delivery, baseline, verification, or active output.
- `build/phase2-analyze-final.log` — Current or November 6 delivery, baseline, verification, or active output.
- `build/phase2-android-vm.py` — Current or November 6 delivery, baseline, verification, or active output.
- `build/phase2-baseline.json` — Current or November 6 delivery, baseline, verification, or active output.
- `build/phase2-candidates-gate.log` — Current or November 6 delivery, baseline, verification, or active output.
- `build/phase2-completion` — Current or November 6 delivery, baseline, verification, or active output.
- `build/phase2-completion-coordinate-error-analyze.log` — Current or November 6 delivery, baseline, verification, or active output.
- `build/phase2-completion-coordinate-error-narrow-analyze.log` — Current or November 6 delivery, baseline, verification, or active output.
- `build/phase2-completion-coordinate-error-narrow-test.log` — Current or November 6 delivery, baseline, verification, or active output.
- `build/phase2-completion-coordinate-error-test.log` — Current or November 6 delivery, baseline, verification, or active output.
- `build/phase2-completion-last-settings-preflight.log` — Current or November 6 delivery, baseline, verification, or active output.
- `build/phase2-completion-last-state-tests-2.log` — Current or November 6 delivery, baseline, verification, or active output.
- `build/phase2-completion-last-state-tests.log` — Current or November 6 delivery, baseline, verification, or active output.
- `build/phase2-completion-package1-alias-final.log` — Current or November 6 delivery, baseline, verification, or active output.
- `build/phase2-completion-package1-alias.log` — Current or November 6 delivery, baseline, verification, or active output.
- `build/phase2-completion-package1-axis-v2.log` — Current or November 6 delivery, baseline, verification, or active output.
- `build/phase2-completion-package1-boundary-final.log` — Current or November 6 delivery, baseline, verification, or active output.
- `build/phase2-completion-package1-final-current.log` — Current or November 6 delivery, baseline, verification, or active output.
- `build/phase2-completion-package1-final.log` — Current or November 6 delivery, baseline, verification, or active output.
- `build/phase2-completion-package1-first.log` — Current or November 6 delivery, baseline, verification, or active output.
- `build/phase2-completion-package1-owned.log` — Current or November 6 delivery, baseline, verification, or active output.
- `build/phase2-completion-package1-repair.log` — Current or November 6 delivery, baseline, verification, or active output.
- `build/phase2-completion-package1-row-adaptation.log` — Current or November 6 delivery, baseline, verification, or active output.
- `build/phase2-completion-package1-second.log` — Current or November 6 delivery, baseline, verification, or active output.
- `build/phase2-completion-package1-uniform-unknown.log` — Current or November 6 delivery, baseline, verification, or active output.
- `build/phase2-completion-package2-first.log` — Current or November 6 delivery, baseline, verification, or active output.
- `build/phase2-completion-package3-counts-repair.log` — Current or November 6 delivery, baseline, verification, or active output.
- `build/phase2-completion-package3-first.log` — Current or November 6 delivery, baseline, verification, or active output.
- `build/phase2-completion-package3-gap-analyze.log` — Current or November 6 delivery, baseline, verification, or active output.
- `build/phase2-completion-package3-gap-final-analyze.log` — Current or November 6 delivery, baseline, verification, or active output.
- `build/phase2-completion-package3-gap-final-test.log` — Current or November 6 delivery, baseline, verification, or active output.
- `build/phase2-completion-package3-gap-repair-analyze.log` — Current or November 6 delivery, baseline, verification, or active output.
- `build/phase2-completion-package3-gap-repair-test.log` — Current or November 6 delivery, baseline, verification, or active output.
- `build/phase2-completion-package3-gap-test.log` — Current or November 6 delivery, baseline, verification, or active output.
- `build/phase2-completion-package3-second.log` — Current or November 6 delivery, baseline, verification, or active output.
- `build/phase2-completion-package4-settings.log` — Current or November 6 delivery, baseline, verification, or active output.
- `build/phase2-completion-package4-startup-repair.log` — Current or November 6 delivery, baseline, verification, or active output.
- `build/phase2-completion-package4-startup.log` — Current or November 6 delivery, baseline, verification, or active output.
- `build/phase2-completion-parent-final-preflight.log` — Current or November 6 delivery, baseline, verification, or active output.
- `build/phase2-completion-parent-final-tests.log` — Current or November 6 delivery, baseline, verification, or active output.
- `build/phase2-completion-parent-preflight-final.log` — Current or November 6 delivery, baseline, verification, or active output.
- `build/phase2-completion-parent-preflight.log` — Current or November 6 delivery, baseline, verification, or active output.
- `build/phase2-completion-records-startup-final.log` — Current or November 6 delivery, baseline, verification, or active output.
- `build/phase2-completion-settings-adapters-final.log` — Current or November 6 delivery, baseline, verification, or active output.
- `build/phase2-completion-site-gps-pending-final.log` — Current or November 6 delivery, baseline, verification, or active output.
- `build/phase2-completion-site-pending-analyze.log` — Current or November 6 delivery, baseline, verification, or active output.
- `build/phase2-completion-site-pending-test-final.log` — Current or November 6 delivery, baseline, verification, or active output.
- `build/phase2-completion-site-pending-test.log` — Current or November 6 delivery, baseline, verification, or active output.
- `build/phase2-critical-tests.log` — Current or November 6 delivery, baseline, verification, or active output.
- `build/phase2-delivery-receipt.json` — Current or November 6 delivery, baseline, verification, or active output.
- `build/phase2-device-preservation.py` — Current or November 6 delivery, baseline, verification, or active output.
- `build/phase2-final-receipt.py` — Current or November 6 delivery, baseline, verification, or active output.
- `build/phase2-full-tests-final.log` — Current or November 6 delivery, baseline, verification, or active output.
- `build/phase2-full-tests.log` — Current or November 6 delivery, baseline, verification, or active output.
- `build/phase2-package1-analyze.log` — Current or November 6 delivery, baseline, verification, or active output.
- `build/phase2-package2-analyze.log` — Current or November 6 delivery, baseline, verification, or active output.
- `build/phase2-package3-analyze.log` — Current or November 6 delivery, baseline, verification, or active output.
- `build/phase2-package4-analyze.log` — Current or November 6 delivery, baseline, verification, or active output.
- `build/phase2-phone-logbook.png` — Current or November 6 delivery, baseline, verification, or active output.
- `build/phase2-phone-moon.png` — Current or November 6 delivery, baseline, verification, or active output.
- `build/phase2-phone-night.png` — Current or November 6 delivery, baseline, verification, or active output.
- `build/phase2-phone-planning.png` — Current or November 6 delivery, baseline, verification, or active output.
- `build/phase2-phone-rig.png` — Current or November 6 delivery, baseline, verification, or active output.
- `build/phase2-phone-weather.png` — Current or November 6 delivery, baseline, verification, or active output.
- `build/phase2-phone.xml` — Current or November 6 delivery, baseline, verification, or active output.
- `build/phase2-production-launch.py` — Current or November 6 delivery, baseline, verification, or active output.
- `build/phase2-release-gate-tests.log` — Current or November 6 delivery, baseline, verification, or active output.
- `build/phase2-release-source-hashes.json` — Current or November 6 delivery, baseline, verification, or active output.
- `build/phase2-renders` — Current or November 6 delivery, baseline, verification, or active output.
- `build/phase2-renders.log` — Current or November 6 delivery, baseline, verification, or active output.
- `build/phase2-restore-owner-data.py` — Current or November 6 delivery, baseline, verification, or active output.
- `build/phase2-settings-snapshots.py` — Current or November 6 delivery, baseline, verification, or active output.
- `build/phase2-source-audit.json` — Current or November 6 delivery, baseline, verification, or active output.
- `build/phase2-wrap-settings.py` — Current or November 6 delivery, baseline, verification, or active output.
- `build/responsive-analyze.log` — Current or November 6 delivery, baseline, verification, or active output.
- `build/responsive-before.xml` — Current or November 6 delivery, baseline, verification, or active output.
- `build/responsive-library-after.png` — Current or November 6 delivery, baseline, verification, or active output.
- `build/responsive-library-after.xml` — Current or November 6 delivery, baseline, verification, or active output.
- `build/responsive-logbook-after.png` — Current or November 6 delivery, baseline, verification, or active output.
- `build/responsive-logbook-after.xml` — Current or November 6 delivery, baseline, verification, or active output.
- `build/responsive-logbook-before.png` — Current or November 6 delivery, baseline, verification, or active output.
- `build/responsive-navigation-tests.log` — Current or November 6 delivery, baseline, verification, or active output.
- `build/responsive-renders-320` — Current or November 6 delivery, baseline, verification, or active output.
- `build/responsive-renders-320-completed.log` — Current or November 6 delivery, baseline, verification, or active output.
- `build/responsive-renders-320.log` — Current or November 6 delivery, baseline, verification, or active output.
- `build/responsive-renders-800` — Current or November 6 delivery, baseline, verification, or active output.
- `build/responsive-renders-800.log` — Current or November 6 delivery, baseline, verification, or active output.
- `build/responsive-report.py` — Current or November 6 delivery, baseline, verification, or active output.
- `build/responsive-settings-after.png` — Current or November 6 delivery, baseline, verification, or active output.
- `build/responsive-settings-after.xml` — Current or November 6 delivery, baseline, verification, or active output.
- `build/responsive-verification.json` — Current or November 6 delivery, baseline, verification, or active output.

## Retained script references

- `build/check_safety_snapshot.py` — Named in build script: build/write_safety_report.py.
- `build/design-refinement-20261028` — Named in build script: build/design-refinement-20261028/prepare_harness.py.
- `build/figma-f01` — Named in build script: build/figma-f01/continuation6-resource-library.executed.js, build/figma-f01/resource-isolation-audit.executed.js (and others).
- `build/figma-f01-r` — Named in build script: build/figma-f01/continuation6-resource-library.executed.js, build/figma-f01/resource-isolation-audit.executed.js (and others).
- `build/figma-nav-icons-20261104` — Named in build script: build/figma-parity-delivery-receipt.py.
- `build/figma-weather-g2-20261105` — Named in build script: build/figma-parity-delivery-receipt.py.
- `build/figma-weather-hourly-20261105` — Named in build script: build/figma-weather-hourly-20261105/cleanup-export-selection.js.
- `build/figma-weather-reference-20261105` — Named in build script: build/phase2-completion/package1_states_inventory.py.
- `build/goal-safety-20261106.md` — Named in build script: build/write_safety_report.py.
- `build/goal-safety-source-sha256.json` — Named in build script: build/check_safety_snapshot.py, build/write_safety_report.py.
- `build/plan-density-20261028` — Named in build script: build/plan-density-20261028/study/render_density_test.dart.
- `build/plan-refinement` — Named in build script: build/plan-refinement/provenance.py.
- `build/ssot` — Named in build script: build/ssot/compare_renders.py.
- `build/typography-migration` — Named in build script: build/typography-migration/migrate.py.
- `build/ui-lab-20261029` — Named in build script: build/penpot-20261029/quality-recovery/prepare_recovery.py, build/penpot-20261029/quality-recovery/render_recovered.py (and others).

## Retained stateful Penpot

- `build/penpot-20261029` — Contains local workspaces, service data, vendor or potential external consumers.

## Retained unresolved historical/static

- `build/038e73cf314d0ddab7bcdad1c01ebb97.cache.dill.track.dill` — No conclusive obsolescence; preserve provenance, potential dynamic or external consumers.
- `build/4189cf65caed1f673f0abbe75cfabebb.cache.dill.track.dill` — No conclusive obsolescence; preserve provenance, potential dynamic or external consumers.
- `build/analysis-corrections.log` — No conclusive obsolescence; preserve provenance, potential dynamic or external consumers.
- `build/archive-before-analyzer.json` — No conclusive obsolescence; preserve provenance, potential dynamic or external consumers.
- `build/atlas-freshness-20261028` — No conclusive obsolescence; preserve provenance, potential dynamic or external consumers.
- `build/atlas-repair` — No conclusive obsolescence; preserve provenance, potential dynamic or external consumers.
- `build/atlas-repair-all` — No conclusive obsolescence; preserve provenance, potential dynamic or external consumers.
- `build/bbb4c0f89fe934879820f9b8b676e861.cache.dill.track.dill` — No conclusive obsolescence; preserve provenance, potential dynamic or external consumers.
- `build/bootstrap-config-validation.json` — No conclusive obsolescence; preserve provenance, potential dynamic or external consumers.
- `build/bootstrap-renders` — No conclusive obsolescence; preserve provenance, potential dynamic or external consumers.
- `build/ci-tests.log` — No conclusive obsolescence; preserve provenance, potential dynamic or external consumers.
- `build/create_safety_snapshot.py` — No conclusive obsolescence; preserve provenance, potential dynamic or external consumers.
- `build/design-guidance-cleanup-20261028` — No conclusive obsolescence; preserve provenance, potential dynamic or external consumers.
- `build/doc-01-contract-validation.json` — No conclusive obsolescence; preserve provenance, potential dynamic or external consumers.
- `build/doc-compaction-20261104` — No conclusive obsolescence; preserve provenance, potential dynamic or external consumers.
- `build/equipment-before.log` — No conclusive obsolescence; preserve provenance, potential dynamic or external consumers.
- `build/equipment-release-tests.log` — No conclusive obsolescence; preserve provenance, potential dynamic or external consumers.
- `build/figma-authoring-sync-20261104` — No conclusive obsolescence; preserve provenance, potential dynamic or external consumers.
- `build/figma-candidates-a-20261105` — No conclusive obsolescence; preserve provenance, potential dynamic or external consumers.
- `build/figma-candidates-geometry-20261105` — No conclusive obsolescence; preserve provenance, potential dynamic or external consumers.
- `build/figma-candidates-notion-20261105` — No conclusive obsolescence; preserve provenance, potential dynamic or external consumers.
- `build/figma-candidates-qa2-20261105` — No conclusive obsolescence; preserve provenance, potential dynamic or external consumers.
- `build/figma-flutter-anchor-parity-20261106` — No conclusive obsolescence; preserve provenance, potential dynamic or external consumers.
- `build/figma-moon-20261105` — No conclusive obsolescence; preserve provenance, potential dynamic or external consumers.
- `build/figma-next-06-20261105` — No conclusive obsolescence; preserve provenance, potential dynamic or external consumers.
- `build/figma-night-20261104` — No conclusive obsolescence; preserve provenance, potential dynamic or external consumers.
- `build/figma-plan-transfer-20261104` — No conclusive obsolescence; preserve provenance, potential dynamic or external consumers.
- `build/figma-weather-20261105` — No conclusive obsolescence; preserve provenance, potential dynamic or external consumers.
- `build/figma-weather-copy-20261105` — No conclusive obsolescence; preserve provenance, potential dynamic or external consumers.
- `build/figma-weather-correction-20261105` — No conclusive obsolescence; preserve provenance, potential dynamic or external consumers.
- `build/figma-weather-v2-20261105` — No conclusive obsolescence; preserve provenance, potential dynamic or external consumers.
- `build/final-diff-check.log` — No conclusive obsolescence; preserve provenance, potential dynamic or external consumers.
- `build/fit-before.log` — No conclusive obsolescence; preserve provenance, potential dynamic or external consumers.
- `build/fit-startup-tests.log` — No conclusive obsolescence; preserve provenance, potential dynamic or external consumers.
- `build/instruction-check.log` — No conclusive obsolescence; preserve provenance, potential dynamic or external consumers.
- `build/instruction-unit-tests.log` — No conclusive obsolescence; preserve provenance, potential dynamic or external consumers.
- `build/plan-night-20261028` — No conclusive obsolescence; preserve provenance, potential dynamic or external consumers.
- `build/refinement-tonight-plan-20261028` — No conclusive obsolescence; preserve provenance, potential dynamic or external consumers.
- `build/release-signing-guard.log` — No conclusive obsolescence; preserve provenance, potential dynamic or external consumers.
- `build/restore-safety-tests.log` — No conclusive obsolescence; preserve provenance, potential dynamic or external consumers.
- `build/snapshot_blob.bin.d` — No conclusive obsolescence; preserve provenance, potential dynamic or external consumers.
- `build/startup-safety.log` — No conclusive obsolescence; preserve provenance, potential dynamic or external consumers.
- `build/target-card-review` — No conclusive obsolescence; preserve provenance, potential dynamic or external consumers.
- `build/tonight-refinement-before` — No conclusive obsolescence; preserve provenance, potential dynamic or external consumers.
- `build/weather-analysis.log` — No conclusive obsolescence; preserve provenance, potential dynamic or external consumers.
- `build/weather-before.log` — No conclusive obsolescence; preserve provenance, potential dynamic or external consumers.
- `build/weather-correction-contract-check.json` — No conclusive obsolescence; preserve provenance, potential dynamic or external consumers.
- `build/weather-value-analysis.log` — No conclusive obsolescence; preserve provenance, potential dynamic or external consumers.
- `build/write_safety_report.py` — No conclusive obsolescence; preserve provenance, potential dynamic or external consumers.
