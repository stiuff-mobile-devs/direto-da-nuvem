import 'package:ddnuvem/controllers/user_controller.dart';
import 'package:ddnuvem/models/user.dart';
import 'package:ddnuvem/services/connection_service.dart';
import 'package:ddnuvem/utils/custom_snackbar.dart';
import 'package:ddnuvem/utils/no_connection_dialog.dart';
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
                : noConnectionDialog(context).show();
            },
            backgroundColor: AppTheme.primaryBlue,
            child: const Icon(Icons.add, color: Colors.white),
          );
        },
      )
    );
  }

  _pushCreateUserPage(BuildContext context) {
    String text;
    final snackBar = CustomSnackbar(context);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return UserCreatePage(
            user: User.empty(),
            onSave: (user) async {
              try {
                await context.read<UserController>().createUser(user);
                text = "Usuário criado com sucesso!";
              } catch (e) {
                text = e.toString();
              }
              snackBar.buildMessage(text);
              if (context.mounted) Navigator.of(context).pop();
            }
          );
        },
      ),
    );
  }
}
