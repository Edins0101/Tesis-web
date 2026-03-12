import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'core/constants/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/auth_page.dart';
import 'features/home/presentation/pages/access_detail_page.dart';
import 'features/home/presentation/pages/access_list_page.dart';
import 'features/home/presentation/pages/dashboard_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _loadEnv();
  runApp(const DashboardApp());
}

Future<void> _loadEnv() async {
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    // Ignore: fallback values are handled in ApiConfig.
  }
}

class DashboardApp extends StatelessWidget {
  const DashboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Dashboard de Accesos',
      theme: AppTheme.light,
      initialRoute: AppRoutes.login,
      routes: {
        AppRoutes.login: (_) => const AuthPage(),
        AppRoutes.dashboard: (_) => const DashboardPage(),
        AppRoutes.accessList: (_) => const AccessListPage(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == AppRoutes.accessDetail) {
          final accessId = settings.arguments as int?;
          if (accessId == null) {
            return MaterialPageRoute<void>(
              builder: (_) => const AccessListPage(),
            );
          }
          return MaterialPageRoute<void>(
            builder: (_) => AccessDetailPage(accessId: accessId),
          );
        }
        return null;
      },
    );
  }
}
