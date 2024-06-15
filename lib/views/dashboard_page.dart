import 'package:ddnuvem/controllers/user_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  Widget build(BuildContext context) {
    // Access UserController directly within the build method
    final userController = Provider.of<UserController>(context, listen: true);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Dashboard"),
            const SizedBox(height: 25),
            SizedBox(
              height: 40,
              child: ElevatedButton(
                onPressed: userController.logout, // Now safe to use
                child: const Text("Sair"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}