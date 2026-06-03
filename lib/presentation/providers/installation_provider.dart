// lib/presentation/providers/installation_provider.dart
//
// INSTALLATION PROVIDER (Riverpod)
// =================================
// Manages installation data for a project. Handles:
// - Adding/editing installation items
// - Tracking status (pending → in-progress → complete → flagged)
// - Punch list management
// - Grouping by area/location
// - Progress tracking per area and overall

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/local/database.dart';
import '../../../data/models/installation.dart';
import '../../../services/sync_service.dart';

/// Installation list state
class InstallationListState {
  final List<Installation> installations;
  final bool isLoading;
  final String? error;

  const InstallationListState({
    this.installations = const [],
    this.isLoading = false,
    this.error,
  });

  InstallationListState copyWith({
    List<Installation>? installations,
    bool? isLoading,
    String? error,
  }) {
    return InstallationListState(
      installations: installations ?? this.installations,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  // ── Computed statistics ──

  int get totalItems => installations.length;
  int get completed =>
      installations.where((i) => i.status == InstallationStatus.complete).length;
  int get inProgress =>
      installations.where((i) => i.status == InstallationStatus.inProgress).length;
  int get flagged =>
      installations.where((i) => i.status == InstallationStatus.flagged).length;
  int get pending =>
      installations.where((i) => i.status == InstallationStatus.pending).length;
  int get needsReinspection =>
      installations.where((i) => i.status == InstallationStatus.needsReinspection).length;

  double get progressPercent =>
      totalItems == 0 ? 0 : (completed / totalItems) * 100;

  /// Punch list items (flagged + needs re-inspection)
  List<Installation> get punchList => installations
      .where((i) =>
          i.status == InstallationStatus.flagged ||
          i.status == InstallationStatus.needsReinspection)
      .toList();

  /// Group by area/location
  Map<String, List<Installation>> get byArea {
    final map = <String, List<Installation>>{};
    for (final item in installations) {
      final area = item.locationOrArea ?? 'General';
      map.putIfAbsent(area, () => []).add(item);
    }
    return map;
  }

  /// Group by status
  Map<InstallationStatus, List<Installation>> get byStatus {
    final map = <InstallationStatus, List<Installation>>{};
    for (final item in installations) {
      map.putIfAbsent(item.status, () => []).add(item);
    }
    return map;
  }
}

/// Installation list notifier
class InstallationListNotifier extends StateNotifier<InstallationListState> {
  final AppDatabase _db;
  final SyncService _syncService;
  final String _projectId;

  InstallationListNotifier(this._db, this._syncService, this._projectId)
      : super(const InstallationListState()) {
    loadInstallations();
  }

  /// Load all installations for the project
  Future<void> loadInstallations() async {
    state = state.copyWith(isLoading: true);
    try {
      final localItems = await _db.getInstallationsForProject(_projectId);
      final items = localItems.map((i) => _localToDomain(i)).toList();
      state = state.copyWith(installations: items, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Add a new installation item
  Future<void> addInstallation(Installation item) async {
    try {
      await _db.insertInstallation(LocalInstallation(
        id: item.id,
        projectId: item.projectId,
        description: item.description,
        locationOrArea: item.locationOrArea,
        status: item.status,
        installedByUserId: item.installedByUserId,
        notes: item.notes,
        flagReason: item.flagReason,
        photoUrls: item.photoUrls.join(','),
        createdAt: item.createdAt,
        completedAt: item.completedAt,
        updatedAt: item.updatedAt,
        isSynced: false,
      ));

      await loadInstallations();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Update installation status
  Future<void> updateStatus(String itemId, InstallationStatus newStatus) async {
    try {
      final index = state.installations.indexWhere((i) => i.id == itemId);
      if (index == -1) return;

      final item = state.installations[index];
      DateTime? completedAt = item.completedAt;

      if (newStatus == InstallationStatus.complete) {
        completedAt = DateTime.now();
      }

      final updated = item.copyWith(
        status: newStatus,
        completedAt: completedAt,
        updatedAt: DateTime.now(),
      );

      await _db.updateInstallation(LocalInstallation(
        id: updated.id,
        projectId: updated.projectId,
        description: updated.description,
        locationOrArea: updated.locationOrArea,
        status: updated.status,
        installedByUserId: updated.installedByUserId,
        notes: updated.notes,
        flagReason: updated.flagReason,
        photoUrls: updated.photoUrls.join(','),
        createdAt: updated.createdAt,
        completedAt: updated.completedAt,
        updatedAt: updated.updatedAt,
        isSynced: false,
      ));

      final updatedList = [...state.installations];
      updatedList[index] = updated;
      state = state.copyWith(installations: updatedList);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Flag an installation item
  Future<void> flagItem(String itemId, String reason) async {
    await updateStatus(itemId, InstallationStatus.flagged);
    // Also update the flag reason
    final index = state.installations.indexWhere((i) => i.id == itemId);
    if (index != -1) {
      final updated = state.installations[index].copyWith(flagReason: reason);
      final updatedList = [...state.installations];
      updatedList[index] = updated;
      state = state.copyWith(installations: updatedList);
    }
  }

  /// Convert local database model to domain model
  Installation _localToDomain(LocalInstallation i) {
    return Installation(
      id: i.id,
      projectId: i.projectId,
      description: i.description,
      locationOrArea: i.locationOrArea,
      status: i.status,
      installedByUserId: i.installedByUserId,
      notes: i.notes,
      flagReason: i.flagReason,
      photoUrls: i.photoUrls.isNotEmpty ? i.photoUrls.split(',') : [],
      createdAt: i.createdAt,
      completedAt: i.completedAt,
      updatedAt: i.updatedAt,
    );
  }
}

// ──────────────────────────────────────────────
// PROVIDERS
// ──────────────────────────────────────────────

/// Installation list provider for a specific project
final installationListProvider = StateNotifierProvider.family<
    InstallationListNotifier,
    InstallationListState,
    String>((ref, projectId) {
  final db = ref.watch(databaseProvider);
  final sync = ref.watch(syncServiceProvider);
  return InstallationListNotifier(db, sync, projectId);
});

/// Punch list provider (just the flagged items)
final punchListProvider = Provider.family<List<Installation>, String>((ref, projectId) {
  final state = ref.watch(installationListProvider(projectId));
  return state.punchList;
});

/// Installation progress provider
final installationProgressProvider = Provider.family<double, String>((ref, projectId) {
  final state = ref.watch(installationListProvider(projectId));
  return state.progressPercent;
});
