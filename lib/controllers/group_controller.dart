import 'package:ddnuvem/models/group.dart';
import 'package:ddnuvem/services/direto_da_nuvem/direto_da_nuvem_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class GroupController extends ChangeNotifier {
  List<Group> groups = [];
  Group? selectedGroup;
  bool loading = false;
  bool isAdmin = false;

  final DiretoDaNuvemAPI diretoDaNuvemAPI;

  GroupController(this.diretoDaNuvemAPI);

  init() async {
    loading = true;
    groups = await diretoDaNuvemAPI.groupResource.listAll();
    isAdmin = groups
        .map((group) => group.admins)
        .expand((admins) => admins!)
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
            element.admins!.contains(FirebaseAuth.instance.currentUser!.email))
        .toList();
  }

  Future<String> createGroup(Group group) async {
    loading = true;
    notifyListeners();
    await diretoDaNuvemAPI.groupResource.create(group);
    groups.add(group);
    loading = false;
    notifyListeners();
    return "Grupo criado com sucesso!";
  }

  Future<String> updateGroup(Group group) async {
    loading = true;
    notifyListeners();
    await diretoDaNuvemAPI.groupResource.update(group);
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
    await diretoDaNuvemAPI.groupResource.update(selectedGroup!);
    notifyListeners();
    return "Fila atual alterada com sucesso!";
  }
}
