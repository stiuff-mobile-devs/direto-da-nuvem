import 'package:ddnuvem/routes/routes.dart';
import 'package:ddnuvem/views/redirection_page.dart';
import 'package:flutter/material.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Direto da Nuvem",
      home: const RedirectionPage(),
      routes: Routes.routes,
      navigatorKey: Routes.navigatorKey,
    );
  }
}
