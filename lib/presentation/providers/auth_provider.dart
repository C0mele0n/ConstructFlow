// lib/presentation/providers/auth_provider.dart
//
// AUTH PROVIDER (Riverpod)
// ========================
// Manages authentication state for the entire app.
// Any screen can "watch" this provider to know if the user is logged in.
//
// KEY RIVERPOD CONCEPTS:
// - StateNotifier = holds state and notifies listeners when it changes
// - StateNotifierProvider = creates a StateNotifier and provides it to the UI
// - ref.watch() = listen to a provider (rebuilds UI when state changes)
// - ref.read() = read a provider's value once (no rebuild)

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/auth_service.dart';

/// Authentication state
class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
  });

  bool get isLoggedIn => user != null;

  AuthState copyWith({
    User? user,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Auth state notifier — manages auth state changes
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(const AuthState()) {
    // Listen to Firebase auth state changes
    _authService.authStateChanges.listen((user) {
      state = state.copyWith(user: user, isLoading: false);
    });
  }

  /// Send OTP to phone number
  Future<String?> sendOtp(String phoneNumber) async {
    state = state.copyWith(isLoading: true, error: null);
    String? verificationId;

    await _authService.sendOtp(
      phoneNumber: phoneNumber,
      onCodeSent: (id) {
        verificationId = id;
        state = state.copyWith(isLoading: false);
      },
      onError: (error) {
        state = state.copyWith(isLoading: false, error: error);
      },
      onAutoVerified: (credential) async {
        // Android auto-verification
        final result = await _authService._auth.signInWithCredential(credential);
        state = state.copyWith(user: result.user, isLoading: false);
      },
    );

    return verificationId;
  }

  /// Verify OTP code
  Future<bool> verifyOtp(String verificationId, String otpCode) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _authService.verifyOtp(
      verificationId: verificationId,
      otpCode: otpCode,
    );

    if (result != null) {
      state = state.copyWith(user: result.user, isLoading: false);
      return true;
    } else {
      state = state.copyWith(isLoading: false, error: 'Invalid code');
      return false;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    await _authService.signOut();
    state = const AuthState();
  }
}

// ──────────────────────────────────────────────
// PROVIDERS
// ──────────────────────────────────────────────

/// Auth service provider (singleton)
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

/// Auth state provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthNotifier(authService);
});
