import 'package:ddnuvem/controllers/group_controller.dart';
import 'package:ddnuvem/controllers/user_controller.dart';
import 'package:ddnuvem/models/user.dart';
import 'package:ddnuvem/services/connection_service.dart';
import 'package:ddnuvem/utils/custom_snackbar.dart';
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
    final userController = context.read<UserController>();
    final groupController = context.read<GroupController>();
    final snackBar = CustomSnackbar(context);
    String text;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => UserCreatePage(
          user: User.copy(user),
          onSave: (updatedUser) async {
            try {
              await userController.updateUser(updatedUser);
              if (user.privileges.isAdmin && !updatedUser.privileges.isAdmin) {
                await groupController
                    .removeAdminFromGroups(updatedUser.email);
              }
              text = "Usuário atualizado com sucesso!";
            } catch (e) {
              text = e.toString();
            }
            snackBar.buildMessage(text);
            if (context.mounted) Navigator.pop(context);
          },
          onDelete: (user) async {
            try {
              if (user.privileges.isAdmin) {
                await groupController.removeAdminFromGroups(user.email);
              }
              await userController.deleteUser(user);
              text = "Usuário excluído com sucesso!";
            } catch (e) {
              text = e.toString();
            }
            snackBar.buildMessage(text);
            if (context.mounted) Navigator.pop(context);
          },
        ),
      ),
    );
  }
}
