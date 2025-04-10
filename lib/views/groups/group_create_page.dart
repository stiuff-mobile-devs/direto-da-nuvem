import 'package:ddnuvem/controllers/group_controller.dart';
import 'package:ddnuvem/views/groups/group_create_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GroupCreatePage extends StatelessWidget {
  GroupCreatePage({super.key});

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController adminEmailController = TextEditingController();
  final GlobalKey<FormState> _adminFormKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    GroupController controller =
        Provider.of<GroupController>(context, listen: false);
    return ChangeNotifierProvider(
      create: (context) => GroupCreateController(),
      builder: (context, _) => Scaffold(
          appBar: AppBar(
            title: const Text("Criar Grupo"),
            actions: [
              IconButton(
                icon: const Icon(Icons.save),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    // Save the form data
                    await controller.createGroup(
                        nameController.text,
                        descriptionController.text,
                        context.read<GroupCreateController>().admins);
                    Navigator.of(context).pop();
                  }
                },
              )
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: nameController,
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
                    controller: descriptionController,
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
                    key: _adminFormKey,
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: adminEmailController,
                            onFieldSubmitted: (value) {
                              if (!_adminFormKey.currentState!.validate()) {
                                return;
                              }
                              context.read<GroupCreateController>().addAdmin(
                                    value,
                                  );
                              adminEmailController.clear();
                            },
                            decoration: const InputDecoration(
                              labelText: "Admins do Grupo",
                              hintText: "Adicione o email do admin",
                            ),
                            validator: (value) {
                              if (value != null &&
                                  context
                                      .read<GroupCreateController>()
                                      .admins
                                      .contains(value)) {
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
                            if (!_adminFormKey.currentState!.validate()) {
                              return;
                            }
                            context.read<GroupCreateController>().addAdmin(
                                  adminEmailController.text,
                                );
                            adminEmailController.clear();
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
          )),
    );
  }
}
