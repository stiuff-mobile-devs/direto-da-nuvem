import 'package:ddnuvem/controllers/device_controller.dart';
import 'package:ddnuvem/controllers/group_controller.dart';
import 'package:ddnuvem/controllers/user_controller.dart';
import 'package:ddnuvem/models/device.dart';
import 'package:ddnuvem/services/connection_service.dart';
import 'package:ddnuvem/utils/custom_dialog.dart';
import 'package:ddnuvem/utils/custom_snackbar.dart';
import 'package:ddnuvem/utils/data_utils.dart';
import 'package:ddnuvem/utils/no_connection_dialog.dart';
import 'package:ddnuvem/utils/theme.dart';
import 'package:ddnuvem/views/devices/register_device_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DeviceCard extends StatelessWidget {
  final Device device;

  const DeviceCard({super.key, required this.device});

  _pushUpdateDevicePage(BuildContext context) {
    Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => RegisterDevicePage(device: device)));
  }

  @override
  Widget build(BuildContext context) {
    final connectionService = context.read<ConnectionService>();
    return GestureDetector(
      onTap: () {
        if (context.read<UserController>().isCurrentUserSuperAdmin()) {
          connectionService.connectionStatus
              ? _pushUpdateDevicePage(context)
              : noConnectionDialog(context).show();
        }
      },
      onLongPress: () {
        if (context.read<UserController>().isCurrentUserSuperAdmin()) {
          connectionService.connectionStatus
              ? _showDeleteDialog(context)
              : noConnectionDialog(context).show();
        }
      },
      child: Card(
        elevation: 4,
        margin: const EdgeInsets.all(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                device.description,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text("Localização: ${device.locale}"),
              Consumer<GroupController>(builder: (context, controller, _) {
                return Text(
                    "Group: ${controller.groups.where((element) => element.id == device.groupId).firstOrNull?.name}");
              }),
              Text("Registrado: ${device.registeredByEmail}"),
              if (device.brand != null) Text("Marca: ${device.brand}"),
              if (device.model != null) Text("Modelo: ${device.model}"),
              if (device.product != null) Text("Produto: ${device.product}"),
              if (device.device != null) Text("Dispositivo: ${device.device}"),
              const SizedBox(height: 8),
              Text(
                "Criado em: ${device.createdAt.formattedDate} ${device.createdAt.formattedTime}",
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _showDeleteDialog(BuildContext context) {
    customDialog(
      context,
      "Excluir dispositivo?",
      "Você deseja excluir este dispositivo?",
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final snackBar = CustomSnackbar(context);
              String text;
              try {
                await context.read<DeviceController>().deleteDevice(device.id);
                text = "Dispositivo excluído com sucesso!";
              } catch (e) {
                text = e.toString();
              }
              snackBar.buildMessage(text);
            },
            style: ElevatedButton.styleFrom(
                minimumSize: const Size(200, 50),
                backgroundColor: AppTheme.primaryRed,
                visualDensity: VisualDensity.compact
            ),
            child: const Text("Excluir", style: TextStyle(
                color: Colors.white)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              visualDensity: VisualDensity.compact,
            ),
            child: const Text("Fechar", style: TextStyle(
                color: AppTheme.primaryBlue)),
          ),
        ],
      )
    );
  }
}
