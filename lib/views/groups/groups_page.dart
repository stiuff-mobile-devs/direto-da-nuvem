import 'package:ddnuvem/controllers/group_controller.dart';
import 'package:ddnuvem/models/group.dart';
import 'package:ddnuvem/views/groups/group_card.dart';
import 'package:ddnuvem/views/groups/group_create_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GroupsPage extends StatelessWidget {
  const GroupsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SafeArea(
          child: Scaffold(
            appBar: AppBar(
              title: const Text("Grupos"),
            ),
            body: Consumer<GroupController>(builder: (context, controller, _) {
              return ListView(
                children: [
                  ...controller.groups.map((e) => GroupCard(
                        group: e,
                      ))
                ],
              );
            }),
          ),
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) {
                    return GroupCreatePage(
                      group: Group.empty(),
                      onSave: (group) async {
                        await context
                            .read<GroupController>()
                            .createGroup(group);
                      },
                    );
                  },
                ),
              );
            },
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: const Icon(
              Icons.add,
              color: Colors.white,
            ),
          ),
        )
      ],
    );
  }
}
