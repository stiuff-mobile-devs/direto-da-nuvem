import 'package:ddnuvem/controllers/group_controller.dart';
import 'package:ddnuvem/controllers/queue_controller.dart';
import 'package:ddnuvem/controllers/user_controller.dart';
import 'package:ddnuvem/models/group.dart';
import 'package:ddnuvem/services/connection_service.dart';
import 'package:ddnuvem/utils/custom_snackbar.dart';
import 'package:ddnuvem/utils/no_connection_dialog.dart';
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
    bool isSuperAdmin = userController.isCurrentUserSuperAdmin();

    return Stack(
      children: [
        SafeArea(
          child: Scaffold(
            appBar: AppBar(
              title: const Text("Grupos"),
            ),
            body: Consumer2<GroupController, QueueController>(
                builder: (context, groupController, queueController, _) {
              return ListView(
                padding: const EdgeInsets.only(bottom: 80),
                children: [
                  ...groupController.getAdminGroups(isSuperAdmin).map(
                      (e) => GroupCard(group: e),
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
          child: Consumer<ConnectionService>(builder: (context, connection, _) {
            return FloatingActionButton(
              onPressed: () {
                connection.connectionStatus
                  ? _createGroupButtonPush(context)
                  : noConnectionDialog(context).show();
              },
              backgroundColor: AppTheme.primaryBlue,
              child: const Icon(
                Icons.add,
                color: Colors.white,
              ),
            );
          })
        )
      ],
    );
  }

  _createGroupButtonPush(BuildContext context) {
    final userController = context.read<UserController>();
    final snackBar = CustomSnackbar(context);
    String text, type;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return GroupCreatePage(
            group: Group.empty(),
            onSave: (group) async {
              try {
                await context.read<GroupController>().createGroup(group);
                await userController.grantAdminPrivilege(group.admins);
                text = "Grupo criado com sucesso!";
                type = "success";
              } catch (e) {
                text = e.toString();
                type = "error";
              }
              snackBar.build(text, type);
              if (context.mounted) Navigator.of(context).pop();
            }
          );
        },
      ),
    );
  }
}
