import 'dart:async';

import 'package:astroplan/domain/models/equipment_profile.dart';
import 'package:astroplan/domain/models/target_alias.dart';
import 'package:astroplan/presentation/viewmodels/library_viewmodels.dart';
import 'package:flutter/foundation.dart';

// Deterministic screen/render fixtures: each read is completed by the test.
class HeldGearReads extends ChangeNotifier implements GearViewModel {
  final reads = <Completer<List<EquipmentProfile>>>[];

  @override
  Future<List<EquipmentProfile>> all() {
    final read = Completer<List<EquipmentProfile>>();
    reads.add(read);
    return read.future;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class HeldAliasReads extends ChangeNotifier implements TargetsViewModel {
  final reads = <Completer<Map<String, List<TargetAlias>>>>[];

  @override
  Future<Map<String, List<TargetAlias>>> aliases() {
    final read = Completer<Map<String, List<TargetAlias>>>();
    reads.add(read);
    return read.future;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
