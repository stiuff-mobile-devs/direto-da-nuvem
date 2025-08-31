import 'package:ddnuvem/views/people/widgets/people_filter_drawer.dart';
import 'package:ddnuvem/views/people/widgets/search_bar_widget.dart';
import 'package:flutter/material.dart';

class PeopleAppBarWidget extends StatelessWidget {
  const PeopleAppBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      title: const Text("Pessoas"),
      actions: [
        IconButton(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              builder: (context) {
                return const PeopleFilterDrawer();
              });
          },
          icon: const Icon(Icons.filter_list))
      ],
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(56),
        child: PeopleSearchBar()
      )
    );
  }
}