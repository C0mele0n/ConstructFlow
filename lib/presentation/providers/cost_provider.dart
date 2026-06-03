// lib/presentation/providers/cost_provider.dart
//
// COST PROVIDER (Riverpod)
// ========================
// Manages cost data for a project. Handles:
// - Adding/editing/deleting costs
// - Computing totals by type and overall
// - Real-time cost tracking
// - Budget vs. actual comparison (v1.1)

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/local/database.dart';
import '../../../data/models/cost.dart';
import '../../../services/sync_service.dart';

/// Cost list state
class CostListState {
  final List<Cost> costs;
  final bool isLoading;
  final String? error;

  const CostListState({
    this.costs = const [],
    this.isLoading = false,
    this.error,
  });

  CostListState copyWith({
    List<Cost>? costs,
    bool? isLoading,
    String? error,
  }) {
    return CostListState(
      costs: costs ?? this.costs,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  // ── Computed statistics ──

  double get totalAmount => costs.fold(0, (sum, c) => sum + c.amount);

  double get materialTotal => _totalForType(CostType.material);
  double get laborTotal => _totalForType(CostType.labor);
  double get equipmentTotal => _totalForType(CostType.equipment);
  double get subcontractorTotal => _totalForType(CostType.subcontractor);
  double get permitTotal => _totalForType(CostType.permit);
  double get otherTotal => _totalForType(CostType.other);

  double _totalForType(CostType type) {
    return costs
        .where((c) => c.type == type)
        .fold(0, (sum, c) => sum + c.amount);
  }

  /// Costs grouped by type
  Map<CostType, List<Cost>> get byType {
    final map = <CostType, List<Cost>>{};
    for (final cost in costs) {
      map.putIfAbsent(cost.type, () => []).add(cost);
    }
    return map;
  }

  /// Costs sorted by date (newest first)
  List<Cost> get sortedByDate {
    final sorted = [...costs];
    sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted;
  }

  /// Costs for a specific date range
  List<Cost> costsInRange(DateTime start, DateTime end) {
    return costs
        .where((c) =>
            c.createdAt.isAfter(start) && c.createdAt.isBefore(end))
        .toList();
  }
}

/// Cost list notifier
class CostListNotifier extends StateNotifier<CostListState> {
  final AppDatabase _db;
  final SyncService _syncService;
  final String _projectId;

  CostListNotifier(this._db, this._syncService, this._projectId)
      : super(const CostListState()) {
    loadCosts();
  }

  /// Load all costs for the project
  Future<void> loadCosts() async {
    state = state.copyWith(isLoading: true);
    try {
      final localCosts = await _db.getCostsForProject(_projectId);
      final costs = localCosts.map((c) => _localToDomain(c)).toList();
      costs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      state = state.copyWith(costs: costs, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Add a new cost
  Future<void> addCost(Cost cost) async {
    try {
      await _db.insertCost(LocalCost(
        id: cost.id,
        projectId: cost.projectId,
        type: cost.type,
        description: cost.description,
        amount: cost.amount,
        addedByUserId: cost.addedByUserId,
        receiptUrl: cost.receiptUrl,
        createdAt: cost.createdAt,
        isSynced: false,
      ));

      // Try to sync if online
      if (await _syncService.isOnline) {
        // TODO: Sync to Firestore
      }

      await loadCosts();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Update a cost
  Future<void> updateCost(Cost updated) async {
    try {
      await _db.updateCost(LocalCost(
        id: updated.id,
        projectId: updated.projectId,
        type: updated.type,
        description: updated.description,
        amount: updated.amount,
        addedByUserId: updated.addedByUserId,
        receiptUrl: updated.receiptUrl,
        createdAt: updated.createdAt,
        isSynced: false,
      ));

      await loadCosts();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Delete a cost
  Future<void> deleteCost(String costId) async {
    try {
      await _db.deleteCost(costId);
      await loadCosts();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Convert local database model to domain model
  Cost _localToDomain(LocalCost c) {
    return Cost(
      id: c.id,
      projectId: c.projectId,
      type: c.type,
      description: c.description,
      amount: c.amount,
      addedByUserId: c.addedByUserId,
      receiptUrl: c.receiptUrl,
      createdAt: c.createdAt,
    );
  }
}

// ──────────────────────────────────────────────
// PROVIDERS
// ──────────────────────────────────────────────

/// Cost list provider for a specific project
final costListProvider =
    StateNotifierProvider.family<CostListNotifier, CostListState, String>(
  (ref, projectId) {
    final db = ref.watch(databaseProvider);
    final sync = ref.watch(syncServiceProvider);
    return CostListNotifier(db, sync, projectId);
  },
);

/// Total cost provider (just the number)
final totalCostProvider = Provider.family<double, String>((ref, projectId) {
  final state = ref.watch(costListProvider(projectId));
  return state.totalAmount;
});

/// Cost breakdown by type provider
final costBreakdownProvider =
    Provider.family<Map<CostType, double>, String>((ref, projectId) {
  final state = ref.watch(costListProvider(projectId));
  return {
    CostType.material: state.materialTotal,
    CostType.labor: state.laborTotal,
    CostType.equipment: state.equipmentTotal,
    CostType.subcontractor: state.subcontractorTotal,
    CostType.permit: state.permitTotal,
    CostType.other: state.otherTotal,
  };
});
