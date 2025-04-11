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

  createGroup(String name, String description, List<String> admins) async {
    loading = true;
    notifyListeners();
    Group group = Group(
        name: name,
        description: description,
        currentQueue: "init",
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        admins: admins);
    await diretoDaNuvemAPI.groupResource.create(group);
    groups.add(group);
    loading = false;
    notifyListeners();
  }

  selectGroup(Group group) {
    selectedGroup = group;
    notifyListeners();
  }

  makeQueueCurrent(String queueId) async {
    await diretoDaNuvemAPI.groupResource.update(selectedGroup!);
    selectedGroup?.currentQueue = queueId;
    notifyListeners();
  }
}
