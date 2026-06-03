// lib/presentation/navigation/app_router.dart
//
// APP ROUTER (Navigation)
// =======================
// Defines all the screens in the app and how to navigate between them.
// Uses GoRouter, which handles:
// - Screen-to-screen navigation
// - Deep links (for invite links)
// - URL-based routing
//
// KEY FLUTTER CONCEPTS:
// - GoRouter = declarative router (define all routes in one place)
// - GoRoute = a single route (path + screen builder)
// - context.go() = navigate to a route
// - context.push() = push a new screen on top

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// ── Auth Screens ──
import 'package:constructflow/presentation/screens/auth/phone_input_screen.dart';
import 'package:constructflow/presentation/screens/auth/otp_verify_screen.dart';

// ── Main Screens ──
import 'package:constructflow/presentation/screens/project/project_list_screen.dart';
import 'package:constructflow/presentation/screens/project/project_create_screen.dart';
import 'package:constructflow/presentation/screens/project/project_detail_screen.dart';

// ── Profile Screens ──
import 'package:constructflow/presentation/screens/profile/profile_screen.dart';

// ── Project Screens ──
import 'package:constructflow/presentation/screens/project/project_dashboard_screen.dart';
import 'package:constructflow/presentation/screens/measurement/measurement_entry_screen.dart';

// ── Placeholder screens for roles (we'll build these later) ──
import 'package:constructflow/presentation/screens/measurement/measurement_list_screen.dart';
import 'package:constructflow/presentation/screens/cut/cut_list_screen.dart';
import 'package:constructflow/presentation/screens/material/material_list_screen.dart';
import 'package:constructflow/presentation/screens/installation/installation_list_screen.dart';
import 'package:constructflow/presentation/screens/cost/cost_overview_screen.dart';

/// The main router for the app
final GoRouter appRouter = GoRouter(
  // Start at the phone input screen (auth flow)
  initialLocation: '/auth/phone',

  routes: [
    // ══════════════════════════════════════════
    // AUTH ROUTES (not logged in)
    // ══════════════════════════════════════════
    GoRoute(
      path: '/auth/phone',
      builder: (context, state) => const PhoneInputScreen(),
    ),
    GoRoute(
      path: '/auth/verify',
      builder: (context, state) {
        // extra passes data between screens
        final phoneNumber = state.extra as String? ?? '';
        return OtpVerifyScreen(phoneNumber: phoneNumber);
      },
    ),

    // ══════════════════════════════════════════
    // MAIN APP ROUTES (logged in)
    // Uses a "shell" route for the bottom navigation bar
    // ══════════════════════════════════════════
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainScaffold(navigationShell: navigationShell);
      },
      branches: [
        // Branch 0: Projects tab
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/projects',
              builder: (context, state) => const ProjectListScreen(),
              routes: [
                GoRoute(
                  path: 'create',
                  builder: (context, state) => const ProjectCreateScreen(),
                ),
                GoRoute(
                  path: ':projectId',
                  builder: (context, state) {
                    final projectId = state.pathParameters['projectId']!;
                    return ProjectDetailScreen(projectId: projectId);
                  },
                  routes: [
                    GoRoute(
                      path: 'dashboard',
                      builder: (context, state) {
                        final projectId = state.pathParameters['projectId']!;
                        return ProjectDashboardScreen(projectId: projectId);
                      },
                    ),
                    GoRoute(
                      path: 'measurements/new',
                      builder: (context, state) {
                        final projectId = state.pathParameters['projectId']!;
                        return MeasurementEntryScreen(projectId: projectId);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        // Branch 1: Profile tab
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),
      ],
    ),

    // ══════════════════════════════════════════
    // ROLE-SPECIFIC ROUTES (inside a project)
    // ══════════════════════════════════════════
    GoRoute(
      path: '/project/:projectId/measurements',
      builder: (context, state) {
        final projectId = state.pathParameters['projectId']!;
        return MeasurementListScreen(projectId: projectId);
      },
    ),
    GoRoute(
      path: '/project/:projectId/cuts',
      builder: (context, state) {
        final projectId = state.pathParameters['projectId']!;
        return CutListScreen(projectId: projectId);
      },
    ),
    GoRoute(
      path: '/project/:projectId/materials',
      builder: (context, state) {
        final projectId = state.pathParameters['projectId']!;
        return MaterialListScreen(projectId: projectId);
      },
    ),
    GoRoute(
      path: '/project/:projectId/installations',
      builder: (context, state) {
        final projectId = state.pathParameters['projectId']!;
        return InstallationListScreen(projectId: projectId);
      },
    ),
    GoRoute(
      path: '/project/:projectId/costs',
      builder: (context, state) {
        final projectId = state.pathParameters['projectId']!;
        return CostOverviewScreen(projectId: projectId);
      },
    ),
  ],
);

// ──────────────────────────────────────────────
// MAIN SCAFFOLD — the bottom navigation bar
// ──────────────────────────────────────────────
// This widget wraps the main app screens with a bottom nav bar.
// It's a "shell" that stays visible while the content above it changes.

class MainScaffold extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainScaffold({
    super.key,
    required this.navigationShell,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell, // The current screen content
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) {
          // Navigate to the selected tab
          navigationShell.goBranch(index);
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.folder_outlined),
            activeIcon: Icon(Icons.folder),
            label: 'Projects',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
