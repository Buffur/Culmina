---
name: dart-use-doc-examples
description: "How to inject external code examples into Dartdoc using the {@example} directive, and how to filter those files using #hide, #region, and #endregion tags."
---

# Culmina Dartdoc examples

Use for a named external-example task in Dart API documentation. Follow [AGENTS](../../../AGENTS.md), inspect the affected declaration and existing examples, and establish which Dartdoc version will render them.

- Choose an inline sample or an external file according to the requested documentation and reuse needs. A multiline sample alone does not require new example files or scaffolding.
- Reuse an appropriate existing local example. Keep illustrative classes, paths and dependencies separate from Culmina production fixtures; do not migrate unrelated comments or install packages to satisfy a template.
- When external injection or marker filtering is needed, read [directive and region examples](references/external-examples.md). These retained syntax examples are version-dependent supporting material; confirm the relevant behavior through the Context7 route in AGENTS before relying on an unfamiliar directive, option or path rule.
- Check the actual referenced path and region. Analyze changed executable examples using the existing project setup. If directive expansion is part of acceptance, render the affected documentation and inspect its output and warnings; analysis alone does not establish expansion.

Report the affected source/example, relevant tool version, checks performed and any rendering limits. A Markdown-only recipe change needs structural validation, not an application run.
