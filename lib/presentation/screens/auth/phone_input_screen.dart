// lib/presentation/screens/auth/phone_input_screen.dart
//
// PHONE INPUT SCREEN (Riverpod version)
// ======================================
// Now uses Riverpod for state management instead of setState.
// This is the proper Flutter pattern — state lives in providers,
// not in the widget.
//
// KEY CHANGES FROM PREVIOUS VERSION:
// - No more StatefulWidget → StatelessWidget + Riverpod
// - ref.watch(authProvider) rebuilds the UI when auth state changes
// - ref.read(authProvider.notifier) calls methods on the AuthNotifier

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';

// ConsumerWidget = a StatelessWidget that can read Riverpod providers
class PhoneInputScreen extends ConsumerWidget {
  const PhoneInputScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch auth state — rebuilds when it changes
    final authState = ref.watch(authProvider);
    final phoneController = TextEditingController();

    // Listen for auth state changes to navigate when logged in
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next.isLoggedIn) {
        context.go('/projects');
      }
    });

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
                controller: phoneController,
                keyboardType: TextInputType.phone,
                enabled: !authState.isLoading,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  hintText: '+1 (555) 123-4567',
                  prefixIcon: Icon(Icons.phone),
                ),
              ),

              // Error message
              if (authState.error != null) ...[
                const SizedBox(height: 8),
                Text(
                  authState.error!,
                  style: TextStyle(color: Theme.of(context).errorColor),
                ),
              ],

              const SizedBox(height: 24),

              // Continue button
              ElevatedButton(
                onPressed: authState.isLoading
                    ? null
                    : () async {
                        final phone = phoneController.text.trim();
                        if (phone.isEmpty) return;

                        // Call the auth notifier to send OTP
                        final notifier = ref.read(authProvider.notifier);
                        final verificationId = await notifier.sendOtp(phone);

                        if (verificationId != null && context.mounted) {
                          context.go('/auth/verify', extra: phone);
                        }
                      },
                child: authState.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
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
