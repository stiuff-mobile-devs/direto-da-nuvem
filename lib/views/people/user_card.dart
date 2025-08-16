import 'package:ddnuvem/controllers/group_controller.dart';
import 'package:ddnuvem/controllers/user_controller.dart';
import 'package:ddnuvem/models/user.dart';
import 'package:ddnuvem/views/people/user_create_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserCard extends StatelessWidget {
  final User user;

  const UserCard({super.key, required this.user});

  _pushUpdateUserPage(BuildContext context, UserController controller) {
    GroupController groupController = context.read<GroupController>();

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => UserCreatePage(
          user: User.copy(user),
          onSave: (updatedUser) {
            final messenger = ScaffoldMessenger.of(context);
            controller.updateUser(updatedUser).then((message) async {
              if (user.privileges.isAdmin && !updatedUser.privileges.isAdmin) {
                await groupController
                    .removeAdministeredGroups(updatedUser.email, updatedUser.updatedBy);
              }
              messenger.showSnackBar(
                SnackBar(
                  content: Text(message),
                ),
              );
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    UserController userController = context.read<UserController>();
    return GestureDetector(
      onTap: () {
        _pushUpdateUserPage(context, userController);
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
}
