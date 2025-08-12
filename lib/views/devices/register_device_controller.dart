import 'package:ddnuvem/controllers/user_controller.dart';
import 'package:ddnuvem/models/device.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RegisterDeviceController extends ChangeNotifier {
  RegisterDeviceController(this.context) {
    userController = Provider.of<UserController>(context, listen: false);
  }

  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController localeController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  UserController? userController;
  final BuildContext context;

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
    final currentUser = userController?.currentUser;
    return Device(
      id: "",
      description: description,
      locale: locale,
      groupId: _groupId!,
      registeredBy: currentUser?.uid ?? "",
      registeredByEmail: currentUser?.email ?? "",
      updatedBy: currentUser?.uid ?? "",
      updatedAt: DateTime.now(),
      createdAt: DateTime.now(),
    );
  }
}
