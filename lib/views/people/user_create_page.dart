import 'package:ddnuvem/controllers/user_controller.dart';
import 'package:ddnuvem/models/user.dart';
import 'package:ddnuvem/utils/custom_snackbar.dart';
import 'package:ddnuvem/utils/email_regex.dart';
import 'package:ddnuvem/utils/theme.dart';
import 'package:ddnuvem/views/people/user_create_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserCreatePage extends StatelessWidget {
  const UserCreatePage({super.key,
    required this.user, required this.onSave, this.onDelete});

  final User user;
  final Function(User) onSave;
  final Function(User)? onDelete;

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
              user.id.isNotEmpty ?
              IconButton(
                color: AppTheme.primaryRed,
                onPressed: () {
                  _showDeleteDialog(context);
                },
                icon: const Icon(Icons.delete),
              ) : const SizedBox.shrink(),
              IconButton(
                color: AppTheme.primaryBlue,
                icon: const Icon(Icons.save),
                onPressed: () async {
                  if (!userCreateController.formKey.currentState!.validate()) {
                    return;
                  }
                  if (!userCreateController.privilegesNotEmpty()) {
                    CustomSnackbar(context).build(
                        "Selecione pelo menos um privilégio.",
                        "error");
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
                    enabled: !user.authenticated,
                    controller: userCreateController.emailController,
                    decoration: const InputDecoration(
                      floatingLabelStyle: TextStyle(color: Colors.blueGrey),
                      border: OutlineInputBorder(),
                      labelText: "E-mail",
                      hintText: "Digite o e-mail do usuário",
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 2),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Campo obrigatório";
                      }
                      if (!emailHasMatch(value)) {
                        return "E-mail inválido";
                      }
                      // if (!iduffEmailHasMatch(value)) {
                      //   return "E-mail deve ser do domínio id.uff.br";
                      // }
                      return null;
                    },
                  ),
                  ValueListenableBuilder<bool>(
                    valueListenable: userCreateController.isInstaller,
                    builder: (context, value, _) {
                      return CheckboxListTile(
                        activeColor: AppTheme.primaryBlue,
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
                        activeColor: AppTheme.primaryBlue,
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
                        activeColor: AppTheme.primaryBlue,
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
  _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Excluir usuário"),
          content: const Text("Você deseja excluir este usuário?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Fechar", style: TextStyle(
                  color: AppTheme.primaryBlue)),
            ),
            TextButton(
              onPressed: () {
                if (onDelete != null) {
                  Navigator.pop(context);
                  onDelete!(user);
                }
              },
              child: const Text("Excluir",
                  style: TextStyle(fontWeight: FontWeight.bold,
                  color: AppTheme.primaryRed),
            )),
          ],
        );
      },
    );
  }

}
