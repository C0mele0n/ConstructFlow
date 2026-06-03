// lib/services/auth_service.dart
//
// AUTH SERVICE
// ============
// Handles all authentication: phone OTP, sign in, sign out, current user.
// This is the bridge between our app and Firebase Authentication.
//
// KEY CONCEPTS:
// - Singleton pattern = only one instance of this service exists
// - Stream = a sequence of values over time (like a live feed of auth state)
// - Firebase Auth = Google's authentication service

import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  // Singleton: one instance shared across the entire app
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // Firebase Auth instance
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Stream of authentication state changes
  /// Emits the current User when logged in, null when logged out
  /// The UI listens to this and shows the right screen
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Current Firebase user (null if not logged in)
  User? get currentUser => _auth.currentUser;

  /// Is someone currently logged in?
  bool get isLoggedIn => _auth.currentUser != null;

  // ──────────────────────────────────────────────
  // PHONE OTP AUTHENTICATION FLOW
  // ──────────────────────────────────────────────
  // Firebase phone auth is a 2-step process:
  // 1. Send OTP to the phone number
  // 2. Verify the OTP code the user received
  //
  // We use "verificationCompleted" callback to auto-verify on Android
  // (Android can read the SMS automatically). On iOS, the user types the code.

  /// Step 1: Send OTP to the given phone number
  /// Returns a verificationId that we need for step 2
  Future<void> sendOtp({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(String error) onError,
    required Function(PhoneAuthCredential credential) onAutoVerified,
  }) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        // Auto-verify on Android (no manual code entry needed)
        verificationCompleted: (PhoneAuthCredential credential) {
          onAutoVerified(credential);
        },
        // Firebase couldn't auto-verify, user needs to type the code
        verificationFailed: (FirebaseAuthException e) {
          onError(e.message ?? 'Verification failed');
        },
        // OTP was sent to the phone
        codeSent: (String verificationId, int? resendToken) {
          onCodeSent(verificationId);
        },
        // Auto-retrieval timed out
        codeAutoRetrievalTimeout: (String verificationId) {
          // Optionally handle timeout
        },
        // How long to wait for auto-verification (Android)
        timeout: const Duration(seconds: 60),
      );
    } catch (e) {
      onError(e.toString());
    }
  }

  /// Step 2: Verify the OTP code the user typed
  /// Returns the Firebase User if successful
  Future<UserCredential?> verifyOtp({
    required String verificationId,
    required String otpCode,
  }) async {
    try {
      // Create a credential from the verification ID and OTP code
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otpCode,
      );
      // Sign in with the credential
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      return null;
    }
  }

  /// Sign out the current user
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
