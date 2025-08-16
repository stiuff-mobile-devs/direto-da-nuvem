import 'package:ddnuvem/controllers/user_controller.dart';
import 'package:ddnuvem/models/group.dart';
import 'package:ddnuvem/views/groups/group_create_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GroupCreatePage extends StatelessWidget {
  const GroupCreatePage({super.key, required this.group, required this.onSave});

  final Group group;
  final Function(Group) onSave;

  @override
  Widget build(BuildContext context) {
    UserController userController = Provider
        .of<UserController>(context, listen: false);
    String titleAction = group.id.isEmpty ? "Criar" : "Editar";
    return ChangeNotifierProvider(
      create: (context) => GroupCreateController(context, group),
      builder: (context, _) {
        GroupCreateController groupCreateController =
            context.read<GroupCreateController>();
        return Scaffold(
          appBar: AppBar(
            title: Text("$titleAction grupo"),
            actions: [
              IconButton(
                icon: const Icon(Icons.save),
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
                  Navigator.of(context).pop();
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
                      labelText: "Nome do Grupo",
                      hintText: "Digite o nome do grupo",
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
                      labelText: "Descrição do Grupo",
                      hintText: "Digite a descrição do grupo",
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
                              context.read<GroupCreateController>().addAdmin(
                                    value,
                                  );
                              groupCreateController.adminEmailController
                                  .clear();
                            },
                            decoration: const InputDecoration(
                              labelText: "Admins do Grupo",
                              hintText: "Adicione o email do admin",
                            ),
                            validator: (value) {
                              if (value != null
                                  && groupCreateController.admins.contains(value)) {
                                return "Email já adicionado";
                              }
                              if (value == null || value.isEmpty) {
                                return "Campo obrigatório";
                              }
                              final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                              if (!emailRegex.hasMatch(value)) {
                                return "Email inválido";
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
                            context.read<GroupCreateController>().addAdmin(
                                  groupCreateController
                                      .adminEmailController.text,
                                );
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
}
