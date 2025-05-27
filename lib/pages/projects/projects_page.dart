import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../api/api.swagger.dart';
import '../../services/api_service.dart';

class ProjectsPage extends StatefulWidget {
  const ProjectsPage({Key? key}) : super(key: key);

  @override
  State<ProjectsPage> createState() => _ProjectsPageState();
}

class _ProjectsPageState extends State<ProjectsPage> {
  late final ApiService _api;
  List<ProjectSummaryDto> _projects = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _api = context.read<ApiService>();
    _fetchProjects();
  }

  Future<void> _fetchProjects() async {
    setState(() => _loading = true);
    try {
      final dto = await _api
          .getProjectsList()
          .timeout(const Duration(seconds: 10));
      setState(() => _projects = dto.projects ?? []);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Не удалось загрузить проекты: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _showCreateProjectDialog() async {
    final nameCtrl = TextEditingController();
    bool saving = false;

    final created = await showDialog<ProjectDto>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateDialog) => AlertDialog(
          title: const Text('New Project'),
          content: TextField(
            controller: nameCtrl,
            decoration: const InputDecoration(labelText: 'Name'),
          ),
          actions: [
            TextButton(
              onPressed: saving ? null : () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: saving
                  ? null
                  : () async {
                final name = nameCtrl.text.trim();
                if (name.isEmpty) return;
                setStateDialog(() => saving = true);
                try {
                  final p = await _api
                      .createProject(name: name)
                      .timeout(const Duration(seconds: 10));
                  if (!ctx.mounted) return;
                  Navigator.pop(ctx, p);
                } catch (e) {
                  setStateDialog(() => saving = false);
                  if (ctx.mounted) {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      SnackBar(content: Text('Ошибка: $e')),
                    );
                  }
                }
              },
              child: saving
                  ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
                  : const Text('Create'),
            ),
          ],
        ),
      ),
    );

    if (created != null) {
      // просто перезагружаем список — гарантированно актуально
      await _fetchProjects();
    }
  }

  String _formatDate(String? iso) {
    if (iso == null) return '';
    try {
      final dt = DateTime.parse(iso);
      return DateFormat('d MMM yyyy').format(dt);
    } catch (_) {
      return iso;
    }
  }

  Widget _buildProjectTile(ProjectSummaryDto p) => ListTile(
    title: Text(p.name ?? '—', style: const TextStyle(fontSize: 18)),
    subtitle: Text('Created ${_formatDate(p.createdAt.toString())}'),
    onTap: () => Navigator.pushNamed(context, '/projectMap', arguments: p.id),
  );

  BottomNavigationBar _bottomBar() => BottomNavigationBar(
    currentIndex: 0,
    onTap: (i) {
      switch (i) {
        case 0:
          break;
        case 1:
          Navigator.pushNamed(context, '/profile');
          break;
        case 2:
          Navigator.pushNamed(context, '/settings');
          break;
      }
    },
    items: const [
      BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
      BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
      BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), label: 'Settings'),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Projects')),
      bottomNavigationBar: _bottomBar(),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateProjectDialog,
        backgroundColor: const Color(0xFF2979FF),
        child: const Icon(Icons.add),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _fetchProjects,
        child: _projects.isEmpty
            ? ListView(
          children: const [
            SizedBox(height: 120),
            Center(
              child: Text('No projects yet. Tap + to create'),
            ),
          ],
        )
            : ListView.separated(
          itemCount: _projects.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (_, i) => _buildProjectTile(_projects[i]),
        ),
      ),
    );
  }
}
