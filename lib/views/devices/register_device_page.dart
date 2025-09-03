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
                            if (!controller.validate()) {
                              return;
                            }

                            Device newDevice;
                            if (device == null) {
                              newDevice = controller.newDevice();
                              deviceController.register(newDevice, context);
                            } else {
                              newDevice = controller.updatedDevice(device!);
                              final messenger = ScaffoldMessenger.of(context);
                              deviceController.update(newDevice).then((message) {
                                messenger.showSnackBar(SnackBar(
                                    content: Text(message)));
                              });
                              Navigator.pop(context);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 50),
                          ),
                          child: Text(device != null
                              ? "Atualizar"
                              : "Cadastrar",
                          style: const TextStyle(color: AppTheme.primaryBlue)),
                        ),
                        // Mostrar botão de deletar apenas se o dispositivo já existir
                        if (device != null) ...[
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () async {
                              // Abre uma caixa de diálogo e aguarda a escolha do usuário.
                              final confirmed = await _showDeleteDialog(context);

                              // Se o usuário aceitar, 
                              // então...
                              if (confirmed == true) {
                                // ... cria um scaffold messenger para mostrar, possivelmente em outra página,
                                // mensagem de sucesso ou erro após tentativa de exclusão.
                                final messenger = ScaffoldMessenger.of(context);
                                try {
                                  // deleta o dispositivo do banco de dados
                                  await context.read<DeviceController>().deleteDevice(device!.id);
                                  // mostra mensagem de sucesso atraves de uma snackbar
                                  // com o auxílio do scaffold messenger.
                                  messenger.showSnackBar(
                                    const SnackBar(content: Text('Dispositivo deletado')),
                                  );
                                  // fecha a página atual de Edição dispositivo.
                                  Navigator.of(context).pop();
                                } catch (e) {
                                  // mostra mensagem de erro através de uma snackbar
                                  // com o auxílio do scaffold messenger.
                                  messenger.showSnackBar(
                                    SnackBar(content: Text('Erro ao deletar: $e'))
                                  );
                                }
                              }
                              // Se o usuário não aceitar (clicar em "Cancelar" ou fora da caixa),
                              // então feche a caixa e não faça nada.
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryRed,
                              minimumSize: const Size(double.infinity, 50),
                            ),
                            child: const Text(
                              "Deletar",
                              style: TextStyle(color: Colors.white),
                            ),
                          )
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

  Future _showDeleteDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirmar Exclusão"),
          content: const Text("Você tem certeza que deseja deletar este dispositivo?"),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text("Deletar"),
            ),
          ],
        );
      },
    );
  }
}
