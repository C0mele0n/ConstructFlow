// lib/presentation/screens/auth/otp_verify_screen.dart
//
// OTP VERIFICATION SCREEN
// ========================
// User enters the 6-digit code they received via SMS.
// If correct, they're logged in and taken to the app.
//
// KEY FLUTTER CONCEPTS:
// - FocusNode = controls which input field is active
// - OTP input pattern (6 individual digit fields)
// - Auto-advance to next field after typing a digit

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class OtpVerifyScreen extends StatefulWidget {
  final String phoneNumber;

  const OtpVerifyScreen({
    super.key,
    required this.phoneNumber,
  });

  @override
  State<OtpVerifyScreen> createState() => _OtpVerifyScreenState();
}

class _OtpVerifyScreenState extends State<OtpVerifyScreen> {
  // 6 controllers for 6 digit inputs
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());

  // 6 focus nodes for 6 digit inputs
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  bool _isLoading = false;

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  /// Get the full OTP code from all 6 fields
  String get _otpCode => _controllers.map((c) => c.text).join();

  /// Check if all 6 digits are filled
  bool get _isComplete => _otpCode.length == 6;

  void _verifyCode() async {
    if (!_isComplete) return;

    setState(() => _isLoading = true);

    // TODO: Verify OTP with Firebase Auth
    // For now, accept any 6-digit code
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() => _isLoading = false);
      // Navigate to the main app (project list)
      context.go('/projects');
    }
  }

  void _onDigitChanged(int index, String value) {
    if (value.length == 1 && index < 5) {
      // Move to next field
      _focusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      // Move to previous field on backspace
      _focusNodes[index - 1].requestFocus();
    }
    // Auto-verify when all digits are filled
    if (_isComplete) {
      _verifyCode();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Phone'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),
              Text(
                'Enter the code sent to',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                widget.phoneNumber,
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              // 6 digit input fields
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(6, (index) {
                  return SizedBox(
                    width: 48,
                    height: 56,
                    child: TextField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      decoration: const InputDecoration(
                        counterText: '', // Hide the "0/1" counter
                        border: OutlineInputBorder(),
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      onChanged: (value) => _onDigitChanged(index, value),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 32),

              // Verify button
              ElevatedButton(
                onPressed: _isComplete && !_isLoading ? _verifyCode : null,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Verify'),
              ),
              const SizedBox(height: 16),

              // Resend code
              TextButton(
                onPressed: () {
                  // TODO: Resend OTP
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Code resent')),
                  );
                },
                child: const Text('Didn\'t receive a code? Resend'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
