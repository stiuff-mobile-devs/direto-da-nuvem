import 'package:ddnuvem/controllers/user_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UnregisteredDeviceErrorPage extends StatefulWidget {
  const UnregisteredDeviceErrorPage({super.key});

  @override
  State<UnregisteredDeviceErrorPage> createState() =>
      _UnregisteredDeviceErrorPageState();
}

class _UnregisteredDeviceErrorPageState
    extends State<UnregisteredDeviceErrorPage> {
  bool showView = true;

  final List<String> assetImages = [
    'assets/001.png',
    'assets/002.png',
    'assets/003.png',
    'assets/004.png',
  ];

  @override
  Widget build(BuildContext context) {
    if (showView) {
      return GestureDetector(
        onTap: () {
          setState(() {
            showView = false;
          });
        },
        child: PageView(
          children: assetImages.map((path) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Image.asset(path, fit: BoxFit.contain),
              ),
            );
          }).toList(),
        ),
      );
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () {
            setState(() {
              showView = true;
            });
          },
          child: const Text("Play"),
        ),
        ElevatedButton(
          onPressed: () {
            context.read<UserController>().logout();
          },
          child: const Text("Sair"),
        ),
      ],
    );
  }
}
