import 'document_section.dart';

/// Canonical bounded group, sharing DocumentSection's joined-list behavior.
class SectionCard extends DocumentSection {
  const SectionCard({
    super.key,
    required super.children,
    super.padding,
    super.joinPrevious,
    super.joinNext,
  });
}
