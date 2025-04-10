import 'package:ddnuvem/controllers/device_controller.dart';
import 'package:ddnuvem/controllers/group_controller.dart';
import 'package:ddnuvem/models/group.dart';
import 'package:ddnuvem/routes/route_paths.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GroupCard extends StatelessWidget {
  const GroupCard({super.key, required this.group});

  final Group group;

  @override
  Widget build(BuildContext context) {
    GroupController groupController = Provider.of<GroupController>(context, listen: false);
    return InkWell(
      onTap: () {
        groupController.selectGroup(group);
        Navigator.of(context).pushNamed(RoutePaths.group);
      },
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Text(
            group.name,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              ),
          ),
          const SizedBox(height: 8),
          Text(
            group.description,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
            Row(
              children: [
              const Icon(Icons.tv, color: Colors.blue),
              const SizedBox(width: 8),
              Consumer<DeviceController>(
                builder: (context, controller, _) {
                  return Text(
                    '${controller.numberOfDevicesOnGroup(group.id??"")} Dispositivos',
                    style: Theme.of(context).textTheme.bodyLarge,
                  );
                }
              ),
              ],
            ),
            Row(
              children: [
              const Icon(Icons.group, color: Colors.green),
              const SizedBox(width: 8),
              Text(
                '${group.admins?.length ?? 0} Admins',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              ],
            ),
            ],
          ),
          ],
        ),
        ),
      ),
    );
  }
}