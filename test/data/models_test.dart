// test/data/models_test.dart
//
// Unit tests for data models: Measurement, Dimensions, Cut, Cost.

import 'package:flutter_test/flutter_test.dart';
import 'package:constructflow/data/models/measurement.dart';
import 'package:constructflow/data/models/cut.dart';
import 'package:constructflow/data/models/cost.dart';
import 'package:constructflow/data/models/material.dart';
import 'package:constructflow/data/models/installation.dart';
import 'package:constructflow/data/models/project.dart';
import 'package:constructflow/data/models/user.dart';

void main() {
  // ─── MeasurementUnit ───────────────────────────────────────

  group('MeasurementUnit', () {
    test('inches symbol is "in"', () {
      expect(MeasurementUnit.inches.symbol, 'in');
    });

    test('feet symbol is "ft"', () {
      expect(MeasurementUnit.feet.symbol, 'ft');
    });

    test('centimeters symbol is "cm"', () {
      expect(MeasurementUnit.centimeters.symbol, 'cm');
    });

    test('meters symbol is "m"', () {
      expect(MeasurementUnit.meters.symbol, 'm');
    });

    test('display names are correct', () {
      expect(MeasurementUnit.inches.displayName, 'Inches');
      expect(MeasurementUnit.feet.displayName, 'Feet');
      expect(MeasurementUnit.centimeters.displayName, 'Centimeters');
      expect(MeasurementUnit.meters.displayName, 'Meters');
    });
  });

  // ─── Priority ──────────────────────────────────────────────

  group('Priority', () {
    test('display names are correct', () {
      expect(Priority.low.displayName, 'Low');
      expect(Priority.medium.displayName, 'Medium');
      expect(Priority.high.displayName, 'High');
      expect(Priority.critical.displayName, 'Critical');
    });
  });

  // ─── Dimensions ────────────────────────────────────────────

  group('Dimensions', () {
    test('area is length × width', () {
      const dims = Dimensions(length: 48, width: 24, unit: MeasurementUnit.inches);
      expect(dims.area, 1152);
    });

    test('area is null when width is null', () {
      const dims = Dimensions(length: 48, unit: MeasurementUnit.inches);
      expect(dims.area, isNull);
    });

    test('displayString for linear measurement', () {
      const dims = Dimensions(length: 48, unit: MeasurementUnit.inches);
      expect(dims.displayString, '48.0 in (linear)');
    });

    test('displayString for 2D measurement', () {
      const dims = Dimensions(length: 48, width: 24, unit: MeasurementUnit.inches);
      expect(dims.displayString, '48.0 × 24.0 in');
    });

    test('displayString for 3D measurement', () {
      const dims = Dimensions(length: 48, width: 24, height: 0.75, unit: MeasurementUnit.inches);
      expect(dims.displayString, '48.0 × 24.0 × 0.75 in');
    });

    test('copyWith updates only specified fields', () {
      const original = Dimensions(length: 48, width: 24, unit: MeasurementUnit.inches);
      final updated = original.copyWith(length: 96);
      expect(updated.length, 96);
      expect(updated.width, 24); // unchanged
      expect(updated.unit, MeasurementUnit.inches); // unchanged
    });

    test('default unit is inches', () {
      const dims = Dimensions(length: 48);
      expect(dims.unit, MeasurementUnit.inches);
    });
  });

  // ─── Measurement ───────────────────────────────────────────

  group('Measurement', () {
    Measurement makeMeasurement({
      String id = 'm1',
      double length = 48,
      double? width = 24,
      String materialType = '3/4 Plywood',
      int quantity = 1,
      Priority priority = Priority.medium,
    }) {
      return Measurement(
        id: id,
        projectId: 'proj_1',
        measuredByUserId: 'user_1',
        dimensions: Dimensions(
          length: length,
          width: width,
          unit: MeasurementUnit.inches,
        ),
        materialType: materialType,
        quantity: quantity,
        priority: priority,
        createdAt: DateTime(2026, 6, 3),
      );
    }

    test('totalArea is area × quantity', () {
      final m = makeMeasurement(length: 48, width: 24, quantity: 3);
      // area = 48 × 24 = 1152, totalArea = 1152 × 3 = 3456
      expect(m.totalArea, 3456);
    });

    test('totalArea is null when width is null', () {
      final m = makeMeasurement(length: 48, width: null);
      expect(m.totalArea, isNull);
    });

    test('default quantity is 1', () {
      final m = makeMeasurement(quantity: 1);
      expect(m.quantity, 1);
    });

    test('default priority is medium', () {
      final m = makeMeasurement();
      expect(m.priority, Priority.medium);
    });

    test('default photoUrls is empty', () {
      final m = makeMeasurement();
      expect(m.photoUrls, isEmpty);
    });

    test('toString includes material and dimensions', () {
      final m = makeMeasurement();
      final str = m.toString();
      expect(str, contains('3/4 Plywood'));
      expect(str, contains('48'));
    });

    test('copyWith preserves unchanged fields', () {
      final original = makeMeasurement();
      final updated = original.copyWith(materialType: '2x4');
      expect(updated.materialType, '2x4');
      expect(original.materialType, '3/4 Plywood'); // original unchanged
      expect(updated.id, original.id);
    });
  });

  // ─── CutStatus ─────────────────────────────────────────────

  group('CutStatus', () {
    test('display names are correct', () {
      expect(CutStatus.pending.displayName, 'Pending');
      expect(CutStatus.inProgress.displayName, 'In Progress');
      expect(CutStatus.complete.displayName, 'Complete');
      expect(CutStatus.flagged.displayName, 'Flagged');
    });
  });

  // ─── Cut ───────────────────────────────────────────────────

  group('Cut', () {
    Cut makeCut({
      String id = 'c1',
      double length = 48,
      MeasurementUnit unit = MeasurementUnit.inches,
      int quantity = 1,
      CutStatus status = CutStatus.pending,
    }) {
      return Cut(
        id: id,
        measurementId: 'm1',
        projectId: 'proj_1',
        length: length,
        unit: unit,
        quantity: quantity,
        status: status,
        createdAt: DateTime(2026, 6, 3),
      );
    }

    test('default unit is inches', () {
      final c = makeCut();
      expect(c.unit, MeasurementUnit.inches);
    });

    test('default quantity is 1', () {
      final c = makeCut();
      expect(c.quantity, 1);
    });

    test('default status is pending', () {
      final c = makeCut();
      expect(c.status, CutStatus.pending);
    });

    test('toString includes length and status', () {
      final c = makeCut(length: 48);
      final str = c.toString();
      expect(str, contains('48'));
      expect(str, contains('pending'));
    });

    test('copyWith updates status', () {
      final original = makeCut();
      final updated = original.copyWith(
        status: CutStatus.complete,
        completedAt: DateTime.now(),
      );
      expect(updated.status, CutStatus.complete);
      expect(updated.completedAt, isNotNull);
      expect(original.status, CutStatus.pending); // original unchanged
    });
  });

  // ─── CostType ──────────────────────────────────────────────

  group('CostType', () {
    test('display names are correct', () {
      expect(CostType.material.displayName, 'Material');
      expect(CostType.labor.displayName, 'Labor');
      expect(CostType.equipment.displayName, 'Equipment');
      expect(CostType.subcontractor.displayName, 'Subcontractor');
      expect(CostType.permit.displayName, 'Permit');
      expect(CostType.other.displayName, 'Other');
    });
  });

  // ─── Cost ──────────────────────────────────────────────────

  group('Cost', () {
    Cost makeCost({
      String id = 'cost_1',
      CostType type = CostType.material,
      String description = '3/4 Plywood — 12 sheets',
      double amount = 450.00,
    }) {
      return Cost(
        id: id,
        projectId: 'proj_1',
        type: type,
        description: description,
        amount: amount,
        addedByUserId: 'user_1',
        createdAt: DateTime(2026, 6, 3),
      );
    }

    test('toString includes type and amount', () {
      final c = makeCost();
      final str = c.toString();
      expect(str, contains('CostType.material'));
      expect(str, contains('450.0'));
    });

    test('copyWith updates amount', () {
      final original = makeCost(amount: 450.00);
      final updated = original.copyWith(amount: 500.00);
      expect(updated.amount, 500.00);
      expect(original.amount, 450.00);
    });

    test('receiptUrl is null by default', () {
      final c = makeCost();
      expect(c.receiptUrl, isNull);
    });
  });

  // ─── Cost Calculation Helpers ──────────────────────────────

  group('Cost calculations', () {
    List<Cost> makeCostList() {
      return [
        Cost(id: 'c1', projectId: 'p1', type: CostType.material, description: 'Plywood', amount: 500, addedByUserId: 'u1', createdAt: DateTime.now()),
        Cost(id: 'c2', projectId: 'p1', type: CostType.material, description: '2x4s', amount: 200, addedByUserId: 'u1', createdAt: DateTime.now()),
        Cost(id: 'c3', projectId: 'p1', type: CostType.labor, description: 'Day 1', amount: 800, addedByUserId: 'u1', createdAt: DateTime.now()),
        Cost(id: 'c4', projectId: 'p1', type: CostType.equipment, description: 'Rental', amount: 150, addedByUserId: 'u1', createdAt: DateTime.now()),
        Cost(id: 'c5', projectId: 'p1', type: CostType.other, description: 'Misc', amount: 50, addedByUserId: 'u1', createdAt: DateTime.now()),
      ];
    }

    test('total cost is sum of all amounts', () {
      final costs = makeCostList();
      final total = costs.fold<double>(0, (sum, c) => sum + c.amount);
      expect(total, 1700);
    });

    test('total by type filters correctly', () {
      final costs = makeCostList();
      final materialCosts = costs.where((c) => c.type == CostType.material);
      final materialTotal = materialCosts.fold<double>(0, (sum, c) => sum + c.amount);
      expect(materialTotal, 700); // 500 + 200
    });

    test('labor total is correct', () {
      final costs = makeCostList();
      final laborCosts = costs.where((c) => c.type == CostType.labor);
      final laborTotal = laborCosts.fold<double>(0, (sum, c) => sum + c.amount);
      expect(laborTotal, 800);
    });

    test('empty cost list has zero total', () {
      final costs = <Cost>[];
      final total = costs.fold<double>(0, (sum, c) => sum + c.amount);
      expect(total, 0);
    });
  });

  // ─── MaterialStatus ────────────────────────────────────────

  group('MaterialStatus', () {
    test('display names are correct', () {
      expect(MaterialStatus.needed.displayName, 'Needed');
      expect(MaterialStatus.ordered.displayName, 'Ordered');
      expect(MaterialStatus.pickedUp.displayName, 'Picked Up');
      expect(MaterialStatus.delivered.displayName, 'Delivered');
      expect(MaterialStatus.onSite.displayName, 'On Site');
    });

    test('status pipeline order is correct', () {
      final statuses = MaterialStatus.values;
      expect(statuses[0], MaterialStatus.needed);
      expect(statuses[1], MaterialStatus.ordered);
      expect(statuses[2], MaterialStatus.pickedUp);
      expect(statuses[3], MaterialStatus.delivered);
      expect(statuses[4], MaterialStatus.onSite);
    });
  });

  // ─── InstallationStatus ────────────────────────────────────

  group('InstallationStatus', () {
    test('display names are correct', () {
      expect(InstallationStatus.pending.displayName, 'Pending');
      expect(InstallationStatus.inProgress.displayName, 'In Progress');
      expect(InstallationStatus.complete.displayName, 'Complete');
      expect(InstallationStatus.flagged.displayName, 'Flagged');
      expect(InstallationStatus.needsReinspection.displayName, 'Needs Re-inspection');
    });
  });

  // ─── ProjectStatus ─────────────────────────────────────────

  group('ProjectStatus', () {
    test('display names are correct', () {
      expect(ProjectStatus.planning.displayName, 'Planning');
      expect(ProjectStatus.active.displayName, 'Active');
      expect(ProjectStatus.onHold.displayName, 'On Hold');
      expect(ProjectStatus.completed.displayName, 'Completed');
    });

    test('has 4 statuses', () {
      expect(ProjectStatus.values.length, 4);
    });
  });

  // ─── ProjectRole ───────────────────────────────────────────

  group('ProjectRole', () {
    test('display names are correct', () {
      expect(ProjectRole.measurer.displayName, 'Measurer');
      expect(ProjectRole.materialHandler.displayName, 'Material Handler');
      expect(ProjectRole.cutter.displayName, 'Cutter');
      expect(ProjectRole.installerAssembler.displayName, 'Installer/Assembler');
      expect(ProjectRole.moneyHandler.displayName, 'Money Handler');
      expect(ProjectRole.projectLeader.displayName, 'Project Leader');
    });

    test('short names are correct', () {
      expect(ProjectRole.measurer.shortName, 'Measure');
      expect(ProjectRole.materialHandler.shortName, 'Material');
      expect(ProjectRole.cutter.shortName, 'Cut');
      expect(ProjectRole.installerAssembler.shortName, 'Install');
      expect(ProjectRole.moneyHandler.shortName, 'Money');
      expect(ProjectRole.projectLeader.shortName, 'Lead');
    });

    test('all 6 roles exist', () {
      expect(ProjectRole.values.length, 6);
    });
  });

  // ─── Material ──────────────────────────────────────────────

  group('Material', () {
    Material makeMaterial({
      int quantityNeeded = 10,
      int quantityOnSite = 0,
      double? unitCost = 45.00,
      MaterialStatus status = MaterialStatus.needed,
    }) {
      return Material(
        id: 'mat_1',
        projectId: 'proj_1',
        name: '3/4 Plywood',
        quantityNeeded: quantityNeeded,
        quantityOnSite: quantityOnSite,
        unitCost: unitCost,
        status: status,
        createdAt: DateTime(2026, 6, 3),
      );
    }

    test('totalCost is quantityNeeded × unitCost', () {
      final m = makeMaterial(quantityNeeded: 10, unitCost: 45.00);
      expect(m.totalCost, 450.00);
    });

    test('totalCost is null when unitCost is null', () {
      final m = makeMaterial(unitCost: null);
      expect(m.totalCost, isNull);
    });

    test('quantityRemaining is quantityNeeded - quantityOnSite', () {
      final m = makeMaterial(quantityNeeded: 10, quantityOnSite: 3);
      expect(m.quantityRemaining, 7);
    });

    test('isFullyStocked is false when partially stocked', () {
      final m = makeMaterial(quantityNeeded: 10, quantityOnSite: 5);
      expect(m.isFullyStocked, false);
    });

    test('isFullyStocked is true when fully stocked', () {
      final m = makeMaterial(quantityNeeded: 10, quantityOnSite: 10);
      expect(m.isFullyStocked, true);
    });

    test('isFullyStocked is true when over-stocked', () {
      final m = makeMaterial(quantityNeeded: 10, quantityOnSite: 12);
      expect(m.isFullyStocked, true);
    });

    test('default status is needed', () {
      final m = makeMaterial();
      expect(m.status, MaterialStatus.needed);
    });

    test('default quantityOnSite is 0', () {
      final m = makeMaterial();
      expect(m.quantityOnSite, 0);
    });

    test('toString includes name and status', () {
      final m = makeMaterial();
      final str = m.toString();
      expect(str, contains('3/4 Plywood'));
      expect(str, contains('needed'));
    });
  });

  // ─── User ──────────────────────────────────────────────────

  group('User', () {
    User makeUser({String id = 'user_1', String name = 'John'}) {
      return User(
        id: id,
        name: name,
        tradeTags: const ['Framing', 'Flooring'],
        createdAt: DateTime(2026, 6, 3),
      );
    }

    test('isGuest is false for normal users', () {
      final u = makeUser();
      expect(u.isGuest, false);
    });

    test('guest constructor creates guest user', () {
      final u = User.guest();
      expect(u.isGuest, true);
      expect(u.id, 'guest');
      expect(u.name, 'Guest');
    });

    test('summary includes name and trades', () {
      final u = makeUser();
      expect(u.summary(), 'John • Framing, Flooring');
    });

    test('summary is just name when no trades', () {
      final u = User(id: 'u1', name: 'Jane', createdAt: DateTime.now());
      expect(u.summary(), 'Jane');
    });

    test('copyWith preserves unchanged fields', () {
      final original = makeUser();
      final updated = original.copyWith(name: 'Jane');
      expect(updated.name, 'Jane');
      expect(updated.id, original.id);
      expect(updated.tradeTags, original.tradeTags);
    });

    test('default tradeTags is empty', () {
      final u = User(id: 'u1', name: 'Test', createdAt: DateTime.now());
      expect(u.tradeTags, isEmpty);
    });
  });
}
