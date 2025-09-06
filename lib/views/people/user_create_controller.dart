import 'package:ddnuvem/controllers/user_controller.dart';
import 'package:ddnuvem/models/user.dart';
import 'package:flutter/material.dart';

class UserCreateController extends ChangeNotifier {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final isInstaller = ValueNotifier<bool>(false);
  final isAdmin = ValueNotifier<bool>(false);
  final isSuperAdmin = ValueNotifier<bool>(false);
  final UserController controller;
  final User user;

  UserCreateController(this.controller, this.user) {
    emailController.text = user.email;
    isInstaller.value = user.privileges.isInstaller;
    isAdmin.value = user.privileges.isAdmin;
    isSuperAdmin.value = user.privileges.isSuperAdmin;

    user.updatedBy = controller.currentUser!.id;

    if (user.id.isEmpty) {
      user.createdBy = controller.currentUser!.id;
    } else {
      user.updatedAt = DateTime.now();
    }

    notifyListeners();
  }

  bool privilegesNotEmpty() {
    return isAdmin.value || isInstaller.value || isSuperAdmin.value;
  }
}
