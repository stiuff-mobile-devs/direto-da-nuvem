import 'package:ddnuvem/routes/route_paths.dart';
import 'package:ddnuvem/views/dashboard_page.dart';
import 'package:ddnuvem/views/intro_page.dart';
import 'package:ddnuvem/views/login_page.dart';
import 'package:ddnuvem/views/queues/queue_view_page.dart';
import 'package:ddnuvem/views/redirection_page.dart';
import 'package:flutter/material.dart';

import '../views/groups/group_create_page.dart';

class Routes {
  static Map<String, Widget Function(BuildContext)> routes = {
    RoutePaths.redirection: (p0) => const RedirectionPage(),
    RoutePaths.login: (p0) => const LoginPage(),
    RoutePaths.dashboard: (p0) => const DashboardPage(),
    RoutePaths.intro: (p0) => const IntroPage(),
    RoutePaths.queue: (p0) => const QueueViewPage(),
    RoutePaths.group: (p0) => const GroupCreatePage(),

  };

  static GlobalKey<NavigatorState>? navigatorKey = GlobalKey<NavigatorState>();
}
