import 'package:ddnuvem/routes/route_paths.dart';
import 'package:ddnuvem/views/dashboard_page.dart';
import 'package:ddnuvem/views/intro_page.dart';
import 'package:ddnuvem/views/login_page.dart';
import 'package:ddnuvem/views/redirection_page.dart';
import 'package:flutter/material.dart';

class Routes {
  static Map<String, Widget Function(BuildContext)> routes = {
    RoutePaths.redirection: (p0) => const RedirectionPage(),
    RoutePaths.login: (p0) => const LoginPage(),
    RoutePaths.dashboard: (p0) => const DashboardPage(),
    RoutePaths.intro: (p0) => const IntroPage(),
  };

  static GlobalKey<NavigatorState>? navigatorKey = GlobalKey<NavigatorState>();
}
