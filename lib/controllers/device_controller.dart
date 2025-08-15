import 'package:ddnuvem/controllers/group_controller.dart';
import 'package:ddnuvem/models/device.dart';
import 'package:ddnuvem/models/group.dart';
import 'package:ddnuvem/models/queue.dart';
import 'package:ddnuvem/services/direto_da_nuvem/direto_da_nuvem_service.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';

class DeviceController extends ChangeNotifier {
  final DiretoDaNuvemAPI _diretoDaNuvemAPI;
  final DeviceInfoPlugin _deviceInfoPlugin = DeviceInfoPlugin();
  final GroupController _groupController;

  AndroidDeviceInfo? androidInfo;
  Group? group;
  Device? device;
  bool isRegistered = false;
  Queue? currentQueue;
  Stream<Queue?>? currentQueueStream;
  List<Device> devices = [];
  bool loadingInitialState = true;

  DeviceController(this._diretoDaNuvemAPI, this._groupController);

  init() async {
    loadingInitialState = true;
    notifyListeners();
    await _getAndroidInfo();
    await _checkIsRegistered(androidInfo!.id);
    await _fetchGroupAndQueue();
    _groupController.addListener(_updateCurrentQueueAndGroup);
    devices = await _diretoDaNuvemAPI.deviceResource.listAll();
    loadingInitialState = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _groupController.removeListener(_updateCurrentQueueAndGroup);
    super.dispose();
  }

  Future<void> _getAndroidInfo() async {
    androidInfo = await _deviceInfoPlugin.androidInfo;
  }

  Future<void> _checkIsRegistered(String id) async {
    device = await _diretoDaNuvemAPI.deviceResource.checkIfRegistered(id);
    isRegistered = device != null;
  }

  Future<void> register(Device device, BuildContext context) async {
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
      devices.add(device);
      await _fetchGroupAndQueue();
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/',
        (route) => false,
      );
    }
    notifyListeners();
  }

  _fetchGroupAndQueue() async {
    await _fetchGroup();
    await _fetchCurrentQueue();
  }

  _fetchGroup() async {
    if (device == null) {
      return;
    }
    group = await _groupController.fetchDeviceGroup(device!);
  }

  _fetchCurrentQueue() async {
    if (group == null) {
      return;
    }

    currentQueue =
        await _diretoDaNuvemAPI.queueResource.get(group!.currentQueue);
    currentQueueStream =
        _diretoDaNuvemAPI.queueResource.getStream(group!.currentQueue);

    currentQueueStream?.listen((queue) {
      currentQueue = queue;
      notifyListeners();
    });
  }

  _updateCurrentQueueAndGroup() async {
    await _fetchGroupAndQueue();
    notifyListeners();
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
}
