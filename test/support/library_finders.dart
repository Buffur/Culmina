// Finders for the Hybrid Library forms (library.js `.block-input`): the
// label sits above its field, outside the TextFormField.
import 'package:astroplan/presentation/screens/library/library_parts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// The text field under the Library form label [label].
Finder fieldLabeled(String label) => find.descendant(
  of: find.ancestor(of: find.text(label), matching: find.byType(LibraryField)),
  matching: find.byType(TextFormField),
);

/// The dropdown under the Library form label [label].
Finder dropdownLabeled<T>(String label) => find.descendant(
  of: find.ancestor(of: find.text(label), matching: find.byType(LibraryField)),
  matching: find.byType(DropdownButtonFormField<T>),
);
