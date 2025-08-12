import 'package:ddnuvem/controllers/user_controller.dart';
import 'package:ddnuvem/models/group.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GroupCreateController extends ChangeNotifier {
  GroupCreateController(this.context, this.group) {
    UserController userController = Provider
        .of<UserController>(context, listen: false);

    nameController.text = group.name;
    descriptionController.text = group.description;
    admins = group.admins;
    group.updatedBy = userController.currentUser!.uid ?? "";

    if (group.id.isEmpty) {
      group.createdBy = userController.currentUser!.uid ?? "";
      admins.contains(userController.currentUser!.email)
          ? null
          : admins.add(userController.currentUser!.email);
    } else {
      group.updatedAt = DateTime.now();
    }

    notifyListeners();
  }

  List<String> admins = [];
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController adminEmailController = TextEditingController();
  final GlobalKey<FormState> adminFormKey = GlobalKey<FormState>();
  final Group group;
  final BuildContext context;

  void addAdmin(String admin) {
    admin = admin.trim();
    if (!admins.contains(admin)) {
      admins.add(admin);
      notifyListeners();
    }
  }

  void removeAdmin(String admin) {
    admin = admin.trim();
    if (admins.contains(admin)) {
      admins.remove(admin);
      notifyListeners();
    }
  }
}
