import 'package:ddnuvem/controllers/group_controller.dart';
import 'package:ddnuvem/views/devices/devices_filter_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GroupFilterDrawer extends StatelessWidget {
  const GroupFilterDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final adminGroups = context
        .read<GroupController>()
        .groups;

    return Column(
      children: [
        const SizedBox(height: 16),
        const Text(
          "Filtrar por grupo",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            itemCount: adminGroups
                .length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(adminGroups[index].name),
                onTap: () {
                  context.read<DevicesFilterController>().addFilter(context
                      .read<GroupController>().groups[index]);
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
