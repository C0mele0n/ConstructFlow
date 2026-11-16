import 'package:flutter/material.dart';
import 'package:constructflow/board_game/core/models.dart' as models;
import 'package:constructflow/board_game/logic/survival_logic.dart' as survival;

void main() {
  runApp(const BoardGameApp());
}

class BoardGameApp extends StatelessWidget {
  const BoardGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BTV Board Game',
      theme: ThemeData.dark().copyWith(
        primaryColor: const Color(0xFF9B59B6), // magenta from ColorBias.M
        scaffoldBackgroundColor: Colors.green.shade900,
      ),
      home: const BoardSetupScreen(),
    );
  }
}

class BoardSetupScreen extends StatelessWidget {
  const BoardSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BTV Board Game - Survival Mode'),
        backgroundColor: Colors.green.shade800,
      ),
      body: const Center(
        child: Text(
          'BTV Board Game Logic',
          style: TextStyle(
            fontSize: 24,
            color: Colors.amber,
          ),
        ),
      ),
    );
  }
}