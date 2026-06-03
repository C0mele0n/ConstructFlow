// lib/main.dart
//
// APP ENTRY POINT
// ===============
// This is the first file that runs when the app starts.
// It initializes Firebase and launches the app widget.
//
// KEY DART CONCEPTS:
// - async main() = the app starts asynchronously (needs to wait for Firebase)
// - WidgetsFlutterBinding = connects Flutter to the phone's operating system
// - runApp() = starts the Flutter app with our root widget

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';

void main() async {
  // Ensure Flutter is initialized before doing anything else
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase (must complete before app starts)
  await Firebase.initializeApp();

  // Launch the app
  // ProviderScope wraps the entire app so Riverpod state management works everywhere
  runApp(
    const ProviderScope(
      child: ConstructFlowApp(),
    ),
  );
}
