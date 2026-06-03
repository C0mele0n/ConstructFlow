// test/domain/voice_parser_test.dart
//
// Unit tests for voice input parsing logic.
// Tests the regex patterns and keyword matching used in MeasurementEntryScreen.

import 'package:flutter_test/flutter_test.dart';

/// A simplified version of the voice parsing logic from MeasurementMeasurementEntryScreen,
// extracted into pure functions for testability.

/// Represents a parsed voice input
class ParsedVoiceInput {
  final String? length;
  final String? width;
  final String? height;
  final String unit;
  final String? material;
  final String? quantity;

  ParsedVoiceInput({
    this.length,
    this.width,
    this.height,
    this.unit = 'inches',
    this.material,
    this.quantity,
  });
}

/// Parse voice input into measurement fields (mirrors _parseVoiceInput logic)
ParsedVoiceInput parseVoiceInput(String input) {
  final lower = input.toLowerCase().trim();
  String? length;
  String? width;
  String? height;
  String unit = 'inches';
  String? material;
  String? quantity;

  // Parse dimensions
  final dimPattern = RegExp(
    r'(\d+(?:/\d+)?(?:\s+\d+/\d+)?)\s*(?:inches?|in|feet|ft|cm|m)?\s*(?:by|x|×)\s*(\d+(?:/\d+)?(?:\s+\d+/\d+)?)\s*(?:inches?|in|feet|ft|cm|m)?(?:\s*(?:by|x|×)\s*(\d+(?:/\d+)?)\s*(?:inches?|in|feet|ft|cm|m)?)?',
  );

  final match = dimPattern.firstMatch(lower);
  if (match != null) {
    length = match.group(1)?.trim();
    width = match.group(2)?.trim();
    if (match.group(3) != null) {
      height = match.group(3)!.trim();
    }
  }

  // Detect unit
  if (lower.contains('foot') || lower.contains('feet') || lower.contains(' ft')) {
    unit = 'feet';
  } else if (lower.contains('cm') || lower.contains('centimeter')) {
    unit = 'centimeters';
  } else if (lower.contains('meter') || lower.contains(' m ')) {
    unit = 'meters';
  }

  // Detect material type
  final materialKeywords = <String, String>{
    'plywood': 'Plywood',
    'drywall': 'Drywall',
    'osb': 'OSB',
    'two by four': '2x4',
    '2x4': '2x4',
    '2x6': '2x6',
    '2x8': '2x8',
    'two by six': '2x6',
    'two by eight': '2x8',
    'two by ten': '2x10',
    'decking': 'Decking',
    'trim': 'Trim',
    'casing': 'Casing',
    'baseboard': 'Baseboard',
    'countertop': 'Countertop',
    'tile': 'Tile',
    'lumber': 'Lumber',
    'lvl': 'LVL',
    'joist': 'Joist',
    'rafter': 'Rafter',
    'stud': 'Stud',
    'beam': 'Beam',
    'concrete': 'Concrete',
    'insulation': 'Insulation',
    'shingle': 'Shingle',
    'flashing': 'Flashing',
  };

  for (final entry in materialKeywords.entries) {
    if (lower.contains(entry.key)) {
      material = entry.value;
      break;
    }
  }

  // Detect quantity
  final qtyPattern = RegExp(r'\b(\d+)\s*(?:pieces?|sheets?|boards?|pcs?|qty)\b');
  final qtyMatch = qtyPattern.firstMatch(lower);
  if (qtyMatch != null) {
    quantity = qtyMatch.group(1);
  }

  return ParsedVoiceInput(
    length: length,
    width: width,
    height: height,
    unit: unit,
    material: material,
    quantity: quantity,
  );
}

void main() {
  group('Dimension parsing', () {
    test('parses "48 inches by 26 inches"', () {
      final result = parseVoiceInput('48 inches by 26 inches');
      expect(result.length, '48');
      expect(result.width, '26');
    });

    test('parses "48 by 26"', () {
      final result = parseVoiceInput('48 by 26');
      expect(result.length, '48');
      expect(result.width, '26');
    });

    test('parses "48 x 26"', () {
      final result = parseVoiceInput('48 x 26');
      expect(result.length, '48');
      expect(result.width, '26');
    });

    test('parses three dimensions "48 by 26 by 3/4"', () {
      final result = parseVoiceInput('48 by 26 by 3/4');
      expect(result.length, '48');
      expect(result.width, '26');
      expect(result.height, '3/4');
    });

    test('parses fractions "3/4 by 48"', () {
      final result = parseVoiceInput('3/4 by 48');
      expect(result.length, '3/4');
      expect(result.width, '48');
    });

    test('handles mixed fractions "1 3/4 by 48"', () {
      final result = parseVoiceInput('1 3/4 by 48');
      expect(result.length, '1 3/4');
      expect(result.width, '48');
    });

    test('returns null dimensions for non-matching input', () {
      final result = parseVoiceInput('plywood countertop');
      expect(result.length, isNull);
      expect(result.width, isNull);
    });
  });

  group('Unit detection', () {
    test('detects inches from "inches"', () {
      final result = parseVoiceInput('48 inches by 26 inches');
      expect(result.unit, 'inches');
    });

    test('detects inches from "in" abbreviation', () {
      final result = parseVoiceInput('48 in by 26 in');
      expect(result.unit, 'inches');
    });

    test('detects feet from "feet"', () {
      final result = parseVoiceInput('4 feet by 8 feet');
      expect(result.unit, 'feet');
    });

    test('detects feet from "ft" abbreviation', () {
      final result = parseVoiceInput('4 ft by 8 ft');
      expect(result.unit, 'feet');
    });

    test('detects centimeters', () {
      final result = parseVoiceInput('120 cm by 60 cm');
      expect(result.unit, 'centimeters');
    });

    test('detects meters', () {
      final result = parseVoiceInput('4 m by 2 m');
      expect(result.unit, 'meters');
    });

    test('defaults to inches when no unit specified', () {
      final result = parseVoiceInput('48 by 26');
      expect(result.unit, 'inches');
    });

    test('detects feet even with "foot" (singular)', () {
      final result = parseVoiceInput('10 foot board');
      expect(result.unit, 'feet');
    });
  });

  group('Material detection', () {
    test('detects plywood', () {
      final result = parseVoiceInput('48 by 26 plywood');
      expect(result.material, 'Plywood');
    });

    test('detects drywall', () {
      final result = parseVoiceInput('48 by 96 drywall');
      expect(result.material, 'Drywall');
    });

    test('detects 2x4', () {
      final result = parseVoiceInput('96 inches 2x4');
      expect(result.material, '2x4');
    });

    test('detects "two by four" written out', () {
      final result = parseVoiceInput('96 inches two by four');
      expect(result.material, '2x4');
    });

    test('detects "two by six" written out', () {
      final result = parseVoiceInput('96 inches two by six');
      expect(result.material, '2x6');
    });

    test('detects countertop', () {
      final result = parseVoiceInput('48 by 26 countertop');
      expect(result.material, 'Countertop');
    });

    test('detects tile', () {
      final result = parseVoiceInput('12 by 12 tile');
      expect(result.material, 'Tile');
    });

    test('detects decking', () {
      final result = parseVoiceInput('5/4 decking 10 feet');
      expect(result.material, 'Decking');
    });

    test('detects trim', () {
      final result = parseVoiceInput('1x4 trim 8 feet');
      expect(result.material, 'Trim');
    });

    test('returns null for unknown material', () {
      final result = parseVoiceInput('48 by 26 somethingorother');
      expect(result.material, isNull);
    });

    test('first matching material wins', () {
      final result = parseVoiceInput('plywood and drywall 48 by 26');
      expect(result.material, 'Plywood');
    });
  });

  group('Quantity detection', () {
    test('detects "5 pieces"', () {
      final result = parseVoiceInput('48 by 26 plywood 5 pieces');
      expect(result.quantity, '5');
    });

    test('detects "3 sheets"', () {
      final result = parseVoiceInput('48 by 96 drywall 3 sheets');
      expect(result.quantity, '3');
    });

    test('detects "10 boards"', () {
      final result = parseVoiceInput('96 2x4 10 boards');
      expect(result.quantity, '10');
    });

    test('detects "4 qty"', () {
      final result = parseVoiceInput('plywood 4 qty');
      expect(result.quantity, '4');
    });

    test('returns null when no quantity specified', () {
      final result = parseVoiceInput('48 by 26 plywood');
      expect(result.quantity, isNull);
    });
  });

  group('Full phrase parsing', () {
    test('parses complete phrase: "48 inches by 26 inches quartz countertop"', () {
      final result = parseVoiceInput('48 inches by 26 inches quartz countertop');
      expect(result.length, '48');
      expect(result.width, '26');
      expect(result.unit, 'inches');
      expect(result.material, 'Countertop');
    });

    test('parses: "two by four ten foot"', () {
      final result = parseVoiceInput('two by four ten foot');
      expect(result.unit, 'feet');
      expect(result.material, '2x4');
    });

    test('parses: "3/4 plywood 4 by 8 5 sheets"', () {
      final result = parseVoiceInput('3/4 plywood 4 by 8 5 sheets');
      expect(result.length, '4');
      expect(result.width, '8');
      expect(result.material, 'Plywood');
      expect(result.quantity, '5');
    });

    test('handles extra whitespace', () {
      final result = parseVoiceInput('  48   by   26   plywood  ');
      expect(result.length, '48');
      expect(result.width, '26');
      expect(result.material, 'Plywood');
    });
  });
}
