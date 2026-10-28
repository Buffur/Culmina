# Culmina design reference

The design rules website, application map and visual atlases live together here.
Open `/design/reference/` through a local HTTP server rooted at the repository.
The rules website loads its catalog with fetch, so use HTTP rather than `file:`.

| Directory | Contents |
| --- | --- |
| `design-rules-web/` | Design rules studio, interactive specimens, extracted catalog and complete source snapshots |
| `app-map-20261028/` | Application map, refreshed Atlas, native component library, captures, boards, manifests and generation scripts |
| `atlas/` | Historical Atlas with original captures, boards and provenance |
| `shared/` | Local Geist font, common shell colors, atlas styling and theme persistence |
| `evidence/` | Original map and component render inputs previously under build/ |
| `qa/` | Browser comparison screenshots and verification artifacts |
| `relocation.json` | Original paths and SHA-256 hashes recorded before moving 1063 files |

The old entry pages under `build/design-rules-web/`, `.audit/app-map-20261028/`
and `.audit/atlas/` redirect here and preserve query strings and fragments.
Live assets resolve inside this directory; Flutter source stays in its existing
project directories. Source viewers are copied snapshots.

Website theme applies Light/Dark across the studio and both atlas viewers,
persists between visits and follows the system on the first visit. Changing it
also selects the matching theme for interactive and native component specimens.
Use Specimen theme or Component theme to inspect Light, Dark or Field Red
independently. Historical and refreshed full-screen captures retain the theme
in which they were rendered; changing the website theme does not recolor PNGs.

Regenerate the studio after changing the project rules or theme source:

```text
python design/reference/design-rules-web/build_catalog.py
python design/reference/design-rules-web/validate_artifact.py
```

The existing map pipeline now reads render inputs from `evidence/`:

```text
python design/reference/app-map-20261028/build_map.py
```

It runs the existing extension/refinement stages and then `style_atlases.py`.
The style decorator is idempotent and can also be run separately after replacing
an atlas HTML viewer. It changes viewers, not historical image or manifest data.
Read `REVIEW.md` for checks and evidence limits.

## Historical Dart source inputs

Three original render inputs are preserved byte-for-byte as `.dart.txt` snapshots.
They contain an appended fragment or imports relative to their original generated
location under build/, not standalone Dart libraries at the new reference path.
`source-snapshots.json` records the original names, retained paths and SHA-256.
The operational prepare helper reads the retained fragment and writes its composed
Dart input under build/. Use the maintained tests under test/ for current checks.
The reference tree is not broadly excluded from Dart analysis; a future real Dart
source added here remains subject to the normal analyzer.
