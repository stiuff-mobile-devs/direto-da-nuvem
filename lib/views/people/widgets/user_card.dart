import 'package:ddnuvem/controllers/group_controller.dart';
import 'package:ddnuvem/controllers/user_controller.dart';
import 'package:ddnuvem/models/user.dart';
import 'package:ddnuvem/services/connection_service.dart';
import 'package:ddnuvem/utils/no_connection_dialog.dart';
import 'package:ddnuvem/views/people/user_create_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserCard extends StatelessWidget {
  final User user;

  const UserCard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final connection = context.read<ConnectionService>();

    return GestureDetector(
      onTap: () {
        connection.connectionStatus
          ? _pushUpdateUserPage(context)
          : noConnectionDialog(context).show();
      },
      child: Card(
        elevation: 4,
        margin: const EdgeInsets.all(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.name.isEmpty ? "Usuário não autenticado" : user.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(user.email),
              Text("Privilégios: ${user.privileges.toString()}"),
            ],
          ),
        ),
      ),
    );
  }

  _pushUpdateUserPage(BuildContext context) {
    UserController userController = context.read<UserController>();
    GroupController groupController = context.read<GroupController>();
    final messenger = ScaffoldMessenger.of(context);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => UserCreatePage(
          user: User.copy(user),
          onSave: (updatedUser) async {
            userController.updateUser(updatedUser).then((message) {
              messenger.showSnackBar(
                SnackBar(
                  content: Text(message),
                ),
              );
            });

            if (user.privileges.isAdmin && !updatedUser.privileges.isAdmin) {
              await groupController
                  .removeAdministeredGroups(updatedUser.email,
                  updatedUser.updatedBy);
            }
          },
          onDelete: (user) {
            if (user.privileges.isAdmin) {
              groupController.removeAdministeredGroups(user.email,
                  userController.currentUser!.id);
            }
            userController.deleteUser(user).then((message) {
              messenger.showSnackBar(
                SnackBar(
                  content: Text(message),
                ),
              );
            });
            Navigator.pop(context);
          },
        ),
      ),
    );
  }
}
