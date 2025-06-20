import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../pages/auth/login_page.dart';
import '../pages/auth/register_page.dart';
import '../pages/projects/projects_page.dart';
import '../pages/projects/project_map_page.dart';
import '../pages/profiles/profile_list_page.dart';
import '../pages/profiles/profile_detail_page.dart';
import '../pages/settings/settings_page.dart';
import '../pages/not_found_page.dart';
import '../pages/user_profile.dart';

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginPage());

      case '/register':
        return MaterialPageRoute(builder: (_) => const RegisterPage());

      case '/projects':
        return MaterialPageRoute(builder: (_) => const ProjectsPage());

      case '/projectMap':
        final projectId = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (_) => ProjectMapPage(projectId: projectId),
        );

      case '/profileList':
        final projectId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => ProfileListPage(projectId: projectId),
        );

      case '/profileDetail':
        final args = settings.arguments as Map<String, Object?>; // безопасный cast
        return MaterialPageRoute(
          builder: (_) => ProfileDetailPage(
            projectId: args['projectId'] as String,
            profileId:  args['profileId']  as String,
            mapBytes:   args['mapBytes']   as Uint8List?, // может быть null
          ),
        );

      case '/settings':
        return MaterialPageRoute(builder: (_) => const SettingsPage());
      case '/profile':
        return MaterialPageRoute(builder: (_) => const UserProfilePage());
      default:
        return MaterialPageRoute(builder: (_) => const NotFoundPage());
    }
  }
}

