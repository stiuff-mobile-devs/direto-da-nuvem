
import 'package:ddnuvem/models/device.dart';
import 'package:flutter/material.dart';

class DeviceCard extends StatelessWidget {
  final Device device;

  const DeviceCard({super.key, required this.device});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              device.description,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text("Locale: ${device.locale}"),
            Text("Group ID: ${device.groupId}"),
            Text("Registered By: ${device.registeredBy}"),
            if (device.brand != null) Text("Brand: ${device.brand}"),
            if (device.model != null) Text("Model: ${device.model}"),
            if (device.product != null) Text("Product: ${device.product}"),
            if (device.device != null) Text("Device: ${device.device}"),
            const SizedBox(height: 8),
            Text(
              "Created At: ${device.createdAt.toLocal()}",
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            Text(
              "Updated At: ${device.updatedAt.toLocal()}",
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}