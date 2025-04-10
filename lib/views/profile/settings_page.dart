import 'package:ddnuvem/controllers/user_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Dispositivos"),
        ),
        body: Consumer<UserController>(
          builder: (context, controller, _) {
            return Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text("Logout"),
                  onTap: controller.logout,
                ),
              ],
            );
          }
        ),
      ),
    );
  }
}
