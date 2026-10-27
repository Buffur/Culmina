---
name: flutter-build-responsive-layout
description: Implement an explicitly scoped adaptive Flutter layout using available local/window constraints. Do not invoke sidebar, grid, orientation or navigation changes to repair an ordinary phone overflow.
metadata:
  model: models/gemini-3.1-pro-preview
  last_modified: Tue, 21 Apr 2026 20:17:40 GMT
---

# Implementing adaptive layouts

Local Culmina amendment, 2026-10-24; upstream frontmatter metadata is retained. Use when the owner task actually calls for adapting composition across named available sizes/form factors. For a local phone overflow, start with [layout diagnosis](../flutter-fix-layout-issues/SKILL.md), not this adaptive recipe. [AGENTS](../../../AGENTS.md) supplies shared source routes and checks; the user task defines scope.

## Space measurement guidelines

Read the affected screen contract, constraints and current caller. LayoutBuilder exposes the parent's BoxConstraints for this part of the tree; MediaQuery.sizeOf exposes the app window's logical size. Use the measure that owns the decision. Check whether maxWidth/maxHeight are finite before relying on them. Prefer aspect-specific MediaQuery accessors; hardware labels or portrait/landscape alone do not establish available content space.

Official guidance and source links: [dated Flutter layout sources](../references/flutter-layout-preview-sources-2026-10-24.md). Culmina source authority remains the affected widgets, `lib/core/theme/` definitions and the user task.

## Workflow: constructing an adaptive layout

1. Name the authorized size range and the required behavior transition; preserve existing navigation, state, content order, actions and scrolling unless a specific change is included.
2. Measure the relevant constraints at that boundary. Choose widths/breakpoints from content needs and the accepted task/reference, not a copied device category.
3. Select the least composition change that fulfils the requested design: wrapping/reflow or constrained content may be sufficient. Use Expanded/Flexible only with a valid flex ancestor and appropriate finite main-axis space.
4. Sidebar, grid or additional columns apply only when the approved adaptive task calls for them. A longer list does not automatically become a grid; preserve reading order, semantics, focus and item meaning. Lazy builders suit long/dynamic collections, not a reason to restructure a short form.
5. Verify the authorized ranges, transition boundaries, text scaling, keyboard/insets, scrolling and reachable actions under [AGENTS](../../../AGENTS.md). Include other input methods only where the target scope calls for them.

## Examples

A sample breakpoint such as 600 logical px, a sidebar width or a max content width illustrates a technique, not a Culmina product token or acceptance rule. Choose and document an actual boundary only for the approved adaptive task. For example, a bounded form might retain one column with a content maxWidth; a grid requires an explicitly appropriate item/composition contract.

## Device and orientation behaviors

Do not change the application's orientation policy, routing or navigation automatically. Window resizing, split-screen and orientation can expose different constraints; preserve the existing platform policy while fixing the named layout. Investigating Android letterboxing/Display APIs or changing supported devices is separate platform work when explicitly requested.

## Finish

Return the authorized adaptive behavior, measured constraints, source/caller, justified breakpoints and checks/limits. For Review, report findings without implementation. Keep SDK/dependency upgrades and preview infrastructure outside a focused layout change unless the task includes them.
