# Culmina geo flow design - 2026-10-23

Status: V2 APPROVED FOR IMPLEMENTATION BY OWNER; implemented and installed 2026-10-23. Final owner acceptance remains pending. [Implementation and evidence](migration/GEO_FLOW_IMPLEMENTATION_2026_10_23.md). Scope: site selection/management, Add/Edit Site, map/coordinate entry and automatic naming. Operate mode; retain existing Hybrid/Geist Android identity. This is a concrete design brief for discussion, not a new transfer or a roadmap audit.

[Current visual concept v2](migration/evidence/geo-design-2026-10-23/geo-concept-v2.png) · [Original v1](migration/evidence/geo-design-2026-10-23/geo-concept-v1.png)

The image was generated with the built-in Imagegen tool. It illustrates hierarchy, not exact Flutter geometry, live map tiles or verified interactions. All coordinates and names in the concept are examples. This document is authoritative where the illustration omits states or abbreviates controls.

## Verified baseline and observations

Task worktree `C:/Users/zalub/AppData/Local/Temp/culqa`; HEAD/origin/develop2a43c899, remote rechecked this run. The preceding Tonight refinement is an uncommitted diff on `codex/tonight-context-controls`, already installed as a release/debug-signed APK on the phone. Preserve that diff and the seven pre-existing generated line-ending-only files. Main owner checkout is untouched. Web reference `design/home-lab/` remains read-only.

Inspected sources: `sites_screen.dart`, `site_editor_screen.dart`, `site_detail_screen.dart`, `location_picker_screen.dart`, `zone_picker_dialog.dart`, `SiteViewModel`, the name-lookup wrapper/provider, coordinate validators, location feedback, shared form/spacing components and existing site tests. This covers the reachable geo flow; it is not an audit of other app areas.

Physical evidence: Xiaomi14T Pro, current release APK SHA256 `faa96548f9631863642150a88b053d6b843187a5d6f5578d79cf2cf945a34434`, dark,1220x2712,DPR3.25,text1. Add Site was already open when inspected. Expanded and restored only its local Use device position disclosure; no form edits, Save, GPS request, system permission action or settings change. Originals/XML remain at `C:/Users/zalub/CulminaQA/2026-10-23/geo-design/01-new-site.*`, `02-new-site-location-expanded.*`, `03-new-site-restored.*`. They contain existing owner coordinates and are not copied into the shareable concept.

| Surface | Finding/classification | Evidence |
| --- | --- | --- |
| Manage sites | Confirmed design concern: introductory instructions and equally weighted GPS/map/add buttons precede the actual saved sites. The hierarchy emphasizes methods instead of the selection task. | Current source and preceding native375dp capture `migration/evidence/tonight-context/native-375/android-home_sitesheet-dark.png`. |
| Add Site, initial | Confirmed visual concern: empty Name comes before position selection; GPS is hidden in a large disclosure; three large heading treatments and long captions interrupt the form. This is not a measured RenderFlex overflow. | Actual phone, current source. |
| Add Site spacing | Name input to disclosure is about12dp; collapsed location block is about78dp tall due to heading/caption; block end to Coordinates heading is20dp, heading to coordinate labels12dp. Individual gaps follow existing tokens, but heading size, caption wrapping and mixed grouping produce the poor rhythm. Global token reduction would affect unrelated forms. | UI XML raw bounds, divided by DPR3.25; no screenshot scaling used for measurement. |
| Add Site copy | Confirmed context mismatch: 'choose it separately in the Plan' is unconditional, while adding from the chooser passes activate=true. Library passes false. | SitesScreen SiteEditorArgs and editor intro. |
| GPS name, editor | Existing behavior already autofills an empty name through the consented lookup after a GPS fix. Manual name/coordinate edits and late replies are guarded. Lookup off/failure/no result still requires a manual name today. | `_applyFix`, `_proposeName`, `_nameHelper`, site tests group 'a name for the position'. |
| Map/manual coordinate name, editor | Confirmed gap against the new requested behavior: map return only changes latitude/longitude and does not invoke `_proposeName`; valid manual coordinates do not trigger name derivation either. | `_pickOnMap`, coordinate listeners. |
| Temporary position | GPS/map can be used without creating a saved site; transient names are looked up through the existing opt-in seam. Preserve this useful distinction. | `SiteViewModel.setLocation/useCurrentLocation`, `/position`, `/site/pick`. |
| Map | Design concern from source: Use this point is a small toolbar check; selected coordinates are not a persistent confirmation summary. Real tiles/GPS behavior was not executed in this design run. | LocationPickerScreen. |
| Site detail and optional fields | Existing edit/delete, time zone, elevation, Bortle/SQM/source/date and notes must remain reachable. No confirmed calculation defect or new requirement here. | SiteDetailScreen, editor, zone picker, existing tests. |

## Proposed hierarchy

### Manage sites

1. Current planning site as one compact selected row: name, coordinates/zone, textual Used for planning, separate management action. No oversized card and no repeated entry below.
2. Saved sites with a compact Add site action in the section header; search when there are saved records. Flat rows with single-choice marker and separate management action. A name tap chooses; the pencil still opens the existing details/edit/delete flow.
3. Use another position: two flat icon/action rows for Current position and Pick on map, not two full-width outlined buttons competing with Add site. Keep their loading/denied feedback and explicit meanings.
4. A temporary position has a factual Not saved label and Save as site. Never rename a remembered position 'Current position' without a fresh fix. No forced creation to plan at coordinates.

Empty state: 'Choose where you will observe' with the same Current position, Map and Add site options; no empty search or disabled list. Failed search retains current-site context and Clear search. A current site appears once. A transient position replaces the current-site summary, not a second copy of a saved entry.

### Add Site

Order: **Position -> Site name -> Time zone -> More -> Save**.

- Position actions are visible, not hidden in Use device position. GPS and map are commands, not a persistent exclusive setting. Show source/state of the selected coordinates separately. Editable latitude/longitude remain directly available offline.
- Before any valid position, show 'Choose a position to name this site automatically'. Do not invent a municipality, default to Kyiv or claim inherited coordinates came from GPS. If coordinates were inherited, label them 'From selected site - verify or replace'.
- After obtaining coordinates, automatically assign the name; the name remains editable as an optional custom label. No mandatory manual name step.
- Time zone stays an explicit choice. Device-zone prefill is labelled and verifiable; do not infer it from a settlement name or silently assume it is correct for a remote point. Unknown retains the existing mean-solar fallback.
- More(optional) is a compact disclosure row, not a second page-size heading. Retain elevation in selected units, independent Bortle/SQM and provenance, notes and external light-pollution map. Blank values remain Unknown.
- Fixed existing Cancel/Save footer remains above the IME with SafeArea. Copy reflects entry context: chooser 'Saving also uses this site for planning'; Library 'Saved to Library; current planning site is unchanged'. Editing a site retains current existing behavior.
- Back/Cancel guards dirty drafts with existing Save/Discard/Cancel. GPS/map results fill a draft only; no save before explicit Save.

### Map / coordinate entry

Keep existing actual map and offline coordinate entry. Add a compact bottom confirmation region with selected latitude/longitude and a clear full-width Use this point action. Keep OpenStreetMap attribution visible, separate from controls. GPS control stays an explicit command. Coordinates remain valid when tiles are unavailable; loading/error copy must not claim a successful fix. Returning a map point to an editor updates only that draft; the standalone position picker applies a transient position through its existing contract. Do not add place search/autocomplete or a new provider.

### Site details / edit

Keep the record detail for factual coordinates, zone and optional fields, existing Edit and confirmed Delete. Do not add another Observing site or wrapper route. Edit uses the same compact form structure but preserves its stored name and values until an explicit edit; opening a saved site never triggers a lookup automatically.

## Automatic naming contract

The owner requirement is automatic assignment, not a forced manual name field. Proposed behavior:

| State | Name and action |
| --- | --- |
| Valid coordinates + lookup enabled | Show a generated coordinate label immediately; look up settlement asynchronously, then replace only an untouched generated label with returned city/town/village/municipality. Show source attribution. |
| Lookup off | Assign `Site - 50.40000, 30.60000` automatically. Inline explanation offers the existing explicit opt-in to settlement lookup; no hidden setting change or network request. This is a coordinate label, not a claimed town name. |
| Offline/failure/no named settlement | Retain generated coordinate label and coordinates; Save works without typing. Show concise Name unavailable/Retry where appropriate. No invented nearest town. |
| Manual coordinates | Validate both numbers before deriving a label. Use an explicit lookup command for a typed pair, avoiding a network request per keystroke; the coordinate label itself updates locally. |
| GPS/map completion | For a new draft, derive from the final accepted pair; an obsolete fix/map lookup must not overwrite more recent coordinates. |
| User custom name | Preserve it through late lookups and coordinate changes. Offer a separate Use automatic name action only if requested. Do not silently rename saved sites. |
| Two points in the same settlement | Names may match; coordinates distinguish rows. Do not invent a new uniqueness requirement. |

The default-off lookup and named source remain per DECISIONS E.1 AM-01/F23 and ENGINEERING_GUARDRAILS22. Settlement names require a lookup/cached result; without consent/network, a reliable town name cannot be promised. Any alternative default policy requires an explicit separate owner decision. This proposal does not make that change.

## Layout specification for implementation

Retain AppPalette semantic roles and Geist. No new brand, dependency, global spacing token or card system.

| Relationship | Intended spacing/role |
| --- | --- |
| Page horizontal gutters | Existing20dp |
| App bar to first content | Existing12dp page inset |
| Major form groups |24dp, consistently applied locally |
| Small section label to content |8dp; use14-16sp semibold instead of repeated20sp headings |
| Label to field |4dp |
| Field to its helper |4dp |
| Neighbor fields/groups within same section |12dp |
| Latitude/longitude at ordinary scale | Two equal columns,12dp gap |
| Large text/narrow width | Stack coordinate fields; no fixed text heights; wrap label/actions without truncating essential values |
| Tap targets |48dp minimum, including Add and pencil actions |
| Footer | Existing safe/IME behavior; body scroll padding must clear footer; no artificial spacer to push it down |

Light/Dark use semantic palettes; Field retains red/black semantics. The map's Field presentation must be verified on the actual widget; the generated dark map image is not Field evidence or a new map-style decision.

## Acceptance and bounded implementation plan

If the direction is selected, implement this geo package in the same isolated task checkout, preserving the existing Tonight diff. One writer; no commit/push.

1. Replace the chooser button stack with the grouped site list/action rows; preserve selection vs management and transient position semantics.
2. Reorder and locally space the Add/Edit form; fix contextual intro copy, keep IME/footer and dirty guards.
3. Add automatic coordinate-label fallback and settlement enrichment through the existing opt-in service, with source/generation/manual-name guards.
4. Improve the map confirmation area while preserving both route result contracts, attribution and manual coordinate fallback.
5. Focused regression tests: no mandatory typing on GPS/map/offline/off naming paths; no network while Off; latest result only; no custom-name/stored-site overwrite; typed/map edits survive late GPS; source correctly labelled; Library Save does not select, chooser Save does; Cancel/IME/Back, deletion/zone/optional field preservation.
6. Capture current/proposed Flutter375dp states in Light/Dark/Field and100/200% plus keyboard. Native emulator checks supplement host renders. Only after completed authorized implementation, rebuild the release/debug-signed APK, verify package/certificate and update the connected phone with `adb install -r`, per the owner's standing instruction; preserve data. No real GPS or permission tapping on the owner's phone for QA.

This design run changed no production code. The prior106-test/native results describe Tonight work; they are not new verification of this proposed design. No new release installation is needed for a design-only deliverable. Next allowed action: owner feedback/selection of the proposed composition, then the bounded implementation cycle.


## V2 refinement review - owner follow-up, 2026-10-23

The owner found the general design acceptable and requested a hierarchy/spacing/centering review, plain edit icons and a more minimal GPS symbol. This follow-up refines the design only; it does not change the preceding production diff, install a conceptual image, or claim another physical QA pass.

### Findings and changes

| Area | V1 finding | V2 direction and acceptance criterion |
| --- | --- | --- |
| Information hierarchy | Overall sequence is appropriate: planning site first; other saved choices; alternative position commands. Add Site position before name is correct for automatic naming. | Preserve this hierarchy. Do not elevate GPS/map commands over saved sites, or move Name back ahead of a position. |
| Current-site emphasis | Section title and Used for planning row caption duplicate the same fact, enlarging only that row. | Keep the section title, remove duplicate row caption. Current site appears once. State is still textual and accessible, not color-only. |
| Edit action | Framed pencils look like another class of button; first-row pencil sits high relative to all row content. | Plain20dp outline pencil, no persistent border/fill/text, centered in48x48dp interactive region. All action centers share one trailing axis. Accessible name/tooltip includes the site name. Focus/pressed feedback remains even though resting chrome is removed. Existing selection/management routing remains as specified above; this visual follow-up does not silently alter route behavior. |
| Row alignment | Different numbers of metadata lines risk inconsistent visual centering. | Center leading choice marker and trailing action against the complete text block, not just the first name line. Minimum72dp row, intrinsic height for long metadata. Title and metadata stay start-aligned. Entire row grows at200% text. |
| GPS icon | Heavy target/filled symbols conflict with thin outline project icons; map duplicates the same action in toolbar and on the map. | One thin unfilled locate ring plus four short ticks, no center dot/extra ring.20dp glyph in24dp box;48dp tap target. Same outline/stroke family as pencil/map/back. One GPS action on map. Distinguish location status outline pin from the GPS command. |
| Form source commands | A selected-looking radio on Current position suggests a persistent mode. GPS/map are commands. | Both neutral actions; source/result is conveyed by Position found and source text below, not a false selected mode. |
| Section headings | Tracked uppercase headings are more prominent than required. | Compact sentence-case14-16sp semibold group labels, consistent baseline and local spacing. Screen titles retain existing22sp role. |
| Form geometry | Perceived group spacing is inconsistent; field edges and heights should be explicit. | Page gutters20dp; group separation24dp; same-group separation12dp; label-to-field/helper4dp; group-label-to-content8dp.48dp minimum fields/actions. Paired coordinates equal width with12dp gap; full-width Name/Zone align to their group edges. No global token changes. |
| Search/header | Add site can drift off the section header baseline. | Header is a48dp row: label start-aligned, Add site action end-aligned and vertically centered, then8dp to search. At large text, wrap to a separate action row rather than squeeze text. |
| More disclosure | Chevron should align to label+caption together. | Center chevron on complete two-line block; compact disclosure with48dp minimum target and clear expanded state. |
| Map toolbar | Two GPS actions create duplicate emphasis. Coordinate entry must remain discoverable after removing the toolbar GPS action. | Back/title/theme in toolbar, one map locate control, explicit Edit coordinates action in confirmation panel. All are48dp targets; map attribution stays visible and clear of controls. |
| Map confirmation | Coordinate value and primary action should align with the rest of the form system. |20dp panel gutters, left-aligned coordinate pair, full-width48dp Use this point. Edit coordinates is neutral semantic text, not an invented blue accent. At200%, stack/wrap coordinates and action labels as needed. |
| Footer | Cancel/Save should share size, label center and keyboard-safe position. | Equal available widths,12dp gap, minimum48dp height,16sp600 action role; safe bottom inset and existing IME treatment. If scaled labels need height, grow both. |

### Important interpretation limits

- This was a visual inspection and revision of a generated raster mockup. Numeric dp values above are the intended implementation contract, not measurements proven by the generated image. We have not verified constraints, actual hit boxes, font metrics, semantics or200% behavior in Flutter for this new composition.
- The final image keeps a small temporary-position helper near the Map row. In implementation, its meaning belongs to the whole alternative-position group, covering both GPS and map. It is not a promise that only map positions are transient.
- The generated map is illustrative example imagery. It is not provider data, a new map skin requirement, native map verification or Field-mode proof.
- Keep semantic Light/Dark/Field colors; no gradients/glow/new accent tokens should be derived from raster artifacts. Source palette, Geist and native components remain authoritative.
- Icon-only must preserve48dp hit targets, tooltip/accessibility names and focus feedback. Do not make the whole glyph the only tappable area, or merge its tap with site selection.
- Actual375dp and200% text renders, long names, coordinate wrapping, keyboard/footer, both site route contracts, map attribution and red-only Field mode remain required in the later implementation cycle.

### Deliverables and verification of this design-only revision

- Preserved original `geo-concept-v1.png`; retained intermediate and final v2 PNG siblings under `migration/evidence/geo-design-2026-10-23/`.
- Final v2 inspected after generation: pencil frames removed; site-row actions appear vertically centered; GPS symbols simplified; duplicate toolbar GPS removed; coordinate-edit text restored to the neutral palette.
- No new app code, production token, dependency, Git delivery or phone state changed in this follow-up. Tests/build/reinstallation are not applicable to this static design deliverable. The existing source verification results must not be relabelled as v2 implementation proof.


## Approved implementation update — 2026-10-23

The owner subsequently said “Погоджую, реалізуй у додаток”. The preceding proposal/design-only statements describe those earlier runs, not the current delivery state. TD-121 now implements v2 in the isolated task checkout, with targeted host tests, Android evidence, independent read-only review and a release/debug-signed update installed on the connected phone. See the linked implementation report for source/build identities, before/after images, reuse boundaries and unverified physical scenarios. No commit/push or owner acceptance is implied.


## Owner screenshot correction — 2026-10-23

The subsequent four annotated screenshots amend the earlier composition: current saved site stays inside the normal list, the temporary summary becomes a compact honest Not saved row with an explicit Save icon, Tonight uses one-line compact place/date controls, map center uses a12dp dot, and Add form removes redundant hints/action/footer rows. New valid manually entered coordinates enrich automatically after typing stops, alongside inherited/GPS/map points, through the unchanged explicit opt-in service. [Implementation, checks and installed build](migration/GEO_OWNER_REFINEMENT_2026_10_23.md). Earlier proposed ordering and explicit-manual-lookup text above are historical where superseded here. Final owner acceptance remains pending.
