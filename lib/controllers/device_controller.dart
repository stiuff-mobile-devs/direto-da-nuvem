import 'package:ddnuvem/models/device.dart';
import 'package:ddnuvem/models/group.dart';
import 'package:ddnuvem/models/queue.dart';
import 'package:ddnuvem/services/direto_da_nuvem/direto_da_nuvem_service.dart';
import 'package:ddnuvem/views/redirection_page.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';

class DeviceController extends ChangeNotifier {
  final DiretoDaNuvemAPI _diretoDaNuvemAPI;
  final DeviceInfoPlugin _deviceInfoPlugin = DeviceInfoPlugin();

  DeviceController(this._diretoDaNuvemAPI);

  init() async {
    await _getAndroidInfo();
    _checkIsRegistered(id!);
  }

  _getAndroidInfo() async {
    androidInfo = await _deviceInfoPlugin.androidInfo;
    id = androidInfo!.id;
    notifyListeners();
  }

  _checkIsRegistered(String id) async {
    device = await _diretoDaNuvemAPI.deviceResource.checkIfRegistered(id);
    isRegistered = device != null;
    notifyListeners();
  }

  register(Device device, BuildContext context) async {
    bool created = await _diretoDaNuvemAPI.deviceResource.create(device);
    isRegistered = created;
    if (isRegistered) {
      this.device = device;
    }
    notifyListeners();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RedirectionPage()),
    );
  }

  fetchGroupAndQueue() async {
    await _fetchGroup();
    await _fetchCurrentQueue();
    notifyListeners();
  }

  _fetchGroup() async {
    group = await _diretoDaNuvemAPI.groupResource.get(device!.groupId);
  }

  _fetchCurrentQueue() async {
    currentQueue =
        await _diretoDaNuvemAPI.queueResource.get(group!.currentQueue);
  }

  AndroidDeviceInfo? androidInfo;
  String? id;
  Queue? currentQueue;
  Group? group;
  Device? device;
  bool isRegistered = false;
}
