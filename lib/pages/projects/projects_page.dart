// lib/ui/pages/projects/projects_page.dart
import 'package:flutter/material.dart';

class ProjectsPage extends StatelessWidget {
  const ProjectsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Projects')),
      body: const Center(child: Text('Здесь будет список проектов')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/projectMap', arguments: null),
        child: const Icon(Icons.add),
      ),
    );
  }
}
