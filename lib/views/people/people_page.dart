import 'package:ddnuvem/controllers/user_controller.dart';
import 'package:ddnuvem/models/user.dart';
import 'package:ddnuvem/views/people/user_card.dart';
import 'package:ddnuvem/views/people/user_create_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PeoplePage extends StatelessWidget {
  const PeoplePage({super.key});

  _pushCreateUserPage(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return UserCreatePage(
            user: User.empty(),
            onSave: (user) {
              final messenger = ScaffoldMessenger.of(context);
              context.read<UserController>().createUser(user).then((message) {
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(message),
                  ),
                );
              });
            }
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SafeArea(
            child: Scaffold(
              appBar: AppBar(
                title: const Text("Pessoas"),
              ),
              body: Consumer<UserController>(builder: (context, controller, _) {
                return ListView(
                  padding: const EdgeInsets.only(bottom: 80),
                  children: [
                    ...controller.users.map((e) => UserCard(user: e)),
                  ],
                );
              }),
            )
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            onPressed: () {
              _pushCreateUserPage(context);
            },
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: const Icon(Icons.add, color: Colors.white,),
          ),
        )
      ],
    );
  }
}