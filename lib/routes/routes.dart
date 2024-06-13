import 'package:ddnuvem/routes/route_paths.dart';
import 'package:ddnuvem/views/login_page.dart';
import 'package:ddnuvem/views/splash_page.dart';
import 'package:flutter/material.dart';

class Routes {
  static Map<String, Widget Function(BuildContext)> routes = {
    RoutePaths.splash:(p0) => const SplashPage(),
    RoutePaths.login:(p0) => const LoginPage(),
    RoutePaths.dashboard:(p0) => const LoginPage(),
  }; 
}