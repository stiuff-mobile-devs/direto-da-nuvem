import 'package:ddnuvem/controllers/group_controller.dart';
import 'package:ddnuvem/controllers/user_controller.dart';
import 'package:ddnuvem/models/group.dart';
import 'package:ddnuvem/utils/theme.dart';
import 'package:ddnuvem/views/groups/group_card.dart';
import 'package:ddnuvem/views/groups/group_create_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GroupsPage extends StatelessWidget {
  const GroupsPage({super.key});

  @override
  Widget build(BuildContext context) {
    UserController userController = context.read<UserController>();
    bool isSuperAdmin = userController.currentUser!.privileges.isSuperAdmin;

    return Stack(
      children: [
        SafeArea(
          child: Scaffold(
            appBar: AppBar(
              title: const Text("Grupos"),
            ),
            body: Consumer<GroupController>(builder: (context, controller, _) {
              return ListView(
                padding: const EdgeInsets.only(bottom: 80),
                children: [
                  ...controller.getAdminGroups(isSuperAdmin).map(
                    (e) => GroupCard(
                      group: e,
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
        !isSuperAdmin ? const SizedBox.shrink() :
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
                        final messenger = ScaffoldMessenger.of(context);
                        context.read<GroupController>()
                            .createGroup(group).then((message) {
                              messenger.showSnackBar(
                              SnackBar(
                                content: Text(message),
                              ),
                            );
                        });
                        await userController.updateGroupAdmins(group.admins);
                      }
                    );
                  },
                ),
              );
            },
            backgroundColor: AppTheme.primaryBlue,
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
