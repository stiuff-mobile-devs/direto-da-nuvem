import 'package:ddnuvem/controllers/user_controller.dart';
import 'package:ddnuvem/models/device.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RegisterDeviceController extends ChangeNotifier {
  final Device? device;
  RegisterDeviceController(this.context, this.device) {
    userController = Provider.of<UserController>(context, listen: false);
    if (device != null) {
      descriptionController.text = device!.description;
      localeController.text = device!.locale;
      _groupId = device!.groupId;
    }
  }

  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController localeController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final FocusNode descriptionFocus = FocusNode();
  final FocusNode localeFocus = FocusNode();
  final FocusNode groupFocus = FocusNode();
  final FocusNode buttonFocus = FocusNode();
  final FocusNode redButtonFocus = FocusNode();
  UserController? userController;
  final BuildContext context;

  String? _groupId;

  selectGroup(String? groupId) {
    _groupId = groupId;
    notifyListeners();
  }

  bool validate() {
    bool? v = formKey.currentState?.validate();
    if (v != true) {
      return false;
    }
    if (_groupId == null) {
      return false;
    }

    return true;
  }

  Device newDevice() {
    String description = descriptionController.text;
    String locale = localeController.text;
    final currentUser = userController?.currentUser;
    return Device(
      id: "",
      description: description,
      locale: locale,
      groupId: _groupId!,
      registeredBy: currentUser?.id ?? "",
      registeredByEmail: currentUser?.email ?? "",
      updatedBy: currentUser?.id ?? "",
      updatedAt: DateTime.now(),
      createdAt: DateTime.now(),
    );
  }

  Device updatedDevice(Device device) {
    final currentUser = userController?.currentUser;
    device.description = descriptionController.text;
    device.locale = localeController.text;
    device.groupId = _groupId!;
    device.updatedAt = DateTime.now();
    device.updatedBy = currentUser?.id ?? "";
    return device;
  }
}
