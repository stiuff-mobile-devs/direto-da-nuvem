import 'package:ddnuvem/controllers/user_controller.dart';
import 'package:ddnuvem/views/people/people_filter_controller.dart';
import 'package:ddnuvem/views/people/user_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PeopleListWidget extends StatelessWidget {
  const PeopleListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<UserController, PeopleFilterController>(
      builder: (context, userController, filterController, _) {
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