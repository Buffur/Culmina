---
name: dart-write-documentation
description: "Rules and formatting guidelines for writing Dart /// API documentation and doc comments. Use when documenting Dart code, writing doc comments for any Dart declaration (libraries, classes, methods, variables, etc.), or when instructed to follow the Effective Dart documentation guidelines."
---

# Culmina Dart API documentation

Use for documentation of an affected Dart declaration. Follow [AGENTS](../../../AGENTS.md) and inspect the declaration, callers and nearby comments before describing its behavior. Document the requested contract, including relevant Unknown, units, time, failure or persistence meaning; do not infer behavior from a signature alone.

- Match local `///` conventions. Start with a concise summary, then explain non-obvious inputs, results and exceptions in prose. Use a blank `///` line between paragraphs and language-labelled fences for code samples.
- Prefer descriptive property phrases, “Whether” for booleans and third-person verbs for methods where they read naturally. Avoid repeating the name or signature. Public API documentation is the usual target; explain private implementation details when the task or their complexity warrants it.
- Link resolvable Dart identifiers with brackets and use backticks for literals or expressions. Place documentation before annotations; reuse inherited documentation when the contract is unchanged.
- Read [focused comment examples](references/comment-examples.md) only when parameter prose, annotations, constructor links or documentation-only imports need clarification. Tool-sensitive examples are version-dependent; confirm unfamiliar syntax through the Context7 route in AGENTS rather than changing runtime imports for a documentation link.
- Run the checks appropriate to the actual files changed. For Dart comments, inspect relevant analyzer diagnostics; render documentation when its generated output or link resolution is part of the task. Do not expand a comment edit into a documentation rewrite or tooling migration.

Report the documented behavior, affected declarations, checks and unresolved evidence. Markdown-only skill edits require structural checks; they do not require running the app.
