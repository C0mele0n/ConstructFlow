// test/domain/cut_generator_test.dart
//
// Unit tests for the Cut Generator (First Fit Decreasing bin packing).
// These are pure Dart tests — no Flutter or Xcode needed to run.

import 'package:flutter_test/flutter_test.dart';
import 'package:constructflow/data/models/measurement.dart';
import 'package:constructflow/data/models/cut.dart';
import 'package:constructflow/domain/usecases/cut_generator.dart';

void main() {
  // ─── Helpers ───────────────────────────────────────────────

  Measurement makeMeasurement({
    required String id,
    required double length,
    double? width,
    double? height,
    MeasurementUnit unit = MeasurementUnit.inches,
    String materialType = 'lumber',
    int quantity = 1,
  }) {
    return Measurement(
      id: id,
      projectId: 'proj_1',
      measuredByUserId: 'user_1',
      dimensions: Dimensions(
        length: length,
        width: width,
        height: height,
        unit: unit,
      ),
      materialType: materialType,
      quantity: quantity,
      createdAt: DateTime.now(),
    );
  }

  // ─── CutGenerator.generate() ───────────────────────────────

  group('CutGenerator.generate()', () {
    test('generates cuts from a single measurement', () {
      final measurements = [
        makeMeasurement(id: 'm1', length: 48, materialType: 'lumber'),
      ];

      final result = CutGenerator.generate(
        measurements: measurements,
        projectId: 'proj_1',
      );

      expect(result.cuts.length, 1);
      expect(result.cuts.first.length, 48);
      expect(result.cuts.first.status, CutStatus.pending);
      expect(result.totalBoards, 1);
    });

    test('expands quantity into multiple cuts', () {
      final measurements = [
        makeMeasurement(id: 'm1', length: 24, materialType: 'lumber', quantity: 3),
      ];

      final result = CutGenerator.generate(
        measurements: measurements,
        projectId: 'proj_1',
      );

      expect(result.cuts.length, 3);
      for (final cut in result.cuts) {
        expect(cut.length, 24);
      }
    });

    test('groups cuts by material type', () {
      final measurements = [
        makeMeasurement(id: 'm1', length: 48, materialType: 'lumber'),
        makeMeasurement(id: 'm2', length: 36, materialType: 'plywood'),
      ];

      final result = CutGenerator.generate(
        measurements: measurements,
        projectId: 'proj_1',
      );

      expect(result.cuts.length, 2);
      // Each material type gets its own board group
      expect(result.totalBoards, 2);
    });

    test('uses custom board length when provided', () {
      final measurements = [
        makeMeasurement(id: 'm1', length: 48, materialType: 'lumber'),
        makeMeasurement(id: 'm2', length: 48, materialType: 'lumber'),
      ];

      final result = CutGenerator.generate(
        measurements: measurements,
        projectId: 'proj_1',
        customBoardLength: 100,
      );

      // Both 48-inch cuts should fit on one 100-inch board (48 + 0.125 kerf + 48 = 96.25 < 100)
      expect(result.totalBoards, 1);
    });

    test('returns empty result for empty measurements', () {
      final result = CutGenerator.generate(
        measurements: [],
        projectId: 'proj_1',
      );

      expect(result.cuts, isEmpty);
      expect(result.boards, isEmpty);
      expect(result.totalWaste, 0);
      expect(result.totalBoards, 0);
    });
  });

  // ─── First Fit Decreasing Algorithm ────────────────────────

  group('First Fit Decreasing', () {
    test('sorts cuts longest first', () {
      final measurements = [
        makeMeasurement(id: 'm1', length: 24, materialType: 'lumber'),
        makeMeasurement(id: 'm2', length: 96, materialType: 'lumber'),
        makeMeasurement(id: 'm3', length: 48, materialType: 'lumber'),
      ];

      final result = CutGenerator.generate(
        measurements: measurements,
        projectId: 'proj_1',
        customBoardLength: 96,
      );

      // The 96-inch cut goes first, then 48, then 24
      // 96 fits on board 1 (uses 96.125 with kerf — actually exactly 96 + kerf)
      // 48 fits on board 2
      // 24 fits on board 2 (48 + 0.125 + 24 = 72.125 < 96)
      expect(result.totalBoards, 2);
    });

    test('packs multiple cuts onto one board when they fit', () {
      final measurements = [
        makeMeasurement(id: 'm1', length: 30, materialType: 'lumber'),
        makeMeasurement(id: 'm2', length: 30, materialType: 'lumber'),
        makeMeasurement(id: 'm3', length: 30, materialType: 'lumber'),
      ];

      final result = CutGenerator.generate(
        measurements: measurements,
        projectId: 'proj_1',
        customBoardLength: 96,
      );

      // 30 + 0.125 + 30 + 0.125 + 30 = 90.25 < 96 — all fit on one board
      expect(result.totalBoards, 1);
    });

    test('starts a new board when cut does not fit', () {
      final measurements = [
        makeMeasurement(id: 'm1', length: 60, materialType: 'lumber'),
        makeMeasurement(id: 'm2', length: 60, materialType: 'lumber'),
      ];

      final result = CutGenerator.generate(
        measurements: measurements,
        projectId: 'proj_1',
        customBoardLength: 96,
      );

      // 60 + 0.125 = 60.125, remaining = 35.875 — next 60 doesn't fit
      expect(result.totalBoards, 2);
    });

    test('accounts for saw kerf in fit calculations', () {
      // Two 48-inch cuts on a 96-inch board
      // 48 + 0.125 (kerf) + 48 = 96.125 > 96 — should NOT fit on one board
      final measurements = [
        makeMeasurement(id: 'm1', length: 48, materialType: 'lumber'),
        makeMeasurement(id: 'm2', length: 48, materialType: 'lumber'),
      ];

      final result = CutGenerator.generate(
        measurements: measurements,
        projectId: 'proj_1',
        customBoardLength: 96,
      );

      // With kerf: 48 + 0.125 + 48 = 96.125 > 96, so needs 2 boards
      expect(result.totalBoards, 2);
    });
  });

  // ─── CutBoard ──────────────────────────────────────────────

  group('CutBoard', () {
    test('remainingLength starts at totalLength', () {
      final board = CutBoard(96);
      expect(board.remainingLength, 96);
    });

    test('remainingLength decreases after adding cuts', () {
      final board = CutBoard(96);
      board.cuts.add(CutAssignment(cutId: 'c1', measurementId: 'm1', length: 48, position: 0));
      // Used: 48 + 0.125 kerf = 48.125
      expect(board.remainingLength, closeTo(96 - 48 - 0.125, 0.001));
    });

    test('canFit returns true when cut fits', () {
      final board = CutBoard(96);
      expect(board.canFit(48), true);
    });

    test('canFit returns false when cut does not fit', () {
      final board = CutBoard(96);
      board.cuts.add(CutAssignment(cutId: 'c1', measurementId: 'm1', length: 96, position: 0));
      // Board is full (96 + 0.125 kerf used)
      expect(board.canFit(1), false);
    });

    test('wastePercent is 0 for empty board', () {
      final board = CutBoard(96);
      expect(board.wastePercent, 0);
    });

    test('wastePercent increases as cuts are added', () {
      final board = CutBoard(96);
      board.cuts.add(CutAssignment(cutId: 'c1', measurementId: 'm1', length: 48, position: 0));
      expect(board.wastePercent, greaterThan(0));
      expect(board.wastePercent, lessThan(1));
    });
  });

  // ─── Standard Sizes ────────────────────────────────────────

  group('Standard board sizes', () {
    test('plywood uses 96-inch boards', () {
      final measurements = [
        makeMeasurement(id: 'm1', length: 48, materialType: 'plywood'),
      ];

      final result = CutGenerator.generate(
        measurements: measurements,
        projectId: 'proj_1',
      );

      expect(result.boards.first.totalLength, 96);
    });

    test('lumber 12ft uses 144-inch boards', () {
      final measurements = [
        makeMeasurement(id: 'm1', length: 48, materialType: 'lumber 12ft'),
      ];

      final result = CutGenerator.generate(
        measurements: measurements,
        projectId: 'proj_1',
      );

      expect(result.boards.first.totalLength, 144);
    });

    test('unknown material type defaults to 96-inch boards', () {
      final measurements = [
        makeMeasurement(id: 'm1', length: 48, materialType: 'unobtainium'),
      ];

      final result = CutGenerator.generate(
        measurements: measurements,
        projectId: 'proj_1',
      );

      expect(result.boards.first.totalLength, 96);
    });
  });

  // ─── Waste Calculation ─────────────────────────────────────

  group('Waste calculation', () {
    test('total waste is sum of all board remainders', () {
      final measurements = [
        makeMeasurement(id: 'm1', length: 48, materialType: 'lumber'),
        makeMeasurement(id: 'm2', length: 48, materialType: 'lumber'),
      ];

      final result = CutGenerator.generate(
        measurements: measurements,
        projectId: 'proj_1',
        customBoardLength: 96,
      );

      // Each board has one 48-inch cut
      // Remaining per board: 96 - 48 - 0.125 = 47.875
      // Total waste: 47.875 * 2 = 95.75
      expect(result.totalWaste, closeTo(95.75, 0.01));
    });

    test('zero waste when board is perfectly filled', () {
      // One 96-inch cut on a 96-inch board (kerf still applies though)
      final measurements = [
        makeMeasurement(id: 'm1', length: 95.875, materialType: 'lumber'),
      ];

      final result = CutGenerator.generate(
        measurements: measurements,
        projectId: 'proj_1',
        customBoardLength: 96,
      );

      // 95.875 + 0.125 kerf = 96.0 — perfect fit
      expect(result.totalWaste, closeTo(0, 0.01));
    });
  });
}
