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
  Device? self;

  DeviceController(this._diretoDaNuvemAPI);

  init() async {
    loadingInitialState = true;
    await _getAndroidInfo();
    await _checkIsRegistered(id!);
    await fetchGroupAndQueue();
    loadingInitialState = false;
    devices = await _diretoDaNuvemAPI.deviceResource.listAll();
    devices.where((device) => device.id == id).forEach((device) {
      self = device;
    });
    notifyListeners();
  }

  _getAndroidInfo() async {
    androidInfo = await _deviceInfoPlugin.androidInfo;
    id = androidInfo!.id;
  }

  _checkIsRegistered(String id) async {
    device = await _diretoDaNuvemAPI.deviceResource.checkIfRegistered(id);
    isRegistered = device != null;
    loadingInitialState = false;
  }

  register(Device device, BuildContext context) async {
    if (androidInfo != null) {
      device.id = androidInfo!.id;
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
  }

  _fetchGroup() async {
    if (device == null) {
      return;
    }
    group = await _diretoDaNuvemAPI.groupResource.get(device!.groupId);
  }

  _fetchCurrentQueue() async {
    if (group == null) {
      return;
    }
    currentQueue =
        await _diretoDaNuvemAPI.queueResource.get(group!.currentQueue);
    currentQueueStream = _diretoDaNuvemAPI.queueResource
        .getStream(group!.currentQueue);
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

  List<Device> listDevicesInGroups(Set<String> groupIds) {
    if (groupIds.isEmpty) {
      return devices;
    }
    List<Device> devicesInGroups = [];
    for (var device in devices) {
      if (groupIds.contains(device.groupId)) {
        devicesInGroups.add(device);
      }
    }
    return devicesInGroups;
  }

  Queue getCurrentQueue() {
    if (currentQueue == null) {
      throw Exception("Fila atual não definida.");
    }
    return currentQueue!;
  }

  AndroidDeviceInfo? androidInfo;
  String? id;
  Queue? currentQueue;
  Stream<Queue?>? currentQueueStream;
  Group? group;
  Device? device;
  bool isRegistered = false;
}
