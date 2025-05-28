import 'package:flutter/material.dart';

class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off_rounded,
                    size: 120, color: theme.colorScheme.primary.withOpacity(.6)),
                const SizedBox(height: 24),
                Text('404',
                    style: theme.textTheme.displayMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(
                  'Oops! The page you’re looking for doesn’t exist.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: 180,
                  height: 48,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.home_outlined),
                    label: const Text('Go Home'),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => Navigator.pushNamedAndRemoveUntil(
                        context, '/projects', (route) => false),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
