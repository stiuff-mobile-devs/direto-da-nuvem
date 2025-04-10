import 'package:ddnuvem/controllers/device_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ImagesPage extends StatelessWidget {
  const ImagesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Scaffold(
      appBar: AppBar(
        title: const Text("Imagens"),
      ),
      body: Consumer<DeviceController>(
        builder: (context, controller, _) {
          return ListView(
            children: [
              ...controller.devices.map((e) => Text(e.description))
            ],
          );
        }
      )
    ));
  }
}