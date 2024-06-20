import 'package:ddnuvem/models/device.dart';
import 'package:ddnuvem/services/direto_da_nuvem/direto_da_nuvem_service.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';

class DeviceController extends ChangeNotifier {
  final DiretoDaNuvemAPI _diretoDaNuvemAPI;
  final DeviceInfoPlugin _deviceInfoPlugin = DeviceInfoPlugin();

  DeviceController(this._diretoDaNuvemAPI);

  init() async {
    await getAndroidInfo();
    checkIsRegistered(id!);
  }

  getAndroidInfo() async {
    androidInfo = await _deviceInfoPlugin.androidInfo;
    id = androidInfo!.id;
    notifyListeners();
  }

  checkIsRegistered(String id) async {
    isRegistered = await _diretoDaNuvemAPI.deviceResource.checkIfRegistered(id);
    notifyListeners();
  }

  register(Device device) async {
    bool created = await _diretoDaNuvemAPI.deviceResource.create(device);
    isRegistered = created;
    if (isRegistered) {
      this.device = device;
    }
    notifyListeners();
  }

  AndroidDeviceInfo? androidInfo;
  String? id;
  Device? device;
  bool isRegistered = false;
}
