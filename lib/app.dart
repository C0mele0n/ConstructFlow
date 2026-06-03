// lib/app.dart
//
// ROOT APP WIDGET
// ===============
// The top-level widget that configures the entire app:
// - Theme (colors, fonts, spacing)
// - Routing (which screen shows when)
// - Navigation structure
//
// KEY FLUTTER CONCEPTS:
// - MaterialApp = the standard Google-style app wrapper
// - MaterialApp.router = same but with GoRouter for navigation
// - ThemeData = defines the look and feel of the entire app
// - Scaffold = the basic screen structure (app bar, body, bottom bar)

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'core/theme/app_theme.dart';
import 'presentation/navigation/app_router.dart';

class ConstructFlowApp extends StatelessWidget {
  const ConstructFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MaterialApp.router sets up navigation with GoRouter
    return MaterialApp.router(
      title: 'ConstructFlow',

      // Theme — the visual style of the entire app
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,

      // Router — handles all screen navigation
      routerConfig: appRouter,

      // Remove the debug banner in the top-right corner
      debugShowCheckedModeBanner: false,
    );
  }
}
