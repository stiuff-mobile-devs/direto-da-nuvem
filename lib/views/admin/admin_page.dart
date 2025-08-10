import 'package:ddnuvem/controllers/user_controller.dart';
import 'package:ddnuvem/views/devices/devices_page.dart';
import 'package:ddnuvem/views/groups/groups_page.dart';
import 'package:ddnuvem/views/images/images_page.dart';
import 'package:ddnuvem/views/people/people_page.dart';
import 'package:ddnuvem/views/profile/settings_page.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    UserController userController = context.read<UserController>();

    final pages = [
      const DevicesPage(),
      const ImagesPage(),
      const GroupsPage(),
      if (userController.isSuperAdmin) const PeoplePage(),
      const SettingsPage(),
    ];

    final tabs = [
      const Tab(icon: Icon(Icons.tv)),
      const Tab(icon: Icon(Icons.image)),
      const Tab(icon: Icon(Icons.group_work)),
      if (userController.isSuperAdmin) const Tab(icon: Icon(Icons.group)),
      const Tab(icon: Icon(Icons.settings)),
    ];

    return DefaultTabController(
      length: 5,
      child: Scaffold(
        body: TabBarView(children: pages),
        bottomNavigationBar: TabBar(tabs: tabs),
      ),
    );
  }
}