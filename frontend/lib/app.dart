import 'package:flutter/material.dart';

import 'theme/app_theme.dart';
import 'screens/home/home_screen.dart';
import 'screens/report/report_item_screen.dart';
import 'screens/matches/matches_screen.dart';
import 'screens/my_reports/my_reports_screen.dart';
import 'screens/admin/admin_dashboard_screen.dart';
import 'screens/login/login_screen.dart';

class ReFindApp extends StatelessWidget {
  const ReFindApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ReFind',

      // ReFind's global theme
      theme: AppTheme.lightTheme,

      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/report': (context) => const ReportItemScreen(),
        '/matches': (context) => const MatchesScreen(),
        '/my-reports': (context) => const MyReportsScreen(),
        '/admin': (context) => const AdminDashboardScreen(),
        '/login': (context) => const LoginScreen(),
      },
    );
  }
}