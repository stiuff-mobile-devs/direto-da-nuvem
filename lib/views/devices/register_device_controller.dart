import 'package:ddnuvem/models/device.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RegisterDeviceController extends ChangeNotifier {
  RegisterDeviceController();

  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController localeController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  String? _groupId;

  selectGroup(String? groupId) {
    _groupId = groupId;
    notifyListeners();
  }

  Device? validate() {
    bool? v = formKey.currentState?.validate();
    if (v != true) {
      return null;
    }
    if (_groupId == null) {
      return null;
    }
    String description = descriptionController.text;
    String locale = localeController.text;
    return Device(
      id: "",
      description: description,
      locale: locale,
      groupId: _groupId!,
      registeredBy: FirebaseAuth.instance.currentUser!.uid,
      registeredByEmail: FirebaseAuth.instance.currentUser!.email ?? "",
      updatedAt: DateTime.now(),
      createdAt: DateTime.now(),
    );
  }
}
