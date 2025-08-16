import 'package:ddnuvem/controllers/user_controller.dart';
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
    UserController userController = context.read<UserController>();
    final isSuperAdmin = userController.currentUser!.privileges.isSuperAdmin;

    final pages = [
      const DevicesPage(),
      //const ImagesPage(),
      const GroupsPage(),
      if (isSuperAdmin) const PeoplePage(),
      const SettingsPage(),
    ].whereType<Widget>().toList();

    final tabs = [
      const Tab(icon: Icon(Icons.tv)),
      //const Tab(icon: Icon(Icons.image)),
      const Tab(icon: Icon(Icons.group_work)),
      if (isSuperAdmin) const Tab(icon: Icon(Icons.group)),
      const Tab(icon: Icon(Icons.settings)),
    ].whereType<Tab>().toList();

    return DefaultTabController(
      length: pages.length,
      child: Scaffold(
        body: TabBarView(children: pages),
        bottomNavigationBar: TabBar(tabs: tabs),
      ),
    );
  }
}