import 'package:ddnuvem/models/device.dart';
import 'package:ddnuvem/models/group.dart';
import 'package:ddnuvem/services/direto_da_nuvem/direto_da_nuvem_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ddnuvem/controllers/device_controller.dart';

class GroupController extends ChangeNotifier {
  final DiretoDaNuvemAPI _diretoDaNuvemAPI;

  Group? selectedGroup;
  List<Group> groups = [];
  Stream<List<Group>>? groupsStream;
  Group? currentDeviceGroup;
  bool loading = false;
  bool isAdmin = false;

  GroupController(this._diretoDaNuvemAPI);

  init() async {
    loading = true;
    notifyListeners();
    await _fetchAllGroups();
    isAdmin = groups
        .map((group) => group.admins)
        .expand((admins) => admins)
        .toSet()
        .contains(FirebaseAuth.instance.currentUser?.email);
    loading = false;
    notifyListeners();
  }

  List<Group> getAdminGroups(bool isSuperAdmin) {
    if (isSuperAdmin) {
      return groups;
    }
    return groups
        .where((element) =>
            element.admins.contains(FirebaseAuth.instance.currentUser!.email))
        .toList();
  }

  _fetchAllGroups() async {
    groups = await _diretoDaNuvemAPI.groupResource.listAll();
    groupsStream = _diretoDaNuvemAPI.groupResource.listAllStream();

    groupsStream?.listen((updatedGroups) {
      groups = updatedGroups;
      notifyListeners();
    });
  }

  Future<Group?> fetchDeviceGroup(Device device) async {
    currentDeviceGroup = await _diretoDaNuvemAPI.groupResource.get(device.groupId);
    return currentDeviceGroup;
  }

  Future<String> createGroup(Group group) async {
    loading = true;
    notifyListeners();
    await _diretoDaNuvemAPI.groupResource.create(group);
    groups.add(group);
    loading = false;
    notifyListeners();
    return "Grupo criado com sucesso!";
  }

  Future<String> updateGroup(Group group) async {
    loading = true;
    notifyListeners();
    await _diretoDaNuvemAPI.groupResource.update(group);
    int index = groups.indexWhere((g) => g.id == group.id);
    groups[index] = group;
    loading = false;
    notifyListeners();
    return "Grupo atualizado com sucesso!";
  }

  selectGroup(Group group) {
    selectedGroup = group;
    notifyListeners();
  }

  Future<String> makeQueueCurrent(String queueId) async {
    selectedGroup?.currentQueue = queueId;
    await _diretoDaNuvemAPI.groupResource.update(selectedGroup!);
    notifyListeners();
    return "Fila ativa atualizada com sucesso!";
  }
}
