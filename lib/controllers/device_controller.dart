import 'package:ddnuvem/models/device.dart';
import 'package:ddnuvem/models/group.dart';
import 'package:ddnuvem/models/queue.dart';
import 'package:ddnuvem/services/direto_da_nuvem/direto_da_nuvem_service.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';

class DeviceController extends ChangeNotifier {
  final DiretoDaNuvemAPI _diretoDaNuvemAPI;
  final DeviceInfoPlugin _deviceInfoPlugin = DeviceInfoPlugin();

  List<Device> devices = [];
  bool loadingInitialState = true;

  DeviceController(this._diretoDaNuvemAPI);

  init() async {
    loadingInitialState = true;
    await _getAndroidInfo();
    _checkIsRegistered(id!);
    loadingInitialState = false;
    devices = await _diretoDaNuvemAPI.deviceResource.listAll();
    notifyListeners();
  }

  _getAndroidInfo() async {
    androidInfo = await _deviceInfoPlugin.androidInfo;
    id = androidInfo!.id;
    notifyListeners();
  }

  _checkIsRegistered(String id) async {
    device = await _diretoDaNuvemAPI.deviceResource.checkIfRegistered(id);
    isRegistered = device != null;
    loadingInitialState = false;
    notifyListeners();
  }

  register(Device device, BuildContext context) async {
    if (androidInfo != null) {
      device.brand = androidInfo!.brand;
      device.model = androidInfo!.model;
      device.product = androidInfo!.product;
      device.device = androidInfo!.device;
    }
    bool created = await _diretoDaNuvemAPI.deviceResource.create(device);
    isRegistered = created;
    if (isRegistered) {
      this.device = device;
    }
    notifyListeners();
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

  int numberOfDevicesOnGroup(String groupId) {
    int count = 0;
    for (var device in devices) {
      if (device.groupId == groupId) {
        count++;
      }
    }
    return count;
  }

  AndroidDeviceInfo? androidInfo;
  String? id;
  Queue? currentQueue;
  Group? group;
  Device? device;
  bool isRegistered = false;
}
