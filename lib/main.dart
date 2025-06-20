import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';

import 'core/env.dart';
import 'core/logger.dart';
import 'core/router.dart';
import 'services/api_service.dart';
import 'package:intl/date_symbol_data_local.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  setupDartLogging();
  logger.i('App initializing, API = ${Env.apiBaseUrl}');

  const storage = FlutterSecureStorage();
  final jwt = await storage.read(key: 'jwt_token');

  final apiService = ApiService.create(baseUrl: Env.apiBaseUrl);

  runApp(
    Provider<ApiService>.value(
      value: apiService,
      child: MyApp(initialRoute: jwt == null ? '/register' : '/projects'),
    ),
  );
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GeoProfiles',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: initialRoute,
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}