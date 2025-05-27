// lib/ui/pages/profiles/profile_list_page.dart
import 'package:flutter/material.dart';

class ProfileListPage extends StatelessWidget {
  final String projectId;
  const ProfileListPage({super.key, required this.projectId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Profiles for $projectId')),
      body: const Center(child: Text('Здесь будет список профилей высот')),
    );
  }
}
