// lib/data/models/cost.dart
//
// COST MODEL
// ==========
// Tracks every cost on a project. Materials, labor, and other expenses.
// The Money Handler uses this to track the running total and generate invoices.

enum CostType {
  material,
  labor,
  equipment,
  subcontractor,
  permit,
  other,
}

extension CostTypeDisplay on CostType {
  String get displayName {
    switch (this) {
      case CostType.material:
        return 'Material';
      case CostType.labor:
        return 'Labor';
      case CostType.equipment:
        return 'Equipment';
      case CostType.subcontractor:
        return 'Subcontractor';
      case CostType.permit:
        return 'Permit';
      case CostType.other:
        return 'Other';
    }
  }
}

class Cost {
  final String id;
  final String projectId;
  final CostType type;
  final String description;       // e.g., "3/4 Plywood — 12 sheets"
  final double amount;            // Dollar amount
  final String addedByUserId;     // Who added this cost
  final String? receiptUrl;       // Photo of receipt
  final DateTime createdAt;

  const Cost({
    required this.id,
    required this.projectId,
    required this.type,
    required this.description,
    required this.amount,
    required this.addedByUserId,
    this.receiptUrl,
    required this.createdAt,
  });

  Cost copyWith({
    String? id,
    String? projectId,
    CostType? type,
    String? description,
    double? amount,
    String? addedByUserId,
    String? receiptUrl,
    DateTime? createdAt,
  }) {
    return Cost(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      type: type ?? this.type,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      addedByUserId: addedByUserId ?? this.addedByUserId,
      receiptUrl: receiptUrl ?? this.receiptUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() => 'Cost($type: \$${amount.toStringAsFixed(2)} — $description)';
}
