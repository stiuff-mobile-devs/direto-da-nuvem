import 'package:ddnuvem/controllers/device_controller.dart';
import 'package:ddnuvem/controllers/group_controller.dart';
import 'package:ddnuvem/controllers/user_controller.dart';
import 'package:ddnuvem/models/device.dart';
import 'package:ddnuvem/utils/widgets/custom_dialog.dart';
import 'package:ddnuvem/utils/widgets/custom_snackbar.dart';
import 'package:ddnuvem/utils/theme.dart';
import 'package:ddnuvem/views/devices/controllers/register_device_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

class RegisterDevicePage extends StatelessWidget {
  final Device? device;
  const RegisterDevicePage({super.key, this.device});

  @override
  Widget build(BuildContext context) {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    return ChangeNotifierProvider<RegisterDeviceController>(
      create: (_) => RegisterDeviceController(context, device),
      builder: (context, _) {
        final controller = Provider.of<RegisterDeviceController>(context);
        final deviceController = Provider.of<DeviceController>(context);
        return Scaffold(
          appBar: AppBar(
            title: Text(device != null ? 
              "Editar dispositivo" : 
              "Cadastrar dispositivo"
            ),

          ),
          body: FocusTraversalGroup (
            child: Container(
              padding: isLandscape
                  ? const EdgeInsets.only(left: 100, right: 100, top: 8, bottom: 8)
                  : const EdgeInsets.all(8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Form(
                    key: controller.formKey,
                    child: Column(
                      children: [
                        Focus(
                          onKeyEvent: (node, event) {
                            if (event is KeyDownEvent &&
                                event.logicalKey == LogicalKeyboardKey.arrowDown) {
                              FocusScope.of(node.context!).requestFocus(controller.localeFocus);
                              return KeyEventResult.handled;
                            }
                            if (event is KeyDownEvent &&
                                event.logicalKey == LogicalKeyboardKey.arrowUp) {
                              FocusScope.of(node.context!).requestFocus(controller.redButtonFocus);
                              return KeyEventResult.handled;
                            }
                            if (event.logicalKey == LogicalKeyboardKey.select ||
                                event.logicalKey == LogicalKeyboardKey.enter) {
                              controller.descriptionFocus.requestFocus();
                              return KeyEventResult.handled;
                            }
                            return KeyEventResult.ignored;
                          },
                          child: TextFormField(
                            autofocus: false,
                            focusNode: controller.descriptionFocus,
                            controller: controller.descriptionController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Campo obrigatório';
                              }
                              return null;
                            },
                            decoration: const InputDecoration(
                              floatingLabelStyle: TextStyle(color: Colors.blueGrey),
                              labelText: "Descrição",
                              border: OutlineInputBorder(),
                              hintText: "Descrição do dispositivo",
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey, width: 2),
                              ),
                            ),
                            onTap: () {
                              controller.descriptionFocus.requestFocus();
                            },
                          )
                        ),
                        const SizedBox(height: 12),
                        Focus(
                          onKeyEvent: (node, event) {
                            if (event is KeyDownEvent &&
                                event.logicalKey == LogicalKeyboardKey.arrowDown) {
                              FocusScope.of(node.context!).requestFocus(controller.buttonFocus);
                              return KeyEventResult.handled;
                            }
                            if (event is KeyDownEvent &&
                                event.logicalKey == LogicalKeyboardKey.arrowUp) {
                              FocusScope.of(node.context!).requestFocus(controller.descriptionFocus);
                              return KeyEventResult.handled;
                            }
                            if (event.logicalKey == LogicalKeyboardKey.select ||
                                event.logicalKey == LogicalKeyboardKey.enter) {
                              controller.descriptionFocus.requestFocus();
                              return KeyEventResult.handled;
                            }
                            return KeyEventResult.ignored;
                          },
                          child: TextFormField(
                            autofocus: false,
                            focusNode: controller.localeFocus,
                            controller: controller.localeController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Campo obrigatório';
                              }
                              return null;
                            },
                            decoration: const InputDecoration(
                              floatingLabelStyle: TextStyle(color: Colors.blueGrey),
                              hintText: "Local do dispositivo",
                              labelText: 'Localização',
                              border: OutlineInputBorder(),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey, width: 2),
                              ),
                            ),
                            onTap: () {
                              controller.descriptionFocus.requestFocus();
                            },
                          )
                        ),
                        const SizedBox(height: 12),
                        choseGroup(controller),
                        const SizedBox(height: 12),
                        Focus(
                          onKeyEvent: (node, event) {
                            if (event is KeyDownEvent &&
                                event.logicalKey == LogicalKeyboardKey.arrowUp) {
                              FocusScope.of(node.context!).requestFocus(controller.localeFocus);
                              return KeyEventResult.handled;
                            }
                            if (event is KeyDownEvent &&
                                event.logicalKey == LogicalKeyboardKey.arrowDown) {
                              FocusScope.of(node.context!).requestFocus(controller.redButtonFocus);
                              return KeyEventResult.handled;
                            }
                            return KeyEventResult.ignored;
                          },
                          child: ElevatedButton(
                            focusNode: controller.buttonFocus,
                            onPressed: () async {
                              if (!controller.validate()) {
                                return;
                              }
                              if (device == null) {
                                final newDevice = controller.newDevice();
                                await deviceController.register(newDevice, context);
                              } else {
                                final newDevice = controller.updatedDevice(device!);
                                await _onUpdateDevice(newDevice, context);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 50),
                                backgroundColor: AppTheme.primaryBlue
                            ),
                            child: Text(device != null
                                ? "Atualizar"
                                : "Cadastrar",
                            style: const TextStyle(color: Colors.white)),
                          )
                        ),
                        if (device != null) ...[
                          const SizedBox(height: 5),
                          ElevatedButton(
                            onPressed: () => _showDeleteDialog(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryRed,
                              minimumSize: const Size(double.infinity, 50),
                            ),
                            child: const Text(
                              "Excluir",
                              style: TextStyle(color: Colors.white),
                            ),
                          )
                        ] else ...[
                          const SizedBox(height: 5),
                          Focus(
                            onKeyEvent: (node, event) {
                              if (event is KeyDownEvent &&
                                  event.logicalKey == LogicalKeyboardKey.arrowUp) {
                                FocusScope.of(node.context!).requestFocus(controller.buttonFocus);
                                return KeyEventResult.handled;
                              }
                              if (event is KeyDownEvent &&
                                  event.logicalKey == LogicalKeyboardKey.arrowDown) {
                                FocusScope.of(node.context!).requestFocus(controller.descriptionFocus);
                                return KeyEventResult.handled;
                              }
                              return KeyEventResult.ignored;
                            },
                            child: ElevatedButton(
                              focusNode: controller.redButtonFocus,
                              onPressed: () => _logout(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryRed,
                                minimumSize: const Size(double.infinity, 50),
                              ),
                              child: const Text(
                                "Sair",
                                style: TextStyle(color: Colors.white),
                              )
                            )
                          ),
                        ]
                      ],
                    )
                  )
                ],
              ),
            ),
          )
        );
      },
    );
  }

  Widget choseGroup(RegisterDeviceController controller) {
    return Consumer<GroupController>(
      builder: (context, groupController, _) {
        List<DropdownMenuEntry<String>> entries = groupController.groups.map(
              (e) {
            return DropdownMenuEntry<String>(value: e.id, label: e.name);
          },
        ).toList();

        return DropdownMenu<String>(
          initialSelection: controller.device?.groupId,
          focusNode: controller.groupFocus,
          width: MediaQuery.of(context).size.width - 16,
          dropdownMenuEntries: entries,
          onSelected: controller.selectGroup,
          label: const Text("Selecionar Grupo"),
          inputDecorationTheme: const InputDecorationTheme(
            floatingLabelStyle: TextStyle(color: Colors.blueGrey),
            border: OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey, width: 2),
            ),
          ),
        );
      },
    );
  }

  _showDeleteDialog(BuildContext context) {
    return customDialog(
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
                await context.read<DeviceController>().deleteDevice(device!.id);
                text = "Dispositivo excluído com sucesso!";
              } catch (e) {
                text = e.toString();
              }
              snackBar.buildMessage(text);
              if (context.mounted) Navigator.of(context).pop();
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

  _onUpdateDevice(Device device, BuildContext ctx) async {
    final deviceController = ctx.read<DeviceController>();
    final snackBar = CustomSnackbar(ctx);
    String text;

    try {
      await deviceController.updateDevice(device);
      text = "Dispositivo atualizado com sucesso!";
    } catch (e) {
      text = e.toString();
    }

    snackBar.buildMessage(text);
    if (ctx.mounted) Navigator.pop(ctx);
  }
  
  _logout(BuildContext context) async {
    final snackBar = CustomSnackbar(context);

    try {
      await context.read<UserController>().logout();
      snackBar.buildType("Sessão encerrada", "success");
    } catch (e) {
      snackBar.buildType(e.toString(), "error");
      return;
    }
  }
}
