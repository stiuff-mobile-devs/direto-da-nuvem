import 'package:ddnuvem/models/group.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class GroupCreateController extends ChangeNotifier {
  GroupCreateController(this.group) {
    final currentUser = FirebaseAuth.instance.currentUser!;
    nameController.text = group.name;
    descriptionController.text = group.description;
    admins = group.admins ?? [];
    group.updatedBy = currentUser.uid;

    if (group.id!.isEmpty) {
      group.createdBy = currentUser.uid;
      admins.contains(currentUser.email!) ? null: admins.add(currentUser.email!);
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
