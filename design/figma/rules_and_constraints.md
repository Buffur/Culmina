# Rules and constraints

Revision: AFTER-DARK-1.0. These rules are binding for explicitly requested After artifacts. They do not retroactively modify the production UI. Owner decisions in D01 permit new visual composition and values while preserving product meaning.

## Control semantics

- Button: an action. Filled for the primary local action; outline/quiet for secondary actions. A chevron row navigates or opens a chooser; a switch immediately toggles a persistent binary preference. Do not use a switch for one-time Save.
- Radio/choice selection: mutually exclusive values. Checkbox: independent selection. Tabs: sibling views or root destinations. Preserve Tonight, Logbook, Library, Settings as root destinations; Plan remains above the shell.
- Text input: user-editable content, always with a durable label and validation. A metadata label is not a disabled input. Missing data is readable text, not a greyed-out control.
- Slider: preview a continuous/discrete series only when the source defines that behavior. Hour inspection is a preview, not a plan mutation. Pair with exact timestamp and accessible step actions.
- Destructive action: explicitly named, with current confirmation/Undo behavior. Back and outside dismissal are not implicit confirmation.

## Hierarchy and disclosure

Use a document hierarchy: page identity, direct answer, supporting grouped facts, secondary detail. Use a bounded surface for a coherent record or interactive group; keep ordinary explanatory sections flat. Apply Notion's restrained row rhythm, not its workspace information architecture.

Keep fit verdict, persistence state and capture result separate. The fit answer must retain reason, usable/needed values when known, and relevant remedies. Scientific evidence, timestamps, units and unknown states must not be hidden solely to achieve visual simplicity.

Disclosure summaries remain visible while expanded and describe facts. Preserve stable disclosure keys and current remembered/controlled state semantics. Moving content behind disclosure is allowed only if it remains reachable with an accurate summary and does not hide a required immediate warning, action, missing input or source limitation.

Do not use decorative status chips for everything, replace labeled actions with unexplained icons, convert all records into large cards, invent scores, add unexplained gradients, or import Notion's AI/search bar as Culmina navigation.

## BEFORE protection and parity

The three source nodes listed in [screen contracts](TARGET_DESIGN_SYSTEM.md) are frozen comparison baselines. Do not edit, reparent, rename, resize, relink or delete them. Do not edit a variable, style, component, vector asset or font binding used by BEFORE. Create independent After resources; a duplicated comparison reference must remain clearly labeled as a copy of the immutable source, never a replacement baseline.

Keep exact fixture content, selected night/site/target/rig, known/unknown values and actions during paired comparisons. Do not “fix” stale timestamps or apparent inconsistencies in a frozen fixture. Record them separately. Current source clarifies invisible behavior; visible source-code differences must stay in a discrepancy note.

## Product invariants

- Culmina plans and logs astrophotography; it does not operate cameras or mounts.
- Unknown is not zero. Preserve missing inputs, gaps, units, source, freshness, evidence kind and partial observations.
- FitAnalyzer and CaptureBudgetCalculator own the verdict and atomic timing. Do not calculate a different answer in Figma.
- Relative stacking gain is not absolute SNR. Storage estimates keep their evidence kind. AF/MF and white balance are descriptive; never invent a focus measurement.
- SessionNight is 24 hours from site mean solar noon in UTC. Preserve zone, DST offset, local-date and next-day semantics.
- A placeholder location is not a selected site. Preserve no-site and missing-target/rig/block states.
- Working draft, explicit Save plan, saved lifecycle and recorded results are distinct. Preserve dirty-state guards, cancellation, validation and failure feedback.
- Core saved plans/catalog/calculations/log records remain useful offline. Forecast/maps/place lookup have separate network and consent constraints.
- Preserve cache/freshness/failure and out-of-range weather states. A weather preview must not change the active plan.
- Do not rename package `astroplan`, change schema or dependencies, or infer migration approval from Figma review.

## Change control

A local screen/component deviation is not allowed without updating the owning module, the reference transformation and revision record together. V1/V2 use AFTER-DARK-1.0 unless a named experimental revision states the exact difference. Do not create an untracked per-screen palette, text scale or component fork.

Light and Field Red are deferred. This does not authorize changing or breaking those production themes. Native accessibility and implementation checks occur in a separately authorized migration.
