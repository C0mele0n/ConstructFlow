// lib/data/models/material.dart
//
// MATERIAL MODEL
// ==============
// Represents a material needed for the project. Auto-generated from measurements.
// The Material Handler tracks what's picked up, delivered, and on-site.

enum MaterialStatus {
  needed,      // Identified but not yet picked up
  ordered,     // Ordered from supplier
  pickedUp,    // Purchased / picked up
  delivered,   // Brought to job site
  onSite,      // At the job site, ready to use
}

extension MaterialStatusDisplay on MaterialStatus {
  String get displayName {
    switch (this) {
      case MaterialStatus.needed:
        return 'Needed';
      case MaterialStatus.ordered:
        return 'Ordered';
      case MaterialStatus.pickedUp:
        return 'Picked Up';
      case MaterialStatus.delivered:
        return 'Delivered';
      case MaterialStatus.onSite:
        return 'On Site';
    }
  }
}

class Material {
  final String id;
  final String projectId;
  final String name;                // e.g., "3/4 Baltic Birch Plywood"
  final String? typeCategory;       // e.g., "Plywood", "Lumber", "Fasteners"
  final String? size;               // e.g., "4x8", "8ft", "10mm"
  final int quantityNeeded;
  final int quantityOnSite;         // How much is currently on-site
  final double? unitCost;           // Price per unit (e.g., per sheet, per board)
  final MaterialStatus status;
  final String? handledByUserId;    // Material Handler
  final String? supplier;           // Where to buy it
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Material({
    required this.id,
    required this.projectId,
    required this.name,
    this.typeCategory,
    this.size,
    required this.quantityNeeded,
    this.quantityOnSite = 0,
    this.unitCost,
    this.status = MaterialStatus.needed,
    this.handledByUserId,
    this.supplier,
    this.notes,
    required this.createdAt,
    this.updatedAt,
  });

  /// Computed: total cost (quantityNeeded × unitCost)
  double? get totalCost {
    if (unitCost == null) return null;
    return quantityNeeded * unitCost!;
  }

  /// Computed: how much more is needed on-site
  int get quantityRemaining => quantityNeeded - quantityOnSite;

  /// Computed: is the full quantity on-site?
  bool get isFullyStocked => quantityOnSite >= quantityNeeded;

  Material copyWith({
    String? id,
    String? projectId,
    String? name,
    String? typeCategory,
    String? size,
    int? quantityNeeded,
    int? quantityOnSite,
    double? unitCost,
    MaterialStatus? status,
    String? handledByUserId,
    String? supplier,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Material(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      name: name ?? this.name,
      typeCategory: typeCategory ?? this.typeCategory,
      size: size ?? this.size,
      quantityNeeded: quantityNeeded ?? this.quantityNeeded,
      quantityOnSite: quantityOnSite ?? this.quantityOnSite,
      unitCost: unitCost ?? this.unitCost,
      status: status ?? this.status,
      handledByUserId: handledByUserId ?? this.handledByUserId,
      supplier: supplier ?? this.supplier,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() =>
      'Material($name: $quantityOnSite/$quantityNeeded — $status)';
}
