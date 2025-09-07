import 'dart:async';
import 'package:ddnuvem/models/device.dart';
import 'package:ddnuvem/models/group.dart';
import 'package:ddnuvem/models/queue.dart';
import 'package:ddnuvem/services/direto_da_nuvem/direto_da_nuvem_service.dart';
import 'package:ddnuvem/services/sign_in_service.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';

class DeviceController extends ChangeNotifier {
  final DiretoDaNuvemAPI _diretoDaNuvemAPI;
  final SignInService _signInService;
  final DeviceInfoPlugin _deviceInfoPlugin = DeviceInfoPlugin();

  AndroidDeviceInfo? androidInfo;
  Group? group;
  Device? device;
  bool isRegistered = false;
  bool isSmartphone = false;
  Queue? currentQueue;
  Queue? defaultQueue;
  List<Device> devices = [];

  StreamSubscription<Queue?>? _currentQueueSubscription;
  StreamSubscription<Group?>? _currentGroupSubscription;
  StreamSubscription<List<Device>>? _devicesSubscription;
  bool loadingInitialState = true;

  DeviceController(this._diretoDaNuvemAPI, this._signInService) {
    _initialize();
    _signInService.addListener(_signInListener);
  }

  _initialize() async {
    await _getAndroidInfo();
    if (_signInService.isLoggedIn()) {
      await _checkIsRegistered();
      await _fetchGroupAndQueue();
      await loadDevices();
    }
    loadingInitialState = false;
    notifyListeners();
    debugPrint("DeviceController initialized");
  }

  @override
  void dispose() {
    _currentQueueSubscription?.cancel();
    _devicesSubscription?.cancel();
    _currentGroupSubscription?.cancel();
    _signInService.removeListener(_signInListener);
    debugPrint("DeviceController disposed");
    super.dispose();
  }

  _signInListener() async {
    if (_signInService.isLoggedIn()) {
      await _checkIsRegistered();
      await _fetchGroupAndQueue();
      await loadDevices();
      notifyListeners();
    } else {
      _signOutClear();
    }
  }

  _signOutClear() {
    group = null;
    currentQueue = null;
    devices = [];
    _currentQueueSubscription?.cancel();
    _currentGroupSubscription?.cancel();
    _devicesSubscription?.cancel();
  }

  Future<void> _getAndroidInfo() async {
    try {
      androidInfo = await _deviceInfoPlugin.androidInfo;
      if (androidInfo != null) {
        isSmartphone = !androidInfo!.systemFeatures
            .contains("android.software.leanback");
      }
    } catch (e) {
      debugPrint("Erro ao obter dados do android: $e");
      androidInfo = null;
    }
  }

  _checkIsRegistered() async {
    if (androidInfo != null) {
      device = await _diretoDaNuvemAPI.deviceResource.get(androidInfo!.id);
      isRegistered = (device != null);
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
    if (device != null) {
      group = await _diretoDaNuvemAPI.groupResource.get(device!.groupId);
      Stream<Group?>? deviceGroupStream = _diretoDaNuvemAPI.groupResource
          .getStream(device!.groupId);

      _currentGroupSubscription?.cancel();
      _currentGroupSubscription = deviceGroupStream.listen((group) {
        this.group = group;
        _fetchCurrentQueue();
        notifyListeners();
      },
      onError: (e) {
        debugPrint("Erro ao escutar stream do grupo do dispositivo: $e");
      });
    }
  }

  _fetchCurrentQueue() async {
    if (group == null) {
      return;
    }

    if (group!.currentQueue.isEmpty) {
      currentQueue = null;
      _currentQueueSubscription?.cancel();
      return;
    }

    currentQueue = await _diretoDaNuvemAPI.queueResource
        .get(group!.currentQueue);
    Stream<Queue?>? currentQueueStream = _diretoDaNuvemAPI.queueResource
        .getStream(group!.currentQueue);

    _currentQueueSubscription?.cancel();
    _currentQueueSubscription = currentQueueStream.listen((queue) {
      currentQueue = queue;
      notifyListeners();
    },
    onError: (e) {
      debugPrint("Erro ao escutar stream de fila ativa: $e");
    });
  }

  Future<Queue?> getDefaultQueue() async {
    defaultQueue ??= await _diretoDaNuvemAPI.queueResource.getDefaultQueue();
    return defaultQueue;
  }

  Future loadDevices() async {
    devices = await _diretoDaNuvemAPI.deviceResource.getAll();
    Stream<List<Device>>? devicesStream =
      _diretoDaNuvemAPI.deviceResource.getAllStream();

    _devicesSubscription?.cancel();
    _devicesSubscription = devicesStream.listen((updatedDevices) async {
      final currentId = device?.id;
      devices = updatedDevices;

      if (currentId != null) {
        // Coloca na variável match uma coleção de dispositivos
        // que tenham o mesmo id do dispositivo atual.
        final match = updatedDevices.where((d) => d.id == currentId);

        // Se esta coleção estiver vazia,
        // significa que o dispositivo atual sumiu do backend.
        if (match.isEmpty) {
          // Sumiu do backend => limpar estado
          _clearCurrentDeviceState();
        } else {
          // Se não estiver vazia,
          // então deve haver exatamente um dispositivo com o mesmo id do atual.
          // Coloca este dispositivo na variável device.
          device = match.first;
        }
      }

      if (device == null) {
        _currentQueueSubscription?.cancel();
        group = null;
        currentQueue = null;
      }
      await _fetchGroupAndQueue();
      notifyListeners();
    },
    onError: (e) {
      debugPrint("Erro ao escutar stream de dispositivos: $e");
    });
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

  Future<void> deleteDevice(String id) async {
    await _diretoDaNuvemAPI.deviceResource.delete(id);
    if (device?.id == id) {
      _clearCurrentDeviceState();
    }
  }

  void _clearCurrentDeviceState() {
    _currentQueueSubscription?.cancel();
    _currentGroupSubscription?.cancel();
    currentQueue = null;
    group = null;
    device = null;
    isRegistered = false;
  }
}

