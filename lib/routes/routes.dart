import 'package:ddnuvem/routes/route_paths.dart';
import 'package:ddnuvem/views/groups/group_page.dart';
import 'package:ddnuvem/views/queues/queue_edit_page.dart';
import 'package:flutter/material.dart';
import '../views/groups/group_create_page.dart';

class Routes {
  static Map<String, Widget Function(BuildContext)> routes = {
    RoutePaths.groupCreate: (p0) => GroupCreatePage(),
    RoutePaths.group: (p0) => const GroupPage(),
    RoutePaths.queueEdit: (p0) => const QueueEditPage(),
  };

  static GlobalKey<NavigatorState>? navigatorKey = GlobalKey<NavigatorState>();
}
