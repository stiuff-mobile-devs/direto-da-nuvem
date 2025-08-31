import 'package:ddnuvem/controllers/user_controller.dart';
import 'package:ddnuvem/models/user.dart';
import 'package:ddnuvem/services/connection_service.dart';
import 'package:ddnuvem/utils/theme.dart';
import 'package:ddnuvem/views/people/widgets/active_filter_badges_widget.dart';
import 'package:ddnuvem/views/people/widgets/people_app_bar_widget.dart';
import 'package:ddnuvem/views/people/widgets/people_list_widget.dart';
import 'package:ddnuvem/views/people/user_create_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PeoplePage extends StatelessWidget {
  const PeoplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const SafeArea(
        child: CustomScrollView(
          slivers: [
            PeopleAppBarWidget(),
            ActiveFilterBadgesWidget(),
            PeopleListWidget(),
          ],
        )
      ),
      floatingActionButton: Consumer<ConnectionService> (
        builder: (context, connection, _) {
          return FloatingActionButton(
            onPressed: () {
              connection.connectionStatus
                ? _pushCreateUserPage(context)
                : connection.noConnectionDialog(context).show();
            },
            backgroundColor: AppTheme.primaryBlue,
            child: const Icon(Icons.add, color: Colors.white),
          );
        },
      )
    );
  }

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
}
