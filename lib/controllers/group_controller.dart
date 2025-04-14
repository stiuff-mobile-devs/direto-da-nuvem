import 'package:ddnuvem/models/group.dart';
import 'package:ddnuvem/services/direto_da_nuvem/direto_da_nuvem_service.dart';
import 'package:flutter/material.dart';

class GroupController extends ChangeNotifier {
  List<Group> groups = [];
  Group? selectedGroup;
  bool loading = false;

  final DiretoDaNuvemAPI diretoDaNuvemAPI;

  GroupController(this.diretoDaNuvemAPI);

  init() async {
    loading = true;
    notifyListeners();
    groups = await diretoDaNuvemAPI.groupResource.listAll();
    loading = false;
    notifyListeners();
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
    return "Fila atualizada com sucesso!";
  }
}
