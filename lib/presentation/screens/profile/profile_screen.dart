// lib/presentation/screens/profile/profile_screen.dart
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Profile', style: TextStyle(fontSize: 18)),
            Text('Name, trade tags, portfolio', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
