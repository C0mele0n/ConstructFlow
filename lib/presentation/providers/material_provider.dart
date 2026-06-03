// lib/presentation/providers/material_provider.dart
//
// MATERIAL PROVIDER (Riverpod)
// ============================
// Manages material data for a project. Handles:
// - Auto-generating material list from measurements
// - Tracking material status (needed → ordered → picked up → delivered → on-site)
// - Computing cost totals
// - Grouping by status and category

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/local/database.dart';
import '../../../data/models/material.dart';
import '../../../data/models/measurement.dart';
import '../../../services/sync_service.dart';

/// Material list state
class MaterialListState {
  final List<Material> materials;
  final bool isLoading;
  final String? error;

  const MaterialListState({
    this.materials = const [],
    this.isLoading = false,
    this.error,
  });

  MaterialListState copyWith({
    List<Material>? materials,
    bool? isLoading,
    String? error,
  }) {
    return MaterialListState(
      materials: materials ?? this.materials,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  // ── Computed statistics ──

  int get totalItems => materials.length;
  int get neededCount =>
      materials.where((m) => m.status == MaterialStatus.needed).length;
  int get onSiteCount =>
      materials.where((m) => m.status == MaterialStatus.onSite).length;

  /// Total cost of all materials (only items with known costs)
  double get totalCost {
    double total = 0;
    for (final m in materials) {
      if (m.totalCost != null) total += m.totalCost!;
    }
    return total;
  }

  /// Total cost of materials on-site
  double get onSiteCost {
    double total = 0;
    for (final m in materials) {
      if (m.status == MaterialStatus.onSite && m.totalCost != null) {
        total += m.totalCost!;
      }
    }
    return total;
  }

  /// Materials grouped by status
  Map<MaterialStatus, List<Material>> get byStatus {
    final map = <MaterialStatus, List<Material>>{};
    for (final m in materials) {
      map.putIfAbsent(m.status, () => []).add(m);
    }
    return map;
  }

  /// Materials grouped by category
  Map<String, List<Material>> get byCategory {
    final map = <String, List<Material>>{};
    for (final m in materials) {
      final cat = m.typeCategory ?? 'Other';
      map.putIfAbsent(cat, () => []).add(m);
    }
    return map;
  }
}

/// Material list notifier
class MaterialListNotifier extends StateNotifier<MaterialListState> {
  final AppDatabase _db;
  final SyncService _syncService;
  final String _projectId;

  MaterialListNotifier(this._db, this._syncService, this._projectId)
      : super(const MaterialListState()) {
    loadMaterials();
  }

  /// Load all materials for the project
  Future<void> loadMaterials() async {
    state = state.copyWith(isLoading: true);
    try {
      final localMaterials = await _db.getMaterialsForProject(_projectId);
      final materials = localMaterials.map((m) => _localToDomain(m)).toList();
      state = state.copyWith(materials: materials, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Auto-generate material list from measurements
  /// Groups measurements by material type and creates material entries
  Future<void> generateFromMeasurements(List<Measurement> measurements) async {
    try {
      // Group measurements by material type
      final grouped = <String, List<Measurement>>{};
      for (final m in measurements) {
        grouped.putIfAbsent(m.materialType, () => []).add(m);
      }

      // Create material entries
      for (final entry in grouped.entries) {
        final materialType = entry.key;
        final groupMeasurements = entry.value;

        // Sum up total quantity needed
        int totalQuantity = 0;
        for (final m in groupMeasurements) {
          totalQuantity += m.quantity;
        }

        // Determine category from material type
        final category = _categorizeMaterial(materialType);

        // Determine standard size
        final size = _standardSize(materialType);

        final material = Material(
          id: 'mat_${_projectId}_${materialType.replaceAll(' ', '_')}',
          projectId: _projectId,
          name: materialType,
          typeCategory: category,
          size: size,
          quantityNeeded: totalQuantity,
          quantityOnSite: 0,
          unitCost: null, // User fills this in
          status: MaterialStatus.needed,
          createdAt: DateTime.now(),
        );

        // Save to local database
        await _db.insertMaterial(LocalMaterial(
          id: material.id,
          projectId: material.projectId,
          name: material.name,
          typeCategory: material.typeCategory,
          size: material.size,
          quantityNeeded: material.quantityNeeded,
          quantityOnSite: material.quantityOnSite,
          unitCost: material.unitCost,
          status: material.status,
          handledByUserId: material.handledByUserId,
          supplier: material.supplier,
          notes: material.notes,
          createdAt: material.createdAt,
          updatedAt: material.updatedAt,
          isSynced: false,
        ));
      }

      // Reload
      await loadMaterials();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Update material status
  Future<void> updateStatus(String materialId, MaterialStatus newStatus) async {
    try {
      final matIndex = state.materials.indexWhere((m) => m.id == materialId);
      if (matIndex == -1) return;

      final updated = state.materials[matIndex].copyWith(
        status: newStatus,
        updatedAt: DateTime.now(),
      );

      // Update local database
      await _db.updateMaterial(LocalMaterial(
        id: updated.id,
        projectId: updated.projectId,
        name: updated.name,
        typeCategory: updated.typeCategory,
        size: updated.size,
        quantityNeeded: updated.quantityNeeded,
        quantityOnSite: updated.quantityOnSite,
        unitCost: updated.unitCost,
        status: updated.status,
        handledByUserId: updated.handledByUserId,
        supplier: updated.supplier,
        notes: updated.notes,
        createdAt: updated.createdAt,
        updatedAt: updated.updatedAt,
        isSynced: false,
      ));

      // Update state
      final updatedMaterials = [...state.materials];
      updatedMaterials[matIndex] = updated;
      state = state.copyWith(materials: updatedMaterials);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Update material details (cost, supplier, notes)
  Future<void> updateMaterial(Material updated) async {
    try {
      await _db.updateMaterial(LocalMaterial(
        id: updated.id,
        projectId: updated.projectId,
        name: updated.name,
        typeCategory: updated.typeCategory,
        size: updated.size,
        quantityNeeded: updated.quantityNeeded,
        quantityOnSite: updated.quantityOnSite,
        unitCost: updated.unitCost,
        status: updated.status,
        handledByUserId: updated.handledByUserId,
        supplier: updated.supplier,
        notes: updated.notes,
        createdAt: updated.createdAt,
        updatedAt: DateTime.now(),
        isSynced: false,
      ));

      await loadMaterials();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Categorize a material type string
  String _categorizeMaterial(String materialType) {
    final lower = materialType.toLowerCase();
    if (lower.contains('plywood') || lower.contains('osb') || lower.contains('mdf')) {
      return 'Sheet Goods';
    }
    if (lower.contains('2x') || lower.contains('4x') || lower.contains('1x') ||
        lower.contains('lumber') || lower.contains('stud') || lower.contains('joist')) {
      return 'Lumber';
    }
    if (lower.contains('drywall') || lower.contains('sheetrock')) {
      return 'Drywall';
    }
    if (lower.contains('tile')) return 'Tile';
    if (lower.contains('trim') || lower.contains('casing') || lower.contains('baseboard')) {
      return 'Trim';
    }
    if (lower.contains('fastener') || lower.contains('screw') || lower.contains('nail')) {
      return 'Fasteners';
    }
    if (lower.contains('insulation')) return 'Insulation';
    if (lower.contains('concrete') || lower.contains('cement')) return 'Concrete';
    return 'Other';
  }

  /// Get standard size for a material type
  String? _standardSize(String materialType) {
    final lower = materialType.toLowerCase();
    if (lower.contains('4x8') || lower.contains('4\'x8\'')) return '4×8';
    if (lower.contains('4x10') || lower.contains('4\'x10\'')) return '4×10';
    if (lower.contains('4x12') || lower.contains('4\'x12\'')) return '4×12';
    if (lower.contains('8ft') || lower.contains('8\'')) return '8ft';
    if (lower.contains('10ft') || lower.contains('10\'')) return '10ft';
    if (lower.contains('12ft') || lower.contains('12\'')) return '12ft';
    if (lower.contains('16ft') || lower.contains('16\'')) return '16ft';
    return null;
  }

  /// Convert local database model to domain model
  Material _localToDomain(LocalMaterial m) {
    return Material(
      id: m.id,
      projectId: m.projectId,
      name: m.name,
      typeCategory: m.typeCategory,
      size: m.size,
      quantityNeeded: m.quantityNeeded,
      quantityOnSite: m.quantityOnSite,
      unitCost: m.unitCost,
      status: m.status,
      handledByUserId: m.handledByUserId,
      supplier: m.supplier,
      notes: m.notes,
      createdAt: m.createdAt,
      updatedAt: m.updatedAt,
    );
  }
}

// ──────────────────────────────────────────────
// PROVIDERS
// ──────────────────────────────────────────────

/// Material list provider for a specific project
final materialListProvider =
    StateNotifierProvider.family<MaterialListNotifier, MaterialListState, String>(
  (ref, projectId) {
    final db = ref.watch(databaseProvider);
    final sync = ref.watch(syncServiceProvider);
    return MaterialListNotifier(db, sync, projectId);
  },
);

/// Total material cost provider
final materialTotalCostProvider = Provider.family<double, String>((ref, projectId) {
  final state = ref.watch(materialListProvider(projectId));
  return state.totalCost;
});
