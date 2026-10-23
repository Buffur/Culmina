---
name: flutter-fix-layout-issues
description: Diagnose a specific Flutter overflow, unbounded constraint or ParentData error from its axis, ancestor constraints and scrolling owner. Use for a local layout correction, not an adaptive-navigation redesign.
metadata:
  model: models/gemini-3.1-pro-preview
  last_modified: Tue, 21 Apr 2026 19:45:59 GMT
---

# Resolving Flutter layout errors

Local Culmina amendment, 2026-10-24; upstream frontmatter metadata is retained. Use for a reported layout failure. Do not invoke adaptive layout or preview infrastructure just because an overflow occurs. Follow the task's [work mode](../../../docs/design/WORKFLOW.md#work-modes); Review stays read-only.

## Read and diagnose

Read the relevant Culmina layout/typography contract, affected widget and ancestors. Official sources and the dated SDK check are in [Flutter layout/preview sources](../references/flutter-layout-preview-sources-2026-10-24.md). Refresh technical docs through the AI_WORKFLOW Context7 route when the task needs an API not established there.

Find the first causal exception; later "RenderBox was not laid out" messages may be consequences, but inspect them if no earlier cause is found. From available inspector/runtime data or the source, identify:

1. The failing axis: Row main axis is horizontal, Column main axis is vertical. Record incoming min/max width/height and which ancestor introduces an unbounded maximum.
2. Whether finite space exists on that axis. A bounded screen does not imply every descendant receives bounded constraints: non-flex Column children and a vertical scrollable's content can receive unbounded height.
3. Which widget should own scrolling. Decide whether the whole form/page scrolls, a bounded list fills the remaining viewport, or independently scrolling regions are explicitly required. Do not add a second same-axis scrollable by default.
4. Whether the content needs a bounded flex allocation, wrapping, reflow or a different authorized local composition. Account for text scale, long content, keyboard/insets and reachable actions rather than hiding the symptom.

## Choose the repair from constraints

| Diagnosis | Conditional response |
| --- | --- |
| A vertical list is a non-flex child of a Column with finite height | If that list should own remaining-page scrolling, Expanded can give it the finite remainder; verify that the header/actions leave usable space. |
| Column is inside a vertical SingleChildScrollView/ListView | Its maximum height may be infinite. Expanded requests a tight share of remaining main-axis space; an infinite remainder cannot be allocated that way and produces the non-zero-flex/unbounded-constraint error. Choose one scrolling owner, use content-sized non-flex children, or establish a justified finite viewport outside the scrollable. Merely adding a minimum height does not make the maximum finite. |
| Text or a field lacks finite width in a Row | Under a finite Row width, Expanded/Flexible may allocate a valid width; choose tight versus loose fit deliberately. If content still cannot fit, use wrapping or an authorized stacked arrangement. A field needs a finite width; flex cannot manufacture one from an unbounded Row. |
| RenderFlex overflow with finite constraints | Determine which children consumed the space. Flex can bound a long text child, but multiple controls or vertical content may need Wrap, local reflow or scrolling instead. Preserve text scale, full labels and touch targets. |
| Incorrect use of ParentDataWidget | Inspect the specific widget's ancestor contract and render-object path, not just its source-level indentation. See the rule below. |

Expanded and Flexible are not universal overflow repairs. Loose Flexible can size below its allocation; whether loose flex is valid in an unbounded flex layout also depends on the container's mainAxisSize/fit arrangement. Diagnose that arrangement instead of mechanically replacing Expanded with Flexible. Fixed height, shrinkWrap and clipping have specific contracts/tradeoffs; none is a general cure. Reducing font sizes or the user's text scaler is not an overflow remedy. Use them only for a justified component size/content requirement, not to conceal inaccessible content or an unresolved scrolling problem.

## ParentData and ancestor rule

For Expanded/Flexible, the enclosing layout ancestor is Row, Column or Flex. The intervening widget path may contain StatelessWidget/StatefulWidget wrappers but not intervening RenderObjectWidgets. Positioned has the corresponding Stack ancestor rule. These APIs do not require a literal immediate child in the Dart widget expression. For example, `Row(children: [Expanded(child: Padding(...))])` puts padding inside the flex child; `Row(children: [Padding(child: Expanded(...))])` interposes RenderPadding and violates the contract. A Container must be judged by the widgets it actually builds, not assumed safe because it is a StatelessWidget.

## Examples

- **Bounded viewport:** a screen-height Column with a header and one remaining-height list can use Expanded around the list.
- **Scrollable form:** a vertical SingleChildScrollView containing a content-sized Column should not acquire Expanded merely because a footer overflows. Preserve page scrolling and place actions according to the existing contract.
- **Narrow text row:** a bounded icon/text Row can constrain its text with Expanded while allowing the text to wrap vertically; a multi-action row may instead need Wrap.

## Finish

For an authorized implementation, verify the original failing state and affected widths/scales/insets through [V1–V8](../../../docs/VERIFICATION_POLICY.md); use available runtime inspection/hot reload where the task permits it. No recipe grants a build/device operation. For a documentation-only task, validate the explanation/references and do not run the app. Deliver the causal constraints, chosen scrolling owner, bounded correction or review finding, actual checks and remaining limits.
