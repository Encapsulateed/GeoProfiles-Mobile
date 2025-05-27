// lib/ui/pages/profiles/profile_detail_page.dart
import 'package:flutter/material.dart';

class ProfileDetailPage extends StatelessWidget {
  final String projectId;
  final String profileId;
  const ProfileDetailPage({super.key, required this.projectId, required this.profileId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Profile $profileId')),
      body: const Center(child: Text('Здесь будет график высот')),
    );
  }
}
