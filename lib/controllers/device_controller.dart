import 'dart:async';
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
  Queue? defaultQueue;
  List<Device> _devices = [];

  StreamSubscription<Queue?>? _currentQueueSubscription;
  StreamSubscription<List<Device>>? _devicesSubscription;
  bool loadingInitialState = true;

  DeviceController(this._diretoDaNuvemAPI, this._groupController);

  init() async {
    loadingInitialState = true;
    notifyListeners();
    await _getAndroidInfo();
    await _checkIsRegistered();
    await _fetchGroupAndQueue();
    await _loadDevices();
    _groupController.addListener(_updateCurrentQueueAndGroup);
    loadingInitialState = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _groupController.removeListener(_updateCurrentQueueAndGroup);
    _currentQueueSubscription?.cancel();
    _devicesSubscription?.cancel();
    super.dispose();
  }

  Future<void> _getAndroidInfo() async {
    try {
      androidInfo = await _deviceInfoPlugin.androidInfo;
    } catch (e) {
      debugPrint("Erro ao obter dados do android: $e");
      androidInfo = null;
    }
  }

  _checkIsRegistered() async {
    if (androidInfo != null) {
      device = await _diretoDaNuvemAPI.deviceResource.get(androidInfo!.id);
      isRegistered = (device != null);
    } else {
      device = null;
      isRegistered = false;
    }
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
      await _fetchGroupAndQueue();

      if (context.mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      }
    }
    notifyListeners();
  }

  Future<String> update(Device device) async {
    try {
      await _diretoDaNuvemAPI.deviceResource.update(device);
      notifyListeners();
      return "Dispositivo atualizado com sucesso!";
    } catch (e) {
      return "Erro ao atualizar dispositivo";
    }
  }

  _fetchGroupAndQueue() async {
    await _fetchGroup();
    await _fetchCurrentQueue();
  }

  _fetchGroup() async {
    if (device == null) {
      group = null;
      return;
    }
    group = await _groupController.fetchDeviceGroup(device!);
  }

  _fetchCurrentQueue() async {
    defaultQueue = await _diretoDaNuvemAPI.queueResource.getDefaultQueue();

    if (group == null) {
      return;
    }

    if (group!.currentQueue.isEmpty) {
      currentQueue = null;
      _currentQueueSubscription?.cancel();
      return;
    }

    currentQueue =
        await _diretoDaNuvemAPI.queueResource.get(group!.currentQueue);

    Stream<Queue?>? currentQueueStream =
        _diretoDaNuvemAPI.queueResource.getStream(group!.currentQueue);

    _currentQueueSubscription?.cancel();
    _currentQueueSubscription = currentQueueStream.listen((queue) {
      currentQueue = queue;
      notifyListeners();
    },
    onError: (e) {
      debugPrint("Erro ao escutar stream de fila ativa: $e");
    });
  }

  Future _loadDevices() async {
    _devices = await _diretoDaNuvemAPI.deviceResource.getAll();
    Stream<List<Device>>? devicesStream = _diretoDaNuvemAPI
        .deviceResource.getAllStream();

    _devicesSubscription?.cancel();
    _devicesSubscription = devicesStream.listen((updatedDevices) async {
      try {
        device = updatedDevices.firstWhere((d) => d.id == device!.id);
      } catch (e) {
        debugPrint("Erro ao atualizar dispositivo atual na stream: $e");
      }
      _updateCurrentQueueAndGroup();
      _devices = updatedDevices;
      notifyListeners();
    },
    onError: (e) {
      debugPrint("Erro ao escutar stream de dispositivos: $e");
    });
  }

  _updateCurrentQueueAndGroup() async {
    await _fetchGroupAndQueue();
    notifyListeners();
  }

  int numberOfDevicesOnGroup(String groupId) {
    int count = 0;
    for (var device in _devices) {
      if (device.groupId == groupId) {
        count++;
      }
    }
    return count;
  }

  List<Device> listDevicesInGroups(Set<String> groupIds) {
    if (groupIds.isEmpty) {
      return _devices;
    }
    List<Device> devicesInGroups = [];
    for (var device in _devices) {
      if (groupIds.contains(device.groupId)) {
        devicesInGroups.add(device);
      }
    }
    return devicesInGroups;
  }
}
