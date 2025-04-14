import 'package:ddnuvem/controllers/device_controller.dart';
import 'package:ddnuvem/models/device.dart';
import 'package:ddnuvem/views/devices/device_card.dart';
import 'package:ddnuvem/views/devices/devices_filter_controller.dart';
import 'package:ddnuvem/views/devices/filter_badge.dart';
import 'package:ddnuvem/views/devices/group_filter_drawer.dart';
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
                return Consumer2<DeviceController, DevicesFilterController>(
                  builder: (context, deviceController, filterController, _) {
                    List<Device> devices = deviceController
                        .listDevicesInGroups(filterController.filters.map((e) => e.id!).toSet());
                    if (index >= devices.length) {
                      return const SizedBox.shrink();
                    }
                    return DeviceCard(device: devices[index]);
                  },
                );
              },
              childCount: context.watch<DeviceController>().devices.length,
            ),
          ),
        ],
      ),
    );
  }
}
