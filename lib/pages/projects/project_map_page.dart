// lib/ui/pages/projects/project_map_page.dart
import 'package:flutter/material.dart';

class ProjectMapPage extends StatelessWidget {
  final String? projectId;
  const ProjectMapPage({super.key, this.projectId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Map: ${projectId ?? ''}')),
      body: const Center(child: Text('Здесь будет карта и создание профиля')),
    );
  }
}
