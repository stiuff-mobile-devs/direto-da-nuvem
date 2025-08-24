import 'package:ddnuvem/controllers/device_controller.dart';
import 'package:ddnuvem/controllers/group_controller.dart';
import 'package:ddnuvem/models/device.dart';
import 'package:ddnuvem/views/devices/register_device_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RegisterDevicePage extends StatelessWidget {
  final Device? device;
  const RegisterDevicePage({super.key, this.device});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<RegisterDeviceController>(
      create: (_) => RegisterDeviceController(context, device),
      builder: (context, _) {
        final controller = Provider.of<RegisterDeviceController>(context);
        final deviceController = Provider.of<DeviceController>(context);
        return Scaffold(
          body: Container(
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    deviceController.isRegistered
                        ? "Editar dispositivo"
                        : "Cadastro de novo dispositivo",
                    style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(
                  height: 16,
                ),
                Form(
                    key: controller.formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: controller.descriptionController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Campo obrigatório';
                            }
                            return null;
                          },
                          decoration: 
                              const InputDecoration(hintText: "Descrição"),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: controller.localeController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Campo obrigatório';
                            }
                            return null;
                          },
                          decoration:
                              const InputDecoration(hintText: "Localização"),
                        ),
                        const SizedBox(height: 12),
                        choseGroup(controller),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () async {
                            Device? device = controller.validate();
                            if (device != null) {
                              deviceController.register(device, context);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 50),
                          ),
                          child: Text(deviceController.isRegistered
                              ? "Atualizar"
                              : "Cadastrar"),
                        ),
                      ],
                    ))
              ],
            ),
          ),
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
          width: MediaQuery.of(context).size.width - 16,
          dropdownMenuEntries: entries,
          onSelected: controller.selectGroup,
          label: const Text("Selectionar Grupo"),
        );
      },
    );
  }
}
