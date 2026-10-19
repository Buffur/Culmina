import '../models/planning_preferences.dart';
import 'storage_failure.dart';

/// Persistence for the user's [PlanningPreferences] (TASK 5.2).
///
/// Every method throws [StorageFailure] when the store cannot be read or
/// written (TASK 15.1).
abstract class PlanningPreferencesRepository {
  /// The saved preferences, or the documented defaults when nothing is saved.
  Future<PlanningPreferences> load();

  /// Stores [preferences] whole.
  Future<void> save(PlanningPreferences preferences);

  /// F21 A5: whether the last [save] did not finish (the store may hold a
  /// mix of two configurations); false once a later save completes.
  Future<bool> lastSaveIncomplete();
}
