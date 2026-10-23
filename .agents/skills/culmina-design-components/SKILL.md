---
name: culmina-design-components
description: Choose or document existing Culmina components. Read only the relevant group and current DESIGN_SYSTEM subsection, not the whole history; local component/layout fixes do not redesign navigation.
---

# Culmina components

Use for composing or documenting an existing component and its states. Do not load all component groups for a local fix or infer permission to change routing. Select the mode through [WORKFLOW](../../../docs/design/WORKFLOW.md#work-modes).

## Read only the affected group

Read [BASELINE](../../../docs/design/BASELINE.md), use the [section-reading route](../../../docs/design/WORKFLOW.md#read-the-needed-contract), then inspect only the named component subsection of [DESIGN_SYSTEM](../../../docs/DESIGN_SYSTEM.md) and its definition/actual caller. Tonight context starts at [Context line](../../../docs/DESIGN_SYSTEM.md#context-line), not at historical adoption tables.

| Task | Reference | Selection boundary |
| --- | --- | --- |
| Field, action, choice, confirmation or deletion | [Forms](references/forms.md) | Preserve selection semantics, units, dirty drafts and Save/Discard/Cancel |
| Context actions, detail template or existing destination | [Navigation](references/navigation.md) | Distinguish component API from screen adoption; preserve Back/state and no-site semantics |
| Fit/state, disclosure, measurements or science graphics | [Data display](references/data-display.md) | Preserve Unknown, fit versus persistence/result state and source-owned calculations |

<a id="form-elements"></a>
<a id="navigation"></a>
<a id="data-display"></a>

## Compose within the current contract

Inspect the requested variant and its loading, missing-input/no-site, unavailable, saved/changed and error states. Reuse the existing component before adding another abstraction. Read the current screen's conditional child order and actual callbacks; a historical comment/gallery example is not proof of adoption.

For a changed component contract record purpose, anatomy, variants/states, inputs/slots, interactions, accessibility, exclusions and a real adopter/check in the existing reference. The Home composition and product invariants are in BASELINE and the [rules skill](../culmina-design-rules/SKILL.md); do not replace them with an old browser composition. Browser comparison methods are [optional history](../../../docs/design/references/LAB_HISTORY.md#component-browser-comparisons).

<a id="composition-and-documentation"></a>

## Finish

Return the chosen existing component, actual caller/state and bounded diff or review findings, with [V1–V8](../../../docs/VERIFICATION_POLICY.md) evidence and limits. Browser analogues do not prove native routing or accessibility acceptance.
