> **Historical navigation copy — not active instructions.** Link destinations are rebased from `.agents/skills/dart-run-static-analysis/SKILL.md`. Content and acceptance statements retain their original date/scope. [Immutable original](../../../../../snapshots/.agents/skills/dart-run-static-analysis/SKILL.md) · [Navigation index](../../../../../NAVIGATION.md). Original SHA-256: `e7173d0b38b5e9e1c116d78355a27a7ad089860f365b48672105feb2e220c06d`.

---
name: dart-run-static-analysis
description: Run scoped Dart or Flutter static analysis and investigate diagnostics; use automated fixes only when they fit the authorized change.
metadata:
  model: models/gemini-3.1-pro-preview
  last_modified: Fri, 24 Apr 2026 15:09:34 GMT
---
# Analyzing and Fixing Dart Code

## Contents
- [Analysis Configuration](#analysis-configuration)
- [Diagnostic Suppression](#diagnostic-suppression)
- [Workflow: Executing Static Analysis](#workflow-executing-static-analysis)
- [Workflow: Applying Automated Fixes](#workflow-applying-automated-fixes)
- [Examples](#examples)

## Analysis Configuration

Inspect the existing `analysis_options.yaml` when relevant. The options below are examples, not instructions to change the project's configuration or dependencies; configuration changes require an authorized task.

- **Base Configuration:** An `include:` directive can select a standard rule set such as `package:lints/recommended.yaml` or `package:flutter_lints/flutter.yaml`.
- **Strict Type Checks:** Existing `analyzer: language:` options may enable strict casts, inference and raw types.
- **Linter Rules:** Explicitly enable or disable specific rules under the `linter: rules:` node. Use a key-value map (`rule_name: true/false`) when overriding included rules, or a list (`- rule_name`) when defining a fresh set. Do not mix list and map syntax in the same `rules` block.
- **Formatter Configuration:** Configure `dart format` behavior under the `formatter:` node. Set `page_width` (default 80) and `trailing_commas` (`automate` or `preserve`).
- **Analyzer Plugins:** Enable custom diagnostics by adding plugins under the `analyzer: plugins:` node. Ensure the plugin package is added as a `dev_dependency` in `pubspec.yaml`.

## Diagnostic Suppression

Prefer fixing the cause. Consider a narrow suppression only when justified and within the authorized scope; never suppress diagnostics merely to pass a check. These are mechanisms, not a request to add them:

- **File-level Exclusion:** Use the `analyzer: exclude:` node in `analysis_options.yaml` to exclude entire files or directories (e.g., `**/*.g.dart`) using glob patterns.
- **File-level Suppression:** Add `// ignore_for_file: <diagnostic_code>` at the top of a Dart file to suppress specific diagnostics for the entire file. Use `// ignore_for_file: type=lint` to suppress all linter rules.
- **Line-level Suppression:** Add `// ignore: <diagnostic_code>` on the line directly above the offending code, or appended to the end of the offending line.
- **Pubspec Suppression:** Add `# ignore: <diagnostic_code>` above the offending line in `pubspec.yaml` files (e.g., `# ignore: sort_pub_dependencies`).
- **Plugin Diagnostics:** Prefix the diagnostic code with the plugin name when suppressing plugin-specific issues (e.g., `// ignore: some_plugin/some_code`).

## Workflow: Executing Static Analysis

Use this workflow to identify type-related bugs, style violations, and potential runtime errors.

**Task Progress:**
- [ ] 1. Verify `analysis_options.yaml` exists at the project root.
- [ ] 2. Run the analyzer using the `analyze_files` MCP tool (if available) or the CLI command `dart analyze <target_directory>`.
- [ ] 3. Review the diagnostic output.
- [ ] 4. If info-level issues must be treated as failures, append the `--fatal-infos` flag.
- [ ] 5. Resolve reported errors manually or proceed to the Automated Fixes workflow.

## Workflow: Applying Automated Fixes

Automated fixes are optional. Use them only when the task authorizes the affected changes and the proposed scope can be bounded. Avoid a repository-wide apply or format for a localized task.

**Task Progress:**
- [ ] 1. Preview proposed changes with a dry run for the authorized target.
- [ ] 2. Review every proposed fix and its affected paths. If the tool cannot limit the apply to the authorized scope, make selected corrections manually.
- [ ] 3. Apply only appropriate in-scope fixes; do not enable rules or alter configuration solely to generate more fixes.
- [ ] 4. Format only the changed Dart files and run the checks required by the project's verification policy.

## Examples

### Comprehensive `analysis_options.yaml`

```yaml
include: package:flutter_lints/recommended.yaml

analyzer:
  exclude:
    - "**/*.g.dart"
    - "lib/generated/**"
  language:
    strict-casts: true
    strict-inference: true
    strict-raw-types: true
  errors:
    todo: ignore
    invalid_assignment: warning
    missing_return: error

linter:
  rules:
    avoid_shadowing_type_parameters: false
    await_only_futures: true
    use_super_parameters: true

formatter:
  page_width: 100
  trailing_commas: preserve
```

### Inline Diagnostic Suppression

```dart
// Suppress for the entire file
// ignore_for_file: unused_local_variable, dead_code

void processData() {
  // Suppress for a specific line
  // ignore: invalid_assignment
  int x = '';
  
  const y = 10; // ignore: constant_identifier_names
}
```
