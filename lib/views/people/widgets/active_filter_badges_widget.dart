import 'package:ddnuvem/views/people/people_filter_controller.dart';
import 'package:ddnuvem/views/people/widgets/privilege_filter_badge.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ActiveFilterBadgesWidget extends StatelessWidget {
  const ActiveFilterBadgesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(child: Consumer<PeopleFilterController>(
      builder: (context, value, child) {
      return Wrap(
        alignment: WrapAlignment.center,
        children: value.filters
          .map((e) => PrivilegeFilterBadge(
            filter: e,
            onAdd: value.addFilter,
            onRemove: value.removeFilter))
          .toList());
        }
      )
    );
  }
}