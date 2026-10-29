# Culmina editable Figma transfer — 29 October 2026

[Open the Figma Design file](https://www.figma.com/design/OeDvjQ58cWoHOCSMd69GCG?node-id=9-38362).

The file contains 576 editable application frames across Light, Dark and Field
Red, including 300 continuous Longreads. The parity pass added 27 source-backed
states and corrected navigation and object identity. All 28 concrete application
screen types are represented by the captured scenarios. The previous transfer
contained 1,197 viewport frames; continuations were consolidated where their
layout and disclosure state remained stable.

| File | Purpose |
| --- | --- |
| [Culmina-current-screens.fig](Culmina-current-screens.fig) | Native editable Figma backup exported after the final fixes |
| [verification.json](verification.json) | Native structure, 20,040 assembled text observations, destination checks, source scroll behavior and saved-version receipt |
| [visual-verification.json](visual-verification.json) | Refreshed Flutter render evidence: nine cases, 51 unchanged scene descriptions and nine matching Longread dimensions |
| [provenance.json](provenance.json) | Source hashes, captured working-tree provenance and byte-identical artifact copies |
| [archive.json](archive.json) | Local work archive location, size, file count and complete manifest hash |
| [comparisons/plan-light.jpg](comparisons/plan-light.jpg) | Refreshed Flutter source and editable Figma Plan |
| [comparisons/weather-dark.jpg](comparisons/weather-dark.jpg) | Complete forecast table and weather disclosures |
| [comparisons/rig-light.jpg](comparisons/rig-light.jpg) | Existing rig fields and source values |

## Verification and scope

Native verification found no missing expected assembled text, broken node
destinations, complete-UI image fills or leftover temporary tags. The 15 Tonight
variants scroll their title with the content and retain fixed bottom navigation;
the other 285 Longreads retain their source chrome. Before/after native PNG bytes
were identical for all 15 scrolling corrections. Each theme uses a 375 × 812
prototype viewport. Live prototype checks covered scrolling and Tonight →
Library → Rigs.

Forty-five native Figma PNGs were exported. Thirty full Longread comparisons had
matching dimensions. Nine refreshed Flutter cases repaired stale compositing in
the original control PNGs; their text, paint, action and scroll descriptions
remained exactly unchanged across all 51 snapshots. The refreshed comparison
mean channel errors were 0.83–3.32 out of 255. This is renderer comparison
evidence, not a claim of pixel identity between Flutter and Figma.

The source was the working tree at capture time, including pre-existing local
application changes, based on commit `e631de00b58a65b830023dd63f33a883abca4300`.
Those application changes are excluded from this artifact delivery. Data comes
from synthetic in-memory fixtures; this is not an export of a personal database.
Source hashes make that boundary inspectable.

Figma preserves editable controls and source-backed navigation. Application
persistence, arbitrary inputs, calculations, network requests, native file
pickers and sharing operations are not executed by the static prototype.
Disclosures that close during scrolling, Welcome variants with incomplete
continuous coverage and the unstable upcoming-plan sweep remain separate
editable states. Host render, native Figma and executed prototype evidence are
distinct from Android/device, accessibility or owner acceptance.

## Local archive

Raw captures, conversion experiments, dependencies, intermediate exports and
task scripts are retained under the ignored local archive recorded in
`archive.json`. They are not uploaded to Git. Every archived file has a SHA-256
receipt in that archive's `files.json`. The registered read-only development
plugin remains at its existing local path so the registration is not broken.
The final `.fig` download path used in the chat retains a compatibility copy.
The complete archive is a machine-local recovery resource; only this final
package is versioned.
