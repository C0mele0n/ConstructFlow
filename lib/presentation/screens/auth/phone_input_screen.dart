// lib/presentation/screens/auth/phone_input_screen.dart
//
// PHONE INPUT SCREEN
// ===================
// The first screen the user sees. They enter their phone number
// to receive a one-time password (OTP) via SMS.
//
// KEY FLUTTER CONCEPTS:
// - StatefulWidget = a widget that can change over time (has "state")
// - TextEditingController = controls a text input field
// - Form + TextFormField = input field with validation
// - context.go() = navigate to another screen

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PhoneInputScreen extends StatefulWidget {
  const PhoneInputScreen({super.key});

  @override
  State<PhoneInputScreen> createState() => _PhoneInputScreenState();
}

class _PhoneInputScreenState extends State<PhoneInputScreen> {
  // Controller — reads and controls the text in the input field
  final _phoneController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    // Clean up the controller when the screen is removed
    _phoneController.dispose();
    super.dispose();
  }

  void _sendCode() async {
    final phone = _phoneController.text.trim();

    // Basic validation
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your phone number')),
      );
      return;
    }

    setState(() => _isLoading = true);

    // TODO: Send OTP via Firebase Auth
    // For now, just navigate to the verify screen
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay

    if (mounted) {
      setState(() => _isLoading = false);
      // Navigate to OTP verification, passing the phone number
      context.go('/auth/verify', extra: phone);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // App logo / title
              const Icon(
                Icons.construction,
                size: 80,
                color: Color(0xFFD4762C),
              ),
              const SizedBox(height: 24),
              Text(
                'ConstructFlow',
                style: Theme.of(context).textTheme.headlineLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Enter your phone number to get started',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              // Phone number input
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  hintText: '(555) 123-4567',
                  prefixIcon: Icon(Icons.phone),
                ),
              ),
              const SizedBox(height: 24),

              // Continue button
              ElevatedButton(
                onPressed: _isLoading ? null : _sendCode,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Send Code'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
