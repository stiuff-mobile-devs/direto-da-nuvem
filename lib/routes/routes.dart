import 'package:ddnuvem/routes/route_paths.dart';
import 'package:ddnuvem/views/groups/group_page.dart';
import 'package:ddnuvem/views/admin/admin_page.dart';
import 'package:flutter/material.dart';

class Routes {
  static Map<String, Widget Function(BuildContext)> routes = {
    RoutePaths.group: (p0) => const GroupPage(),
    RoutePaths.admin: (p1) => const AdminPage(),
  };

  static GlobalKey<NavigatorState>? navigatorKey = GlobalKey<NavigatorState>();
}
