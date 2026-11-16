/// Core data models for BTV Board Game.
/// Based on Board Game.md ratified 2026-10-29 and default-deck-stats skill.
import 'dart:math';

enum ColorBias {
  M, // magenta (inner)
  R, // red (inner)
  Y, // yellow (inner)
  G, // green (inner)
  C, // cyan (inner)
  B, // blue (inner)
  D, // deep pink / magenta-red (outer)
  O, // orange / red-yellow (outer)
  L, // lime / yellow-green (outer)
  T, // turquoise / green-cyan (outer)
  A, // aqua / cyan-blue (outer)
  P, // purple / blue-magenta (outer)
}

enum ChargePolarity { positive, negative, neutral }

class ChargeCoin {
  final ChargePolarity polarity;
  int count; // 0, 1, 2, or 3+ per bank

  ChargeCoin(this.polarity, this.count);

  ChargeCoin add() => ChargeCoin(polarity, (count + 1).clamp(0, 3));

  ChargeCoin subtract() => ChargeCoin(polarity, (count - 1).clamp(0, 3));

  @override
  String toString() => 'Coin($polarity:$count)';
}

class Card {
  final String name;
  final ColorBias colorBias;
  final int plusCharge;
  final int minusCharge;
  final int capMax;

  Card(this.name, this.colorBias, this.plusCharge, this.minusCharge, this.capMax);

  /// Whether this card can be activated given current bank polarities
  bool canActivate({required int positiveBank, required int negativeBank}) {
    return positiveBank >= plusCharge && negativeBank >= minusCharge;
  }

  /// Get the charge cap this card provides
  int getCapMax() => capMax;

  @override
  String toString() => 'Card(name: $name, color: $colorBias, +:$plusCharge, -:$minusCharge, cap: $capMax)';
}

// The 36-card default deck (finalized 2026-10-29)
// 12 zero-pair cards + 25 non-zero pair cards (1-5 × 1-5) = 36 total
final List<Card> defaultDeck = [
  // Zero-charge cards (12 cards)
  Card('M00', ColorBias.M, 0, 0, 0),
  Card('R01', ColorBias.R, 0, 1, 0),
  Card('Y10', ColorBias.Y, 1, 0, 1),
  Card('G00', ColorBias.G, 0, 0, 0),
  Card('C02', ColorBias.C, 0, 2, 2),
  Card('B20', ColorBias.B, 2, 0, 2),
  Card('D03', ColorBias.D, 0, 3, 3),
  Card('O30', ColorBias.O, 3, 0, 3),
  Card('L04', ColorBias.L, 0, 4, 4),
  Card('T40', ColorBias.T, 4, 0, 4),
  Card('A05', ColorBias.A, 0, 5, 5),
  Card('P50', ColorBias.P, 5, 0, 5),

  // Non-zero pairs (25 cards: 5×5)
  Card('M11', ColorBias.M, 1, 1, 1), Card('M21', ColorBias.M, 2, 1, 2),
  Card('M31', ColorBias.M, 3, 1, 3), Card('M41', ColorBias.M, 4, 1, 4),
  Card('M51', ColorBias.M, 5, 1, 5),
  Card('R12', ColorBias.R, 1, 2, 2), Card('R22', ColorBias.R, 2, 2, 2),
  Card('R32', ColorBias.R, 3, 2, 3), Card('R42', ColorBias.R, 4, 2, 4),
  Card('R52', ColorBias.R, 5, 2, 5),
  Card('Y13', ColorBias.Y, 1, 3, 3), Card('Y23', ColorBias.Y, 2, 3, 3),
  Card('Y33', ColorBias.Y, 3, 3, 3), Card('Y43', ColorBias.Y, 4, 3, 4),
  Card('Y53', ColorBias.Y, 5, 3, 5),
  Card('G14', ColorBias.G, 1, 4, 4), Card('G24', ColorBias.G, 2, 4, 4),
  Card('G34', ColorBias.G, 3, 4, 4), Card('G44', ColorBias.G, 4, 4, 4),
  Card('G54', ColorBias.G, 5, 4, 5),
  Card('B15', ColorBias.B, 1, 5, 5), Card('B25', ColorBias.B, 2, 5, 5),
  Card('B35', ColorBias.B, 3, 5, 5), Card('B45', ColorBias.B, 4, 5, 5),
  Card('B55', ColorBias.B, 5, 5, 5),
];
