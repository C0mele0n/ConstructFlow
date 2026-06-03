// lib/presentation/providers/cut_provider.dart
//
// CUT PROVIDER (Riverpod)
// =======================
// Manages cut list data. Handles:
// - Generating cut lists from measurements
// - Marking cuts complete
// - Flagging cuts with issues
// - Computing cut statistics
//
// CUT LIST GENERATION:
// The cut list is auto-generated from measurements. For example:
// Measurement: "48in × 26in, 3/4 Plywood, qty: 12"
// → Generates 12 cuts of 48" pieces from 4×8 sheets
//
// A real cut optimizer would use bin-packing algorithms to minimize waste.
// For MVP, we generate straightforward cuts and let the Cutter adjust.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/local/database.dart';
import '../../../data/models/cut.dart';
import '../../../data/models/measurement.dart';
import '../../../services/sync_service.dart';
import 'measurement_provider.dart';

/// Cut list state
class CutListState {
  final List<Cut> cuts;
  final bool isLoading;
  final bool isGenerating;
  final String? error;

  const CutListState({
    this.cuts = const [],
    this.isLoading = false,
    this.isGenerating = false,
    this.error,
  });

  CutListState copyWith({
    List<Cut>? cuts,
    bool? isLoading,
    bool? isGenerating,
    String? error,
  }) {
    return CutListState(
      cuts: cuts ?? this.cuts,
      isLoading: isLoading ?? this.isLoading,
      isGenerating: isGenerating ?? this.isGenerating,
      error: error,
    );
  }

  // ── Computed statistics ──

  int get totalCuts => cuts.length;
  int get completedCuts => cuts.where((c) => c.status == CutStatus.complete).length;
  int get flaggedCuts => cuts.where((c) => c.status == CutStatus.flagged).length;
  int get pendingCuts => cuts.where((c) => c.status == CutStatus.pending).length;

  double get progressPercent =>
      totalCuts == 0 ? 0 : (completedCuts / totalCuts) * 100;

  /// Cuts grouped by status
  Map<CutStatus, List<Cut>> get byStatus {
    final map = <CutStatus, List<Cut>>{};
    for (final cut in cuts) {
      map.putIfAbsent(cut.status, () => []).add(cut);
    }
    return map;
  }

  /// Cuts grouped by measurement (source)
  Map<String, List<Cut>> get byMeasurement {
    final map = <String, List<Cut>>{};
    for (final cut in cuts) {
      map.putIfAbsent(cut.measurementId, () => []).add(cut);
    }
    return map;
  }
}

/// Cut list notifier
class CutListNotifier extends StateNotifier<CutListState> {
  final AppDatabase _db;
  final SyncService _syncService;
  final String _projectId;

  CutListNotifier(this._db, this._syncService, this._projectId)
      : super(const CutListState()) {
    loadCuts();
  }

  /// Load all cuts for the project from local database
  Future<void> loadCuts() async {
    state = state.copyWith(isLoading: true);
    try {
      final localCuts = await _db.getCutsForProject(_projectId);
      final cuts = localCuts.map((c) => _localToDomain(c)).toList();
      // Sort: pending first, then in-progress, then flagged, then complete
      cuts.sort((a, b) => a.status.index.compareTo(b.status.index));
      state = state.copyWith(cuts: cuts, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Generate cut list from measurements
  /// For each measurement, creates the appropriate number of cuts
  Future<void> generateFromMeasurements(List<Measurement> measurements) async {
    state = state.copyWith(isGenerating: true);

    try {
      final cuts = <Cut>[];

      for (final measurement in measurements) {
        // For MVP: generate one cut per quantity
        // A real optimizer would do bin-packing here
        for (int i = 0; i < measurement.quantity; i++) {
          final cut = Cut(
            id: '${measurement.id}_cut_$i',
            measurementId: measurement.id,
            projectId: _projectId,
            length: measurement.dimensions.length,
            unit: measurement.dimensions.unit,
            quantity: 1,
            status: CutStatus.pending,
            createdAt: DateTime.now(),
          );
          cuts.add(cut);

          // Save to local database
          await _db.insertCut(LocalCut(
            id: cut.id,
            measurementId: cut.measurementId,
            projectId: cut.projectId,
            length: cut.length,
            unit: cut.unit,
            quantity: cut.quantity,
            status: cut.status,
            cutByUserId: null,
            notes: null,
            flagReason: null,
            createdAt: cut.createdAt,
            completedAt: null,
            isSynced: false,
          ));
        }
      }

      // If online, sync to Firestore
      if (await _syncService.isOnline) {
        // TODO: Batch sync cuts to Firestore
      }

      // Reload
      await loadCuts();
      state = state.copyWith(isGenerating: false);
    } catch (e) {
      state = state.copyWith(isGenerating: false, error: e.toString());
    }
  }

  /// Mark a cut as complete
  Future<void> markComplete(String cutId, String userId) async {
    try {
      final cutIndex = state.cuts.indexWhere((c) => c.id == cutId);
      if (cutIndex == -1) return;

      final updatedCut = state.cuts[cutIndex].copyWith(
        status: CutStatus.complete,
        cutByUserId: userId,
        completedAt: DateTime.now(),
      );

      // Update local database
      await _db.updateCut(LocalCut(
        id: updatedCut.id,
        measurementId: updatedCut.measurementId,
        projectId: updatedCut.projectId,
        length: updatedCut.length,
        unit: updatedCut.unit,
        quantity: updatedCut.quantity,
        status: updatedCut.status,
        cutByUserId: updatedCut.cutByUserId,
        notes: updatedCut.notes,
        flagReason: updatedCut.flagReason,
        createdAt: updatedCut.createdAt,
        completedAt: updatedCut.completedAt,
        isSynced: false,
      ));

      // Update state
      final updatedCuts = [...state.cuts];
      updatedCuts[cutIndex] = updatedCut;
      state = state.copyWith(cuts: updatedCuts);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Flag a cut with an issue
  Future<void> flagCut(String cutId, String reason) async {
    try {
      final cutIndex = state.cuts.indexWhere((c) => c.id == cutId);
      if (cutIndex == -1) return;

      final updatedCut = state.cuts[cutIndex].copyWith(
        status: CutStatus.flagged,
        flagReason: reason,
      );

      // Update local database
      await _db.updateCut(LocalCut(
        id: updatedCut.id,
        measurementId: updatedCut.measurementId,
        projectId: updatedCut.projectId,
        length: updatedCut.length,
        unit: updatedCut.unit,
        quantity: updatedCut.quantity,
        status: updatedCut.status,
        cutByUserId: updatedCut.cutByUserId,
        notes: updatedCut.notes,
        flagReason: updatedCut.flagReason,
        createdAt: updatedCut.createdAt,
        completedAt: updatedCut.completedAt,
        isSynced: false,
      ));

      // Update state
      final updatedCuts = [...state.cuts];
      updatedCuts[cutIndex] = updatedCut;
      state = state.copyWith(cuts: updatedCuts);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Clear all cuts and regenerate (for re-generating the cut list)
  Future<void> regenerateFromMeasurements(List<Measurement> measurements) async {
    try {
      // Delete existing cuts
      for (final cut in state.cuts) {
        // TODO: Add delete cut to database
      }
      // Generate new cuts
      await generateFromMeasurements(measurements);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Convert local database model to domain model
  Cut _localToDomain(LocalCut c) {
    return Cut(
      id: c.id,
      measurementId: c.measurementId,
      projectId: c.projectId,
      length: c.length,
      unit: c.unit,
      quantity: c.quantity,
      status: c.status,
      cutByUserId: c.cutByUserId,
      notes: c.notes,
      flagReason: c.flagReason,
      createdAt: c.createdAt,
      completedAt: c.completedAt,
    );
  }
}

// ──────────────────────────────────────────────
// PROVIDERS
// ──────────────────────────────────────────────

/// Cut list provider for a specific project
final cutListProvider =
    StateNotifierProvider.family<CutListNotifier, CutListState, String>(
  (ref, projectId) {
    final db = ref.watch(databaseProvider);
    final sync = ref.watch(syncServiceProvider);
    return CutListNotifier(db, sync, projectId);
  },
);

/// Computed progress provider (just the percentage)
final cutProgressProvider = Provider.family<double, String>((ref, projectId) {
  final cutState = ref.watch(cutListProvider(projectId));
  return cutState.progressPercent;
});
