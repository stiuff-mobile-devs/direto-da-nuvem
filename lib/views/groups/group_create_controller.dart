import 'package:ddnuvem/controllers/user_controller.dart';
import 'package:ddnuvem/models/group.dart';
import 'package:flutter/material.dart';

class GroupCreateController extends ChangeNotifier {
  GroupCreateController(this.userController, this.group) {
    nameController.text = group.name;
    descriptionController.text = group.description;
    admins = group.admins;
    group.updatedBy = userController.currentUser!.uid;

    if (group.id.isEmpty) {
      group.createdBy = userController.currentUser!.uid;
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
  final UserController userController;
  final Group group;

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
