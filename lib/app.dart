import 'package:ddnuvem/routes/route_paths.dart';
import 'package:ddnuvem/routes/routes.dart';
import 'package:ddnuvem/views/login_page.dart';
import 'package:flutter/material.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Direto da Nuvem",
      initialRoute: RoutePaths.splash,
      routes: Routes.routes,
      navigatorKey: Routes.navigatorKey,
    );
  }
}