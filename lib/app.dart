import 'package:ddnuvem/routes/route_paths.dart';
import 'package:ddnuvem/routes/routes.dart';
import 'package:flutter/material.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  initServices(Duration d) async {
  }

  @override
  void initState() {
    super.initState();
  }

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
