import 'package:ddnuvem/controllers/device_controller.dart';
import 'package:ddnuvem/controllers/group_controller.dart';
import 'package:ddnuvem/controllers/queue_controller.dart';
import 'package:ddnuvem/controllers/user_controller.dart';
import 'package:ddnuvem/models/group.dart';
import 'package:ddnuvem/utils/widgets/custom_dialog.dart';
import 'package:ddnuvem/utils/widgets/custom_snackbar.dart';
import 'package:ddnuvem/utils/email_regex.dart';
import 'package:ddnuvem/utils/theme.dart';
import 'package:ddnuvem/views/groups/controllers/group_create_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GroupCreatePage extends StatelessWidget {
  const GroupCreatePage({super.key,
    required this.group, required this.onSave});

  final Group group;
  final Function(Group) onSave;

  @override
  Widget build(BuildContext context) {
    UserController userController = context.read<UserController>();
    bool isSuperAdmin = userController.isCurrentUserSuperAdmin();
    String titleAction = group.id.isEmpty ? "Criar" : "Editar";

    return ChangeNotifierProvider(
      create: (context) => GroupCreateController(userController, group),
      builder: (context, _) {
        GroupCreateController groupCreateController =
            context.read<GroupCreateController>();
        return Scaffold(
          appBar: AppBar(
            title: Text("$titleAction grupo"),
            actions: [
              group.id.isNotEmpty && isSuperAdmin
                  ? IconButton(
                      color: AppTheme.primaryRed,
                      onPressed: () {
                        _showDeleteDialog(context);
                      },
                      icon: const Icon(Icons.delete),
                    )
                  : const SizedBox.shrink(),
              IconButton(
                icon: const Icon(Icons.save),
                color: AppTheme.primaryBlue,
                onPressed: () async {
                  if (!groupCreateController.formKey.currentState!.validate()) {
                    return;
                  }

                  groupCreateController.group.name =
                      groupCreateController.nameController.text;
                  groupCreateController.group.description =
                      groupCreateController.descriptionController.text;
                  groupCreateController.group.admins =
                      groupCreateController.admins;

                  onSave(groupCreateController.group);
                },
              )
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Form(
              key: groupCreateController.formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: groupCreateController.nameController,
                    decoration: const InputDecoration(
                      floatingLabelStyle: TextStyle(color: Colors.blueGrey),
                      labelText: "Nome do Grupo",
                      hintText: "Digite o nome do grupo",
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 2),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Campo obrigatório";
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: groupCreateController.descriptionController,
                    decoration: const InputDecoration(
                      floatingLabelStyle: TextStyle(color: Colors.blueGrey),
                      labelText: "Descrição do Grupo",
                      hintText: "Digite a descrição do grupo",
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 2),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Campo obrigatório";
                      }
                      return null;
                    },
                  ),
                  Form(
                    key: groupCreateController.adminFormKey,
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller:
                                groupCreateController.adminEmailController,
                            onFieldSubmitted: (value) {
                              if (!groupCreateController
                                  .adminFormKey.currentState!
                                  .validate()) {
                                return;
                              }
                              groupCreateController.addAdmin(value);
                              groupCreateController
                                  .adminEmailController.clear();
                            },
                            decoration: const InputDecoration(
                              labelText: "Admins do Grupo",
                              floatingLabelStyle: TextStyle(color: Colors.blueGrey),
                              hintText: "Adicione o e-mail do admin",
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey, width: 2),
                              ),
                            ),
                            validator: (value) {
                              if (value != null
                                  && groupCreateController.admins.contains(value)) {
                                return "E-mail já adicionado";
                              }
                              if (value == null || value.isEmpty) {
                                return "Campo obrigatório";
                              }
                              if (!emailHasMatch(value)) {
                                return "E-mail inválido";
                              }
                              return null;
                            },
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () {
                            if (!groupCreateController
                                .adminFormKey.currentState!
                                .validate()) {
                              return;
                            }
                            groupCreateController.addAdmin(
                                  groupCreateController
                                      .adminEmailController.text);
                            groupCreateController.adminEmailController.clear();
                          },
                        )
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Consumer<GroupCreateController>(
                      builder: (context, groupCreateController, _) {
                    return Wrap(
                      children: groupCreateController.admins
                          .map((admin) => Chip(
                                label: Text(admin),
                                onDeleted: () {
                                  groupCreateController.removeAdmin(admin);
                                },
                              ))
                          .toList(),
                    );
                  })
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  _showDeleteDialog(BuildContext context) {
    final queueController = context.read<QueueController>();
    final deviceController = context.read<DeviceController>();
    final groupController = context.read<GroupController>();
    final snackBar = CustomSnackbar(context);
    String text;

    customDialog(context,
      "Excluir grupo?",
      "Você deseja excluir este grupo e todas as suas filas e dispositivos?",
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton(
            onPressed: () async {
              try {
                await groupController.deleteGroup(group.id);
                await queueController.deleteQueuesByGroup(group.id);
                await deviceController.deleteDevicesByGroup(group.id);
                text = "Grupo excluído com sucesso!";
              } catch (e) {
                text = e.toString();
              }
              snackBar.buildMessage(text);
              if (context.mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil('/',
                        (route) => false,
                    arguments: {'startIndex': 1});
              }
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
