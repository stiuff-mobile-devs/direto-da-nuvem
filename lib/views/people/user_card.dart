import 'package:ddnuvem/controllers/user_controller.dart';
import 'package:ddnuvem/models/user.dart';
import 'package:ddnuvem/views/people/user_create_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserCard extends StatelessWidget {
  final User user;

  const UserCard({super.key, required this.user});

  _pushUpdateUserPage(BuildContext context, UserController controller) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => UserCreatePage(
          user: user,
          onSave: (queue) {
            final messenger = ScaffoldMessenger.of(context);
            controller.updateUser(user)
                .then((message) {
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
