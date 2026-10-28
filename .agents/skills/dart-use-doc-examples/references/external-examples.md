# External Dartdoc examples

Read when the task needs external-file injection or region filtering. These examples retain techniques from the imported recipe; they are illustrative, version-dependent supporting details, not compiled Culmina fixtures or proof of support in the installed Dartdoc. Verify the relevant syntax and semantics through AGENTS' current-documentation route before use.

## File injection

The imported recipe illustrates this directive form:

```text
{@example <path>[#<region>] [lang=LANGUAGE] [indent=keep|strip]}
```

For example, a doc comment can refer to a local example when supported:

```dart
/// Sends a request to the service.
///
/// {@example /example/client_request.dart}
```

Use an external file when reuse, executable validation or a longer sample justifies it. An ordinary inline fenced sample can remain inline.

## Regions and hidden setup

The imported recipe uses region comments to select part of an example:

```dart
void main() {
  // #region request_snippet
  final client = Client();
  client.send();
  // #endregion request_snippet
}
```

```dart
/// Sends a request to the service.
///
/// {@example /example/client.dart#request_snippet}
```

`Client` is illustrative; use the actual API and setup in the affected project. The imported hiding example is:

```dart
final mockServer = startServer(); // #hide
final data = await fetch(mockServer.url);
```

Before using markers, confirm whether the installed renderer requires a region suffix for filtering, how it strips marker lines, and whether the behavior applies to the chosen file format. Inspect generated output so hidden setup and marker comments do not accidentally appear in the published sample.

## Path and output checks

The imported recipe distinguishes a package-root path such as `/example/client.dart` from a source-relative path such as `../utils/demo.dart`. It also describes URI-style forward slashes, encoded spaces, local-file restrictions and package-boundary handling. Treat these as behaviors to verify for the installed tool, particularly when moving a source file or using `..`, spaces or a non-Dart sample.

Confirm that the local file and selected region exist, analyze executable example code in its real package, and render the affected documentation when expansion matters. Check warnings and the visible snippet. A successful analyzer run does not prove directive or marker rendering, and this reference does not authorize a new example package or dependency.
