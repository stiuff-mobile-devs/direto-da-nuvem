import 'package:ddnuvem/controllers/device_controller.dart';
import 'package:ddnuvem/controllers/group_controller.dart';
import 'package:ddnuvem/models/device.dart';
import 'package:ddnuvem/utils/theme.dart';
import 'package:ddnuvem/views/devices/register_device_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
          body: FocusTraversalGroup (
            child: Container(
              padding: isLandscape
                  ? const EdgeInsets.only(left: 100, right: 100, top: 8, bottom: 8)
                  : const EdgeInsets.all(8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Cadastro de novo dispositivo",
                      style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(
                    height: 16,
                  ),
                  Form(
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
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
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
                        ),
                        const SizedBox(height: 12),
                        choseGroup(controller),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          focusNode: controller.buttonFocus,
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
}
