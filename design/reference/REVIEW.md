# Reference consolidation and theme review — 2026-10-28

## Decision

Implemented the requested consolidation and shared website styling. Owner review
is pending; no native product design acceptance is implied.

The previous layout split the studio under build/ and the two atlas viewers
under .audit/. The studio shell was always dark even when its specimens were
light. The new structure keeps the website, render inputs, images, scripts and
shared assets together in `design/reference/`. Both atlases use the studio's
Geist typography, neutral surfaces, navigation and Light/Dark shell roles.

## Success criteria and checks

- Moved 1063 files and verified all bytes immediately after relocation.
  `relocation.json` records every original hash and location. Subsequent changes
  are limited to viewer HTML/CSS/JS, scripts, links and regenerated rule snapshots.
- The artifact validator passes with 27 current source snapshots, 96 indexed
  statements, 255 native component samples and 16 scientific examples; no missing
  static entry-page links. It rechecks 751 image/font/manifest hashes from the
  relocation inventory. Original captured images and provenance manifests remain
  unchanged.
- Browser checks in the pinned local Playwright Chromium: website Light/Dark,
  persistence after reload and navigation, independent Field Red specimen choice,
  actual Light native image URLs (93 specimens including scientific examples),
  Field Red gallery (85), and no broken loaded native images in the checked view.
- All three old entry pages redirect, preserving fragments. Direct `#atlas`
  opens the Atlas panel and renders 63 captures. Searching Weather returns four
  captures. The pre-existing initial-hash bug was corrected.
- Edit → Leave plan opens the unsaved-changes dialog; Escape dismisses it.
- At 390×844, studio, current Atlas and historical Atlas have document width
  390 px. Studio also retains that width with specimen text at 200%. Long rule
  paths wrap; the phone specimen and sidebar own their intended local scrolling.
- JavaScript syntax and Python compilation checks pass. The source catalog
  generator and idempotent style decorator run successfully. The full historical
  map regeneration pipeline was updated for the new inputs but was not rerun.
- Instruction validator: 26 skills, 48 Markdown files, zero errors. Its nine
  unit tests pass using the existing instruction-tool Python environment.

## Comparison and limits

`qa/` contains matched 1280×720 before/after studio and current Atlas screenshots
plus mobile checks. Dark captures use the same existing content; regenerated
studio metadata includes this relocation's documentation changes, so its indexed
statement count differs from the original screenshot. Light is a newly supported
website shell and has no previous Light baseline.

Full-screen Atlas PNGs remain their original Dark/100% synthetic Flutter host
captures. Website theme changes their surrounding viewer, not their pixels.
Native component specimens switch between existing Light, Dark and Field Red
renders. No Flutter production code, native render, Android, TalkBack, user study
or release verification was performed for this website task.

## Repository verification after consolidation

Historical source inputs are retained as `.dart.txt`, with byte hashes in
`source-snapshots.json`. This resolves diagnostics from treating a source fragment
and generated-location test snapshots as standalone libraries. No broad analyzer
exclusion for `design/reference/` is used. The prepare helper consumes the retained
fragment at its new path. README routes the historical Atlas and manifest to
`design/reference/atlas/`; the old entry remains a redirect.

Reference files use Git `-text` attributes to retain byte provenance across
checkouts. Live source catalog hashes instead use canonical UTF-8/LF text; original
image, font and provenance manifest hashes remain byte-based and unchanged.
The catalog now also exposes AppTextTheme and CulminaMarkColors runtime sources.

A staged-checkout validation also caught three viewer links into the ignored local
build cache. All 36 earlier source-audit captures and their 36 metadata files are
now retained under evidence/source-audit-20261028/, with an additional byte-hash
manifest. Viewer links use these committed relative assets. Validation succeeds
without any local build directory or previous .audit capture directories.
