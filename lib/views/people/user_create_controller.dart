import 'package:ddnuvem/controllers/user_controller.dart';
import 'package:ddnuvem/models/user.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserCreateController extends ChangeNotifier {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final isInstaller = ValueNotifier<bool>(false);
  final isAdmin = ValueNotifier<bool>(false);
  final isSuperAdmin = ValueNotifier<bool>(false);
  final User user;
  final BuildContext context;

  UserCreateController(this.context, this.user) {
    UserController userController = context.read<UserController>();

    emailController.text = user.email;
    isInstaller.value = user.privileges.isInstaller;
    isAdmin.value = user.privileges.isAdmin;
    isSuperAdmin.value = user.privileges.isSuperAdmin;

    user.updatedBy = userController.currentUser!.uid ?? "";

    if (user.id.isEmpty) {
      user.createdBy = userController.currentUser!.uid ?? "";
    } else {
      user.updatedAt = DateTime.now();
    }

    notifyListeners();
  }

  bool validPrivileges() {
    return isAdmin.value || isInstaller.value || isSuperAdmin.value;
  }
}
