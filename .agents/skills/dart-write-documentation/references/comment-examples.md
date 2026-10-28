# Focused Dart API comment examples

Read only the example relevant to the documentation task. These samples clarify writing choices; placeholder types and bodies are not Culmina fixtures. Constructor and documentation-import syntax retained from the imported recipe is version-dependent: verify unfamiliar features against the installed tools through AGENTS' Context7 route.

## Inputs and exceptions in prose

Explain useful behavior without repeating the signature or using Javadoc-style parameter sections:

```dart
/// Fetches the remote data.
///
/// If [force] is true, this bypasses the local cache and forces a
/// network request.
///
/// Throws a [NetworkException] if the host is unreachable.
Data load(bool force) { /* implementation */ }
```

The actual implementation must establish these cache and exception claims. A template is not evidence that the affected API behaves this way.

## Annotation placement and inherited contracts

When a changed override needs its own explanation, place the comment before metadata:

```dart
/// Renders the widget in the available space.
@override
Widget build(BuildContext context) { /* implementation */ }
```

An unchanged inherited contract may need no duplicated comment. For a getter/setter pair, keep the shared explanation in one appropriate place, following nearby conventions and checking renderer diagnostics.

## Natural openers

```dart
/// Whether the connection is active.
bool get isActive => _active;

/// Initializes the connection.
void init() { /* implementation */ }
```

These are writing patterns, not a reason to rewrite unrelated comments. Explain a subtle private implementation when it helps maintainers understand the requested change.

## Constructor links

The retained unnamed-constructor linking example is:

```dart
/// Creates a user with the same defaults as [User.new].
User.create() { /* implementation */ }
```

Verify both the constructor's actual behavior and link resolution. Do not invent a relationship between constructors merely to use this wording.

## Documentation-only imports

The imported recipe illustrates a documentation import for a symbol outside the library's runtime imports:

```dart
/// @docImport 'package:http/http.dart';
library;

/// Sends the request using the supplied [Client].
```

Confirm support, placement and symbol resolution in the installed Dartdoc/analyzer before adopting this technique. Reuse existing imports when sufficient; a documentation link does not justify adding a runtime dependency. Render the affected documentation when resolving such links is part of acceptance.
