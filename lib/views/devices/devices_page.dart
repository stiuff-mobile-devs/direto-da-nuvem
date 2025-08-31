import 'package:ddnuvem/controllers/device_controller.dart';
import 'package:ddnuvem/controllers/group_controller.dart';
import 'package:ddnuvem/controllers/user_controller.dart';
import 'package:ddnuvem/services/connection_service.dart';
import 'package:ddnuvem/views/devices/widgets/device_card.dart';
import 'package:ddnuvem/views/devices/devices_filter_controller.dart';
import 'package:ddnuvem/views/devices/widgets/filter_badge.dart';
import 'package:ddnuvem/views/devices/widgets/group_filter_drawer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DevicesPage extends StatelessWidget {
  const DevicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: const Text("Dispositivos"),
            actions: [
              IconButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (context) {
                      return const GroupFilterDrawer();
                    },
                  );
                },
                icon: const Icon(Icons.filter_list),
              )
            ],
          ),
          SliverToBoxAdapter(
            child: Consumer<DevicesFilterController>(
              builder: (context, value, child) {
                return Wrap(
                  alignment: WrapAlignment.center,
                  children: value.filters
                      .map(
                        (e) => FilterBadge(
                          filter: e,
                          onAdd: value.addFilter,
                          onRemove: value.removeFilter,
                        ),
                      )
                      .toList(),
                );
              },
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return Consumer4<DeviceController, GroupController,
                    DevicesFilterController, ConnectionService>(
                  builder: (context, deviceController, groupController,
                      filterController, connectionService, _) {
                    UserController userController =
                        context.read<UserController>();
                    final adminGroups = groupController
                        .getAdminGroups(userController
                        .isCurrentUserSuperAdmin());
                    final adminGroupIds = adminGroups.map((g) => g.id).toSet();

                    // Use filters if any, otherwise use all admin group IDs
                    final filterGroupIds = filterController.filters.isNotEmpty
                        ? filterController.filters.map((g) => g.id).toSet()
                        : adminGroupIds;

                    final devices =
                        deviceController.listDevicesInGroups(filterGroupIds);

                    if (index >= devices.length) {
                      return const SizedBox.shrink();
                    }

                    return DeviceCard(device: devices[index]);
                  },
                );
              },
              // Use the filtered device count for childCount!
              childCount: () {
                final filterController =
                    context.watch<DevicesFilterController>();
                final deviceController = context.watch<DeviceController>();
                final groupController = context.watch<GroupController>();
                final userController = context.watch<UserController>();

                final adminGroups =
                    groupController.getAdminGroups(userController
                        .isCurrentUserSuperAdmin());
                final adminGroupIds = adminGroups.map((g) => g.id).toSet();

                final filterGroupIds = filterController.filters.isNotEmpty
                    ? filterController.filters.map((g) => g.id).toSet()
                    : adminGroupIds;

                return deviceController
                    .listDevicesInGroups(filterGroupIds)
                    .length;
              }(),
            ),
          ),
        ],
      ),
    );
  }
}
