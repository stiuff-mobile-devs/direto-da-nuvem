import 'package:ddnuvem/controllers/user_controller.dart';
import 'package:ddnuvem/models/user.dart';
import 'package:ddnuvem/views/people/user_create_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PeoplePage extends StatelessWidget {
  const PeoplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SafeArea(child: Scaffold(
          appBar: AppBar(
            title: const Text("Pessoas"),
          ),
        )),
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) {
                    return UserCreatePage(
                        user: User.empty(),
                        onSave: (user) {
                          final messenger = ScaffoldMessenger.of(context);
                          context
                              .read<UserController>()
                              .createUser(user).then((message) {
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
            },
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: const Icon(Icons.add, color: Colors.white,),
          ),
        )
      ],
    );
  }
}