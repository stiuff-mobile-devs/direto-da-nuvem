import 'package:ddnuvem/routes/route_paths.dart';
import 'package:ddnuvem/routes/routes.dart';
import 'package:flutter/material.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: Routes.routes,
      initialRoute: RoutePaths.splash,
      title: "Direto da Nuvem",
    );
  }
}