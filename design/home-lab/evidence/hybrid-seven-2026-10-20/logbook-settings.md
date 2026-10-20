# Hybrid refinements 3 and 7

Implemented only when the workspace variant is `blend`; Paper was exercised as a non-Hybrid control. Changed `logbook.js`, `logbook.css`, and `settings.js`. The parent supplies the variant through the workspace module API.

- Progress uses one introductory sentence, one compact result-count/last-imaged line, clearer target/filter/group hierarchy, and a closed “How totals are grouped” disclosure. Every numeric total, group identity, and unknown-sensitivity explanation is retained. The two filter-group lists compare exactly with Paper.
- An identical settings file now shows “Already up to date” with Close. It neither offers Replace nor writes storage. Equality compares actual validated values recursively and ignores object key order; rounded display labels do not decide equality. A differing value below display precision retains explicit replacement and gets accurate explanatory copy.
- Different files retain Cancel, explicit Replace, download-first, storage error and retry behavior. Read-revision guards are untouched.

Used Culmina rules/components/typography and Impeccable craft-floor instructions. Browser verification followed the Playwright CLI skill with a named in-memory Edge session and current CLI documentation fetched through Context7. No owner browser/session was attached.

Three bounded CLI scripts and their checked assertions are recorded in `logbook-settings-checks.json`. The scripts contain the actions and assertions; no test-runner dependency was added. `node --check` passed for both changed JavaScript files. Final render checks cover light/dark/field at200%, unknown sensitivity, overflow and the parent's reserved status row. All observed final page-error events: zero.

Captures: `progress-light-200.png`, `progress-dark-200.png`, `progress-field-200.png`, `settings-identical-200.png`. Settings JSON fixtures are browser-generated example defaults and controlled test changes, not owner data. These are browser-prototype checks, not native/device/science acceptance.
