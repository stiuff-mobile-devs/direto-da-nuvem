import 'package:ddnuvem/views/devices/devices_page.dart';
import 'package:ddnuvem/views/groups/groups_page.dart';
import 'package:ddnuvem/views/images/images_page.dart';
import 'package:ddnuvem/views/profile/settings_page.dart';
import 'package:flutter/material.dart';

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const DefaultTabController(
      length: 3,
      child: Scaffold(
        body: TabBarView(children: [
          DevicesPage(),
          //ImagesPage(),
          GroupsPage(),
          // PeoplePage(),
          SettingsPage(),
        ]),
        bottomNavigationBar: TabBar(
          tabs: [
            Tab(
              icon: Icon(Icons.tv),
            ),
            //Tab(
            //  icon: Icon(Icons.image),
            //),
            Tab(
              icon: Icon(Icons.group_work),
            ),
            // Tab(icon: Icon(Icons.group), ),
            Tab(
              icon: Icon(Icons.settings),
            ),
          ],
        ),
      ),
    );
  }
}
