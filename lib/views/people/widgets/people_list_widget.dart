import 'package:ddnuvem/controllers/user_controller.dart';
import 'package:ddnuvem/services/connection_service.dart';
import 'package:ddnuvem/views/people/controllers/people_filter_controller.dart';
import 'package:ddnuvem/views/people/widgets/user_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PeopleListWidget extends StatelessWidget {
  const PeopleListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer3<UserController, ConnectionService, PeopleFilterController>(
      builder: (context, userController, connection, filterController, _) {
        final users = userController.getUsersByPrivilegeAndQuery(
            filterController.filters, filterController.searchQuery);
        return SliverPadding(
          padding: const EdgeInsets.only(bottom: 80),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return UserCard(user: users[index]);
              },
              childCount: users.length,
            ),
          ),
        );
      },
    );
  }
}