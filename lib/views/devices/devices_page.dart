import 'package:ddnuvem/controllers/device_controller.dart';
import 'package:ddnuvem/views/devices/device_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DevicesPage extends StatelessWidget {
  const DevicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Scaffold(
      appBar: AppBar(
        title: const Text("Dispositivos"),
      ),
      body: Consumer<DeviceController>(
        builder: (context, controller, _) {
          return ListView(
            children: [
              ...controller.devices.map((e) => DeviceCard(device: e,))
            ],
          );
        }
      )
    ));
  }
}