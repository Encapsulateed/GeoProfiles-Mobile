// lib/core/router.dart

import 'package:flutter/material.dart';

import '../pages/auth/login_page.dart';
import '../pages/auth/register_page.dart';
import '../pages/projects/projects_page.dart';
import '../pages/projects/project_map_page.dart';
import '../pages/profiles/profile_list_page.dart';
import '../pages/profiles/profile_detail_page.dart';
import '../pages/settings/settings_page.dart';
import '../pages/not_found_page.dart';

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
      // аргумент: String? projectId (null — новый проект)
        final projectId = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (_) => ProjectMapPage(projectId: projectId),
        );
      case '/profileList':
      // аргумент: String projectId
        final projectId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => ProfileListPage(projectId: projectId),
        );
      case '/profileDetail':
      // аргументы: Map<String, String>{'projectId':..,'profileId':..}
        final args = settings.arguments as Map<String, String>;
        return MaterialPageRoute(
          builder: (_) => ProfileDetailPage(
            projectId: args['projectId']!,
            profileId: args['profileId']!,
          ),
        );
      case '/settings':
        return MaterialPageRoute(builder: (_) => const SettingsPage());
      default:
        return MaterialPageRoute(builder: (_) => const NotFoundPage());
    }
  }
}
