import 'package:ddnuvem/controllers/user_controller.dart';
import 'package:ddnuvem/models/user.dart';
import 'package:ddnuvem/views/people/people_filter_controller.dart';
import 'package:ddnuvem/views/people/people_filter_drawer.dart';
import 'package:ddnuvem/views/people/privilege_filter_badge.dart';
import 'package:ddnuvem/views/people/user_card.dart';
import 'package:ddnuvem/views/people/user_create_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PeoplePage extends StatelessWidget {
  const PeoplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: CustomScrollView(
        slivers: [
          SliverAppBar(title: const Text("Pessoas"), actions: [
            IconButton(
                onPressed: () {
                  showModalBottomSheet(
                      context: context,
                      builder: (context) {
                        return const PeopleFilterDrawer();
                      });
                },
                icon: const Icon(Icons.filter_list))
          ]),
          SliverToBoxAdapter(child: Consumer<PeopleFilterController>(
              builder: (context, value, child) {
            return Wrap(
                alignment: WrapAlignment.center,
                children: value.filters
                    .map((e) => PrivilegeFilterBadge(
                        filter: e,
                        onAdd: value.addFilter,
                        onRemove: value.removeFilter))
                    .toList());
          })),
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              return Consumer2<UserController, PeopleFilterController>(
                builder: (context, userController, filterController, _) {
                  final users = userController.getUsersByPrivilege(filterController.filters);
                  if (index >= users.length) {
                    return const SizedBox.shrink();
                  }
                  return UserCard(user: users[index]);
                }
              );
            }, 
            childCount: context.watch<UserController>().users.length)
          ),
        ],
      )
    ),
    floatingActionButton: FloatingActionButton(
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) {
              return UserCreatePage(
                user: User.empty(),
                onSave: (user) {
                  final messenger = ScaffoldMessenger.of(context);
                  context.read<UserController>().createUser(user).then((msg) {
                    messenger.showSnackBar(SnackBar(content: Text(msg)));
                  });
                },
              );
            },
          ),
        );
      },
      backgroundColor: Theme.of(context).colorScheme.primary,
      child: const Icon(Icons.add, color: Colors.white),
    ),
    );
  }
}
