// lib/presentation/widgets/offline_indicator.dart
//
// OFFLINE INDICATOR WIDGET
// ========================
// Shows a banner at the top of the screen when the device is offline.
// Uses Riverpod to watch connectivity changes.
//
// This is a key UX element for an offline-first app — users need to know
// that their data is being saved locally and will sync when reconnected.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/sync_service.dart';

/// Provider that streams online/offline status
final connectivityProvider = StreamProvider<bool>((ref) {
  return ref.watch(syncServiceProvider).connectivityStream;
});

class OfflineIndicator extends ConsumerWidget {
  const OfflineIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectivity = ref.watch(connectivityProvider);

    return connectivity.when(
      data: (isOnline) {
        if (isOnline) return const SizedBox.shrink();
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          color: Colors.orange,
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cloud_off, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text(
                'You\'re offline — changes will sync when reconnected',
                style: TextStyle(color: Colors.white, fontSize: 13),
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
