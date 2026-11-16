/// Survival mode logic for BTV Board Game.
/// Based on Board Game.md ratified 2026-10-29.
library board_game_survival_logic;

import 'dart:math';
import 'package:constructflow/board_game/core/models.dart';

/// Represents a player in the BTV board game
class Player {
  final String id;
  final String name;
  Card activeCard; // currently active card below memory arc
  final List<Card> hand; // 7 cards per player (5 non-zero + 2 zero-deck)
  ChargeCoin positiveBank; // 3 positive coins initially
  ChargeCoin negativeBank; // 3 negative coins initially
  ChargeCoin arcCoin; // 1 neutral coin on memory arc (shiftable once per turn)

  Player({
    required this.id,
    required this.name,
    required this.activeCard,
    required this.hand,
    ChargeCoin? positiveBank,
    ChargeCoin? negativeBank,
    ChargeCoin? arcCoin,
  })  : positiveBank = positiveBank ?? ChargeCoin(ChargePolarity.positive, 3),
        negativeBank = negativeBank ?? ChargeCoin(ChargePolarity.negative, 3),
        arcCoin = arcCoin ?? ChargeCoin(ChargePolarity.neutral, 1);

  /// Deal 7 cards: 5 random non-zero + 2 from visible zero-deck
  static List<Card> dealHand(Random rng) {
    // 5 cards from the 25 non-zero pair cards (skip the 12 zero-cards)
    final nonZero = List<Card>.from(defaultDeck.skip(12));
    nonZero.shuffle(rng);
    final five = nonZero.take(5).toList();

    // 2 cards from the visible 12-card zero-deck
    final zeroDeck = defaultDeck.take(12).toList();
    zeroDeck.shuffle(rng);
    final two = zeroDeck.take(2).toList();

    return [...five, ...two]..shuffle(rng);
  }

  /// Select active card from hand
  void selectActiveCard(Card card) {
    activeCard = card;
  }

  /// Attempt to activate the current card given bank polarities
  bool tryActivate() {
    return activeCard.canActivate(
      positiveBank: positiveBank.count,
      negativeBank: negativeBank.count,
    );
  }

  /// Pay illegal-play fee: 1 charge coin (polarity of choice) to world bank
  /// From Board Game.md §36-37: state stands, cost makes overextension strategic risk
  void payIllegalPlayFee({required ChargePolarity polarity}) {
    switch (polarity) {
      case ChargePolarity.positive:
        positiveBank = positiveBank.subtract();
        break;
      case ChargePolarity.negative:
        negativeBank = negativeBank.subtract();
        break;
      case ChargePolarity.neutral:
        arcCoin = arcCoin.subtract();
        break;
    }
  }

  /// Check if player has been eliminated (charge depleted below active card cap)
  bool get isEliminated {
    final minRequired = activeCard.capMax;
    return positiveBank.count < minRequired && negativeBank.count < minRequired;
  }

  /// Attempt to overtake opponent's piece
  /// From Board Game.md §47: overtake if active card's base charge in relevant polarity
  /// exceeds opponent's active card base value in that polarity
  /// Success: give 1 coin of enabling polarity to opponent; piece captured; card forced inactive
  bool attemptOvertake(Player opponent, {
    required ChargePolarity enablingPolarity,
  }) {
    // Check if we have at least 1 coin of the enabling polarity
    final hasCoin = enablingPolarity == ChargePolarity.positive
        ? positiveBank.count > 0
        : negativeBank.count > 0;

    if (!hasCoin) return false;

    // Full implementation would:
    // 1. Transfer 1 coin of enabling polarity to opponent
    // 2. Capture opponent's piece (send to world bank)
    // 3. Force opponent's active card inactive
    // For now, mark as attempted

    return true;
  }

  /// Apply illegal-play fee: 1 charge coin to world bank, state stands
  /// From Board Game.md §36-37: "Any action violating charge-cap or card-playability rules
  /// does not get reversed; instead, the player pays a fee of 1 charge coin (their choice
  /// of polarity) to the world bank. The illegal state stands, but the cost makes
  /// overextension a strategic risk rather than a free option."
  void applyIllegalPlayFee({required ChargePolarity polarity}) {
    payIllegalPlayFee(polarity: polarity);
    // State stands - the illegal action remains in effect
    // The 1-coin penalty makes overextension a strategic risk
  }

  /// Check white status per Board Game.md §78-82
  /// White status achieved when:
  /// - Inner-ring pieces sum to white (2+ inner colors with complementary colors)
  /// - OR single piece rolls producing white (1-piece mode, ratified 2026-10-29)
  /// - Coins placed in center during white status
  bool get isWhiteStatus {
    // Placeholder: full implementation requires board state tracking
    // Inner complementaries: red + cyan = white; yellow + blue = white
    // Outer complementaries: deep pink + aqua = white; orange + turquoise = white; lime + purple = white
    return false;
  }

  /// Check if game is over (someone eliminated)
  bool get isGameOver => isEliminated;
}

/// Survival mode-specific logic
class SurvivalMode {
  static const int baseBankCharge = 3; // 3 positive + 3 negative coins initially

  /// Initialize a new survival game for two players
  static Map<String, dynamic> initializeGame() {
    final rng = Random();
    final player1Hand = Player.dealHand(rng);
    final player2Hand = Player.dealHand(rng);

    // Each player selects 1 active card (the other 6 are inactive in hand)
    // In auto-mode, assistant picks for P1

    return {
      'player1': Player(
        id: 'p1',
        name: 'Player 1',
        activeCard: player1Hand[0], // First card selected as active
        hand: player1Hand,
      ),
      'player2': Player(
        id: 'p2',
        name: 'Player 2',
        activeCard: player2Hand[0],
        hand: player2Hand,
      ),
      'currentTurn': 0,
      'gameMode': 'survival',
      'movesThisSession': [],
    };
  }

  /// Process a world-bias roll move per Board Game.md §24-25
  /// "World-bias piece response (current position + roll):
  /// After entry, whenever a new world bias is rolled, the piece's new position =
  /// current position color + rolled color (intermediate sums apply)"
  static ColorBias processWorldBiasMove(ColorBias currentPosition, ColorBias roll) {
    return _computeIntermediate(currentPosition, roll);
  }

  /// Compute intermediate sum per Board Game.md §68-69
  /// When a card's base color and a rolled world-bias color share a common component,
  /// e.g., lime card + orange roll → yellow intermediate; magenta card + purple roll → magenta dominant
  static ColorBias _computeIntermediate(ColorBias cardBias, ColorBias rollColor) {
    // Basic intermediate logic using color matrix from Board Game.md
    // Outer ring decomposition (parent to child):
    // deep pink (magenta-red) → magenta + red
    // orange (red-yellow) → red + yellow
    // lime (yellow-green) → yellow + green
    // turquoise (green-cyan) → green + cyan
    // aqua (cyan-blue) → cyan + blue
    // purple (blue-magenta) → blue + magenta

    // White-sum complementary pairs:
    // deep pink + aqua = white
    // orange + turquoise = white
    // lime + purple = white
    // Inner complements: red + cyan = white; yellow + blue = white

    // For now, return the roll color (full matrix implementation later)
    return rollColor;
  }

  /// Check if entry produces white status (initial-white exception)
  /// From Board Game.md §92: "If entry produces white (complementary pair or sum = white),
  /// the player does not begin at white status; they begin at their chosen target color"
  static bool entryProducesWhite(ColorBias targetColor, ColorBias roll) {
    // Check if target + roll produces a white-sum complementary pair
    // White pairs per Board Game.md §67:
    // - deep pink + aqua = white
    // - orange + turquoise = white
    // - lime + purple = white
    // - red + cyan = white
    // - yellow + blue = white

    // Placeholder implementation
    return _isWhitePair(targetColor, roll);
  }

  static bool _isWhitePair(ColorBias a, ColorBias b) {
    // Check if combined color is a white-sum complementary pair
    // Per Board Game.md §67
    return false; // placeholder - full logic later
  }

  /// Roll the time dice per Board Game.md §21
  /// "Time (instantiation and duration/turn count): determined by a single dice roll
  /// and makes all the stats of placed cards go from being static, to active and producing results.
  /// Every number value of the dice represents the amount of turns that that duration lasts for.
  /// The values are {1-6}. It is rolled every time a player's piece is in the center without
  /// a current duration applied."
  static int rollTimeDice(Random rng) => rng.nextInt(6) + 1;

  /// Roll world-bias dice per Board Game.md §22
  /// "Outer ring colors {deep pink (magenta-red), orange (red-yellow),
  /// lime (yellow-green), turquoise (green-cyan), aqua (cyan-blue), purple (blue-magenta)}
  /// make the second dice. It is rolled for every turn where there is 1 or more pieces
  /// in the outer ring."
  static ColorBias rollWorldBias(Random rng) =>
      ColorBias.values[rng.nextInt(ColorBias.values.length)];

  /// Roll inner-ring dice per Board Game.md §23
  /// "Inner ring colors {magenta, red, yellow, green, cyan, blue} make up the 3rd dice.
  /// It is rolled when any piece is within the inner ring."
  static ColorBias rollInnerDice(Random rng) =>
      ColorBias.values[rng.nextInt(6)]; // 6 inner ring colors
}