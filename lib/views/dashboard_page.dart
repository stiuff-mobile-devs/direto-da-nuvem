import 'package:ddnuvem/controllers/user_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late UserController userController;

  getDependencies() {
    userController = Provider.of<UserController>(context, listen: true);
  }

  @override
  void initState() {
    getDependencies();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.all(25.0),
              child: Text("Conectado"),
            ),
            Text("idInstaller: ${userController.isInstaller}"),
            const SizedBox(height: 25),
            SizedBox(
              height: 40,
              child: ElevatedButton(
                onPressed: userController.logout,
                child: const Text("Sair"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
