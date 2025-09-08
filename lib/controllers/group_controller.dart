import 'dart:async';
import 'package:ddnuvem/models/group.dart';
import 'package:ddnuvem/services/direto_da_nuvem/direto_da_nuvem_service.dart';
import 'package:ddnuvem/services/sign_in_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class GroupController extends ChangeNotifier {
  final DiretoDaNuvemAPI _diretoDaNuvemAPI;
  final SignInService _signInService;

  List<Group> groups = [];
  StreamSubscription<List<Group>>? _groupsSubscription;

  GroupController(this._diretoDaNuvemAPI, this._signInService) {
    _initialize();
    _signInService.addListener(_signInListener);
  }

  _initialize() async {
    if (_signInService.isLoggedIn()) {
      await _fetchAllGroups();
    }
  }

  @override
  void dispose() {
    _groupsSubscription?.cancel();
    _signInService.removeListener(_signInListener);
    super.dispose();
  }

  _signInListener() async {
    if (_signInService.isLoggedIn()) {
      await _fetchAllGroups();
    } else {
      _signOutClear();
    }
  }

  _signOutClear() {
    groups = [];
    _groupsSubscription?.cancel();
  }

  _fetchAllGroups() async {
    groups = await _diretoDaNuvemAPI.groupResource.getAll();
    Stream<List<Group>>? groupsStream = _diretoDaNuvemAPI
        .groupResource.getAllStream();

    _groupsSubscription?.cancel();
    _groupsSubscription = groupsStream.listen((updatedGroups) {
      groups = updatedGroups;
      notifyListeners();
    },
    onError: (e) {
      debugPrint("Erro ao escutar stream de grupos: $e");
    });

    notifyListeners();
  }

  createGroup(Group group) async {
    try {
      await _diretoDaNuvemAPI.groupResource.create(group);
    } catch (e) {
      rethrow;
    }
  }

  deleteGroup(String groupId) async {
    try {
      await _diretoDaNuvemAPI.groupResource.delete(groupId);
    } catch (e) {
      rethrow;
    }
  }

  updateGroup(Group group) async {
    try {
      await _diretoDaNuvemAPI.groupResource.update(group);
    } catch (e) {
      rethrow;
    }
  }

  Future removeAdminFromGroups(String email) async {
    List<Group> g = groups.where((group) => group.admins.contains(email)).toList();
    for (var group in g) {
      group.admins.remove(email);
      group.updatedAt = DateTime.now();
      group.updatedBy = _signInService.getFirebaseAuthUser()!.uid;
      await updateGroup(group);
    }
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

  updateCurrentQueue(Group group, String queueId) async {
    try {
      group.currentQueue = queueId;
      await updateGroup(group);
    } catch (e) {
      rethrow;
    }
  }
}
