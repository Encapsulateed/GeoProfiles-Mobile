import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../api/api.swagger.dart';
import '../../services/api_service.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  late final ApiService _api;
  UserDto? _user;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _api = context.read<ApiService>();
    _load();
  }

  Future<void> _load() async {
    try {
      final me = await _api.me();
      if (mounted) setState(() => _user = me);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load profile: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_user == null) {
      return const Scaffold(body: Center(child: Text('No profile data')));
    }

    final theme = Theme.of(context);
    final dateReg = _user!.id != null
        ? DateFormat.yMMMEd().format(DateTime.tryParse(_user!.id!) ?? DateTime.now())
        : '-';

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      bottomNavigationBar: const _BottomNav(selected: 1),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            Text(_user!.username ?? '',
                style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 32),
            _readOnlyField(label: 'Name', value: _user!.username ?? ''),
            const SizedBox(height: 16),
            _readOnlyField(label: 'Email', value: _user!.email ?? ''),
            const SizedBox(height: 16),
            _readOnlyField(label: 'Registered', value: dateReg, icon: null),
          ],
        ),
      ),
    );
  }

  Widget _readOnlyField({required String label, required String value, IconData? icon = Icons.edit}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(child: Text(value.isEmpty ? '-' : value, style: const TextStyle(fontSize: 16))),
          if (icon != null) Icon(icon, size: 20, color: Colors.grey.shade600),
        ],
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int selected;
  const _BottomNav({required this.selected});
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: selected,
      onTap: (i) {
        switch (i) {
          case 0:
            Navigator.pushNamedAndRemoveUntil(context, '/projects', (_) => false);
            break;
          case 1:
          // already here
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
  }
}
