import 'dart:async';
import 'package:ddnuvem/models/device.dart';
import 'package:ddnuvem/models/group.dart';
import 'package:ddnuvem/services/direto_da_nuvem/direto_da_nuvem_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class GroupController extends ChangeNotifier {
  final DiretoDaNuvemAPI _diretoDaNuvemAPI;

  Group? selectedGroup;
  List<Group> groups = [];
  bool isAdmin = false;

  StreamSubscription<List<Group>>? _groupsSubscription;

  GroupController(this._diretoDaNuvemAPI) {
    init();
  }

  init() async {
    notifyListeners();
    await _fetchAllGroups();
    isAdmin = groups
        .map((group) => group.admins)
        .expand((admins) => admins)
        .toSet()
        .contains(FirebaseAuth.instance.currentUser?.email);
    notifyListeners();
  }

  @override
  void dispose() {
    _groupsSubscription?.cancel();
    super.dispose();
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
    groups = await _diretoDaNuvemAPI.groupResource.getAll();
    Stream<List<Group>>? groupsStream = _diretoDaNuvemAPI
        .groupResource.getAllStream();

    _groupsSubscription?.cancel();
    _groupsSubscription = groupsStream.listen((updatedGroups) {
      groups = updatedGroups;

      if (selectedGroup != null) {
        try {
          selectedGroup = groups.firstWhere(
                  (group) => group.id == selectedGroup!.id);
        } catch (e) {
          selectedGroup = null;
        }
      }
      notifyListeners();
    },
    onError: (e) {
      debugPrint("Erro ao escutar stream de grupos: $e");
    });
  }

  Future<Group?> fetchDeviceGroup(Device device) async {
    return await _diretoDaNuvemAPI.groupResource.get(device.groupId);
  }

  Future<String> createGroup(Group group) async {
    notifyListeners();
    await _diretoDaNuvemAPI.groupResource.create(group);
    notifyListeners();
    return "Grupo criado com sucesso!";
  }

  Future<String> deleteGroup(String groupId) async {
    await _diretoDaNuvemAPI.groupResource.delete(selectedGroup!.id);
    notifyListeners();
    return "Grupo excluído com sucesso!";
  }

  Future<String> updateGroup(Group group) async {
    notifyListeners();
    await _diretoDaNuvemAPI.groupResource.update(group);
    int index = groups.indexWhere((g) => g.id == group.id);
    groups[index] = group;
    notifyListeners();
    return "Grupo atualizado com sucesso!";
  }

  Future removeAdministeredGroups(String email, String removedBy) async {
    List<Group> g = groups.where((group) => group.admins.contains(email)).toList();
    for (var group in g) {
      group.admins.remove(email);
      group.updatedAt = DateTime.now();
      group.updatedBy = removedBy;
      await updateGroup(group);
    }
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
