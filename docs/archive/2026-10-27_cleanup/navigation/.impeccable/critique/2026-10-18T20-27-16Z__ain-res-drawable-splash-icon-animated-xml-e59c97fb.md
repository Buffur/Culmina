> **Historical navigation copy — not active instructions.** Link destinations are rebased from `.impeccable/critique/2026-10-18T20-27-16Z__ain-res-drawable-splash-icon-animated-xml-e59c97fb.md`. Content and acceptance statements retain their original date/scope. [Immutable original](../../../.impeccable/critique/2026-10-18T20-27-16Z__ain-res-drawable-splash-icon-animated-xml-e59c97fb.md) · [Navigation index](../../../NAVIGATION.md). Original SHA-256: `ec692cfd4bf0d6c042b58e5aea1846e88921ee97366a41b92d4c9291328286b9`.

---
target: Existing Culmina logo and animation
total_score: 13
max_score: 16
na_heuristics: 3,5,6,7,9,10
p0_count: 0
p1_count: 0
target_identity: "file:C:\\Users\\zalub\\OneDrive\\Desktop\\Astro Planner\\Astro-Planner\\android\\app\\src\\main\\res\\drawable\\splash_icon_animated.xml"
target_fingerprint: "sha256:3e4dd963592dc50e5314a89cfd8b669a5c31dd7f8070d581d85e57089a280cfb"
target_path: "C:\\Users\\zalub\\OneDrive\\Desktop\\Astro Planner\\Astro-Planner\\android\\app\\src\\main\\res\\drawable\\splash_icon_animated.xml"
timestamp: 2026-10-18T20-27-16Z
slug: ain-res-drawable-splash-icon-animated-xml-e59c97fb
---
Method: dual-agent (A: /root/logo_design_review; B: /root/logo_evidence_review).

# Culmina R3-final logo and motion review — 2026-10-18

Scope: analysis and proposals only. The approved identity and held one-second splash remain the baseline. No application changes or device validation were performed.

## Product context and specificity

Culmina is an offline-first astrophotography session and capture planner for manual and semi-automated imagers. The current AM-01 direction foregrounds capture blocks, integration/total duration, storage and relative stacking gain, with scientific detail available through progressive disclosure. The visual brief calls for calm precision, readable field use and restrained motion.

Keep R3-final: the open C, concentric arcs and ice-blue culmination star form a coherent astronomical identity. The logo need not depict every planning capability. Its specificity comes from the complete composition; additional sparkle decoration would weaken the restrained character.

## What works

- The dominant orbit is centred at (54,54), preserving stability against launcher masks.
- Navy #0B1230, outer orbit #E6EBF7, inner orbit #7F8DC0 and star #8CCBFF form a clear hierarchy.
- Native launcher, animated vector and Flutter loading mark share geometry and palette.
- Sequential icon then background fading avoids displaying the logo over app content.

## Current motion, verified in source

Android 12+: outer orbit draws at 0–650 ms; inner orbit at 150–750 ms. The star scales 0.5 to 1 and rotates -30 to 0 degrees at 500–1000 ms; opacity rises from 0 to 1 at 500–750 ms. The approved second is held, followed by 120 ms icon fade and 150 ms background fade. The native exit bypasses the hold/fades when animators are disabled.

Flutter continuation appears only while bootstrap actually loads: star opacity 1 to 0.6 to 1 over 1600 ms. Reduced motion stops the animation with the star fully visible. This is an indeterminate loading cue, not numerical progress.

## Priority issues — optional P3 refinements

1. The star simultaneously changes scale, rotation and opacity. Rotation is the least necessary effect and makes the finish more playful than the product brief. Proposal: remove rotation and reduce the scale excursion. Suggested command: impeccable animate.
2. Final star geometry is reached at 1000 ms, when exit may begin. There is no explicit resting interval. Proposal: finish formation around 800 ms and reserve the final 200 ms of the approved second for the complete still mark. Suggested command: impeccable animate, followed by polish.

Neither issue is a release blocker or permission to implement.

## Proposed directions

| Direction | Motion | Tradeoff |
|---|---|---|
| Quiet culmination — recommended | Keep drawing both arcs, remove star rotation, scale star approximately 0.8 to 1, finish by 800 ms and rest until 1000 ms | Closest refinement of the accepted story |
| Steady instrument | Complete mark visible from the beginning; one restrained star brightness change | Immediate recognition, less theatrical formation |
| One coherent trace | Coordinate both arc reveals as one gesture, star appears through opacity only, final 150–200 ms still | Greater sense of a single construction; needs timing exploration |

Suggested prototype timeline for Quiet culmination: outer arc 0–600 ms, inner arc 100–650 ms, star 400–800 ms, still mark 800–1000 ms; preserve the current separate 120/150 ms exit for the first comparison. These are proposed timings, not measurements or accepted amendments.

Keep paths, centring, colours and final geometry. Avoid additional particles, bloom, orbiting satellites or bounce. For small artwork below 32 px, evaluate an optical variant with a slightly stronger or omitted inner arc separately; do not alter the master without comparison.

## Scoped heuristic scores

Provisional expert judgment, not a usability or scientific validation.

| Nielsen heuristic | Score | Reason |
|---|---|---|
| 1. System status | 3/4 | Actual-loading continuation is honest; native sequence is a fixed brand moment |
| 2. Real-world match | 3/4 | Celestial metaphor fits the domain |
| 3. User control | n/a | No interactive choice in this scoped mark |
| 4. Consistency | 4/4 | Shared inspected geometry and palette |
| 5. Error prevention | n/a | No input |
| 6. Recognition over recall | n/a | No navigation or task choices |
| 7. Efficiency | n/a | No task operation; the held second is approved |
| 8. Aesthetic minimalism | 3/4 | Strong composition; simultaneous star effects can be simplified |
| 9. Error recovery | n/a | Outside the target |
| 10. Help | n/a | Outside the target |
| Total | 13/16 — Good | Scoped logo and motion assessment |

## Cognitive load, emotional journey and personas

Low cognitive load: one mark and no visible choices. Initial incomplete arcs can resemble a loader before the star identifies the composition; the assembled mark is satisfying but deserves a still finishing beat. Frequent users repeatedly experience the intentionally held second. Motion-sensitive users rely on reduced-motion handling. At small sizes the thin inner arc is the first detail to weaken. These are review considerations, not reproduced accessibility failures.

## Evidence and detector

Inspected current native/Flutter source, icon_512.png and s13_3_splash_frames_1s.png. The filmstrip was recorded on 2026-10-17 on a Xiaomi 14T Pro, Android 16, isolated release test package. It supports the storyboard and sequential exit; it cannot establish current playback smoothness. Historical 720/380 ms timelines and 272/290 ms first-frame medians are superseded or describe other builds and must not be presented as current visible startup measurements.

The detector returned [] with exit 0 on the animated-vector XML. Native Android animation is outside its applicable coverage, so this is not an animation/accessibility PASS. Browser overlays are not applicable to this native surface. Reduced-motion and final visible startup timing remain device-evidence obligations. No new native run or app tests were performed.

Questions skipped: 2 Priority Issues, both optional refinements; the recommended direction is explicit and no implementation was requested.
