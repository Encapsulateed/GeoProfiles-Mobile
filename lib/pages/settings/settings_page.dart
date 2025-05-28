import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Simple settings screen with Sync toggle and Log-out action.
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  static const _storage = FlutterSecureStorage();
  static const _syncKey = 'sync_enabled';

  bool _syncEnabled = true;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final v = await _storage.read(key: _syncKey);
    setState(() {
      _syncEnabled = (v == null) ? true : v == 'true';
      _loading = false;
    });
  }

  Future<void> _toggleSync(bool value) async {
    setState(() => _syncEnabled = value);
    await _storage.write(key: _syncKey, value: value.toString());
  }

  Future<void> _logout() async {
    await _storage.delete(key: 'jwt_token');
    await _storage.delete(key: 'refresh_token');
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      bottomNavigationBar: const _BottomNav(selectedIndex: 2),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Sync', style: TextStyle(fontSize: 18)),
                  Switch(
                    value: _syncEnabled,
                    onChanged: _toggleSync,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: _logout,
                style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: const Text('Log Out', style: TextStyle(fontSize: 18, color: Colors.blue)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int selectedIndex;
  const _BottomNav({required this.selectedIndex});
  @override
  Widget build(BuildContext context) => BottomNavigationBar(
    currentIndex: selectedIndex,
    onTap: (i) {
      switch (i) {
        case 0:
          Navigator.pushNamedAndRemoveUntil(context, '/projects', (_) => false);
          break;
        case 1:
          Navigator.pushNamedAndRemoveUntil(context, '/profileList', (_) => false);
          break;
        case 2:
        // Already here
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