# Accepted Culmina Graphite concept

Created and accepted in the design conversation on 2026-10-19. This package accompanies
[the implementation handoff](../../GRAPHITE_UI_IMPLEMENTATION_PLAN.md).

## Files

- `concept.html`: original editable fragment, created with the visualize workflow.
- `preview.html`: standalone browser wrapper for inspecting the concept. Open locally;
  no publication is needed. Some icons/host helper assets may need network access.
- `plan-dark.png`, `home-dark.png`, `night-dark.png`, `plan-light.png`: static fallback
  references, captured from the final concept in a local headless browser.

The preview starts on Plan in Graphite dark appearance. The outer Home/Plan/Night
tabs navigate example screens; the in-app sun/moon icon switches the preview's
light/dark appearance. Night means the Night & Moon content screen, not a theme.
Exposure/count fields, disclosures, local Save feedback and the time slider work.

These are **concept references, not screenshots of the shipped Flutter app**.
Dates, intervals, 32 MB/frame and 8% overhead are illustrative. The preview only
shows one Light block. Production must keep its existing domain and workflow
contracts, application language, features and accessibility requirements.

Earlier rounded-card concepts and the bright-red demonstration were rejected.
They are intentionally not included. The red field mode already in Culmina was
not removed or redesigned by this concept approval.

The implementing agent must produce new actual-widget render evidence in a
separate directory and must not overwrite this approved reference package.
