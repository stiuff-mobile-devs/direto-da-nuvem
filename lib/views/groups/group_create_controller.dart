import 'package:flutter/material.dart';

class GroupCreateController extends ChangeNotifier {
  List<String> admins = [];

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
