import 'package:ddnuvem/controllers/user_controller.dart';
import 'package:ddnuvem/utils/theme.dart';
import 'package:ddnuvem/views/devices/devices_page.dart';
import 'package:ddnuvem/views/groups/groups_page.dart';
import 'package:ddnuvem/views/people/people_page.dart';
import 'package:ddnuvem/views/profile/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    int startIndex = 0;

    try {
      final obj = ModalRoute.of(context)?.settings.arguments;
      Map<dynamic,dynamic>? map = obj != null ? obj as Map : null;
      if (map != null) {
        startIndex = map['startIndex'] ?? 0;
      }
    } catch (e) {
      debugPrint(e.toString());
    }

    final isSuperAdmin = context.read<UserController>()
        .isCurrentUserSuperAdmin();

    final pages = [
      const DevicesPage(),
      const GroupsPage(),
      //const ImagesPage(),
      if (isSuperAdmin) const PeoplePage(),
      const SettingsPage(),
    ].whereType<Widget>().toList();

    final tabs = [
      const Tab(icon: Icon(Icons.tv)),
      const Tab(icon: Icon(Icons.group_work)),
      //const Tab(icon: Icon(Icons.image)),
      if (isSuperAdmin) const Tab(icon: Icon(Icons.group)),
      const Tab(icon: Icon(Icons.settings)),
    ].whereType<Tab>().toList();

    return DefaultTabController(
      initialIndex: startIndex,
      length: pages.length,
      child: Scaffold(
        body: TabBarView(children: pages),
        bottomNavigationBar: TabBar(
          tabs: tabs,
          labelColor: AppTheme.primaryBlue,
          indicatorColor: AppTheme.primaryBlue,
        ),
      ),
    );
  }
}