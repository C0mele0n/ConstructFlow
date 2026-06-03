// lib/presentation/providers/measurement_provider.dart
//
// MEASUREMENT PROVIDER (Riverpod)
// ===============================
// Manages measurement data for a project.
// Handles loading, creating, and parsing voice input.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/local/database.dart';
import '../../../data/models/measurement.dart';
import '../../../services/sync_service.dart';

/// Measurements state for a project
class MeasurementListState {
  final List<Measurement> measurements;
  final bool isLoading;
  final String? error;

  const MeasurementListState({
    this.measurements = const [],
    this.isLoading = false,
    this.error,
  });

  MeasurementListState copyWith({
    List<Measurement>? measurements,
    bool? isLoading,
    String? error,
  }) {
    return MeasurementListState(
      measurements: measurements ?? this.measurements,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  /// Total count of all measurements
  int get totalCount => measurements.length;

  /// Total quantity across all measurements
  int get totalQuantity => measurements.fold(0, (sum, m) => sum + m.quantity);

  /// Measurements grouped by material type
  Map<String, List<Measurement>> get byMaterial {
    final map = <String, List<Measurement>>{};
    for (final m in measurements) {
      map.putIfAbsent(m.materialType, () => []).add(m);
    }
    return map;
  }

  /// Measurements grouped by priority
  Map<Priority, List<Measurement>> get byPriority {
    final map = <Priority, List<Measurement>>{};
    for (final m in measurements) {
      map.putIfAbsent(m.priority, () => []).add(m);
    }
    return map;
  }
}

/// Measurements notifier
class MeasurementListNotifier extends StateNotifier<MeasurementListState> {
  final AppDatabase _db;
  final SyncService _syncService;
  final String _projectId;

  MeasurementListNotifier(this._db, this._syncService, this._projectId)
      : super(const MeasurementListState()) {
    loadMeasurements();
  }

  /// Load all measurements for the project from local database
  Future<void> loadMeasurements() async {
    state = state.copyWith(isLoading: true);
    try {
      final localMeasurements = await _db.getMeasurementsForProject(_projectId);
      final measurements = localMeasurements.map((m) => _localToDomain(m)).toList();
      state = state.copyWith(measurements: measurements, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Add a new measurement
  Future<void> addMeasurement(Measurement measurement) async {
    try {
      // Save to local database
      await _db.insertMeasurement(LocalMeasurement(
        id: measurement.id,
        projectId: measurement.projectId,
        measuredByUserId: measurement.measuredByUserId,
        length: measurement.dimensions.length,
        width: measurement.dimensions.width,
        height: measurement.dimensions.height,
        unit: measurement.dimensions.unit,
        materialType: measurement.materialType,
        quantity: measurement.quantity,
        priority: measurement.priority,
        notes: measurement.notes,
        photoUrls: measurement.photoUrls.join(','),
        createdAt: measurement.createdAt,
        isSynced: false,
      ));

      // Try to sync to Firestore if online
      if (await _syncService.isOnline) {
        // TODO: Sync to Firestore
      }

      // Reload
      await loadMeasurements();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Delete a measurement
  Future<void> deleteMeasurement(String id) async {
    try {
      await _db.deleteMeasurement(id);
      await loadMeasurements();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Convert local database model to domain model
  Measurement _localToDomain(LocalMeasurement m) {
    return Measurement(
      id: m.id,
      projectId: m.projectId,
      measuredByUserId: m.measuredByUserId,
      dimensions: Dimensions(
        length: m.length,
        width: m.width,
        height: m.height,
        unit: m.unit,
      ),
      materialType: m.materialType,
      quantity: m.quantity,
      priority: m.priority,
      notes: m.notes,
      photoUrls: m.photoUrls.isNotEmpty ? m.photoUrls.split(',') : [],
      createdAt: m.createdAt,
    );
  }
}

// ──────────────────────────────────────────────
// PROVIDERS
// ──────────────────────────────────────────────

/// Measurements provider for a specific project
/// Using .family() because we need a different provider per project
final measurementListProvider = StateNotifierProvider.family<
    MeasurementListNotifier,
    MeasurementListState,
    String>((ref, projectId) {
  final db = ref.watch(databaseProvider);
  final sync = ref.watch(syncServiceProvider);
  return MeasurementListNotifier(db, sync, projectId);
});
