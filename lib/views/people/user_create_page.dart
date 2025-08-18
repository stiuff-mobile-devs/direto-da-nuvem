import 'package:ddnuvem/controllers/user_controller.dart';
import 'package:ddnuvem/models/user.dart';
import 'package:ddnuvem/views/people/user_create_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserCreatePage extends StatelessWidget {
  const UserCreatePage({super.key, required this.user, required this.onSave});

  final User user;
  final Function(User) onSave;

  @override
  Widget build(BuildContext context) {
    UserController userController = context.read<UserController>();
    String titleAction = user.id.isEmpty ? "Criar" : "Editar";

    return ChangeNotifierProvider(
      create: (context) => UserCreateController(userController, user),
      builder: (context, _) {
        UserCreateController userCreateController =
        context.read<UserCreateController>();
        return Scaffold(
          appBar: AppBar(
            title: Text("$titleAction usuário"),
            actions: [
              IconButton(
                icon: const Icon(Icons.save),
                onPressed: () async {
                  if (!userCreateController.formKey.currentState!.validate()) {
                    return;
                  }

                  if (!userCreateController.privilegesNotEmpty()) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Selecione pelo menos um privilégio."),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  userCreateController.user.email =
                      userCreateController.emailController.text;
                  userCreateController.user.privileges.isInstaller =
                      userCreateController.isInstaller.value;
                  userCreateController.user.privileges.isAdmin =
                      userCreateController.isAdmin.value;
                  userCreateController.user.privileges.isSuperAdmin =
                      userCreateController.isSuperAdmin.value;

                  onSave(userCreateController.user);
                  Navigator.of(context).pop();
                },
              )
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Form(
              key: userCreateController.formKey,
              child: Column(
                children: [
                  TextFormField(
                    enabled: user.uid.isEmpty,
                    controller: userCreateController.emailController,
                    decoration: const InputDecoration(
                      labelText: "E-mail",
                      hintText: "Digite o e-mail iduff do usuário",
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Campo obrigatório";
                      }
                      final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                      if (!emailRegex.hasMatch(value)) {
                        return "E-mail inválido";
                      }
                      // final iduffRegex = RegExp(
                      //     r"^[A-Za-z0-9.!#$%&'*+/=?^_`{|}~-]+@id\.uff\.br$");
                      // if (!iduffRegex.hasMatch(value)) {
                      //   return "E-mail deve ser do domínio id.uff.br";
                      // }
                      return null;
                    },
                  ),
                  ValueListenableBuilder<bool>(
                    valueListenable: userCreateController.isInstaller,
                    builder: (context, value, _) {
                      return CheckboxListTile(
                        title: const Text("Instalador"),
                        value: value,
                        onChanged: (v) {
                          userCreateController.isInstaller.value = v ?? false;
                        },
                      );
                    },
                  ),
                  ValueListenableBuilder<bool>(
                    valueListenable: userCreateController.isAdmin,
                    builder: (context, value, _) {
                      return CheckboxListTile(
                        title: const Text("Administrador"),
                        value: value,
                        onChanged: (v) {
                          userCreateController.isAdmin.value = v ?? false;
                        },
                      );
                    },
                  ),
                  ValueListenableBuilder<bool>(
                    valueListenable: userCreateController.isSuperAdmin,
                    builder: (context, value, _) {
                      return CheckboxListTile(
                        title: const Text("Super Administrador"),
                        value: value,
                        onChanged: (v) {
                          userCreateController.isSuperAdmin.value = v ?? false;
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
