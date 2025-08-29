import 'dart:async';

import 'package:ddnuvem/models/user.dart';
import 'package:ddnuvem/services/direto_da_nuvem/direto_da_nuvem_service.dart';
import 'package:ddnuvem/services/sign_in_service.dart';
import 'package:ddnuvem/views/redirection_page.dart';
import 'package:flutter/material.dart';

class UserController extends ChangeNotifier {
  final SignInService _signInService;
  final DiretoDaNuvemAPI _diretoDaNuvemAPI;

  List<User> users = [];
  User? currentUser;
  String? profileImageUrl;

  StreamSubscription<List<User>>? _usersSubscription;
  bool isLoggedIn = false;
  bool loadingInitialState = true;

  UserController(this._signInService, this._diretoDaNuvemAPI);

  Future init() async {
    loadingInitialState = true;
    notifyListeners();

    if (_signInService.checkIfLoggedIn()) {
      await _getCurrentUserInfo();
      isLoggedIn = true;
    } else {
      isLoggedIn = false;
      currentUser = null;
      profileImageUrl = null;
    }

    loadingInitialState = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _usersSubscription?.cancel();
    super.dispose();
  }

  login(BuildContext context) async {
    if (!await _signInService.signInWithGoogle()) {
      isLoggedIn = false;
      return;
    }

    await _getCurrentUserInfo();
    isLoggedIn = true;
    notifyListeners();

    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const RedirectionPage()),
            (Route<dynamic> route) => false,
      );
    }
  }

  logout() async {
    await _signInService.signOut();
    currentUser = null;
    profileImageUrl = null;
    users = [];
    isLoggedIn = false;
    notifyListeners();
  }

  _getCurrentUserInfo() async {
    final fbAuthUser = _signInService.getFirebaseAuthUser();
    profileImageUrl = fbAuthUser?.photoURL;
    User? user = await _diretoDaNuvemAPI.userResource.get(fbAuthUser!.email!);
    currentUser = user ?? User.empty();
    await loadAllUsers();
  }

  loadAllUsers() async {
    if (currentUser!.privileges.isSuperAdmin) {
      users = await _diretoDaNuvemAPI.userResource.getAll();

      Stream<List<User>>? usersStream =
          _diretoDaNuvemAPI.userResource.getAllStream();

      _usersSubscription?.cancel();
      _usersSubscription = usersStream.listen((updatedUsers) {
        users = updatedUsers;
        notifyListeners();
      },
      onError: (e) {
        debugPrint("Erro ao escutar stream de usuários: $e");
      });
    }
  }

  Future<String> createUser(User user) async {
    if (await _diretoDaNuvemAPI.userResource.create(user)) {
      notifyListeners();
      return "Usuário criado com sucesso!";
    }

    return "Usuário já existe.";
  }

  Future<String> deleteUser(User user) async {
    await _diretoDaNuvemAPI.userResource.delete(user);
    notifyListeners();
    return "Usuário excluído com sucesso!";
  }

  Future<String> updateUser(User user) async {
    await _diretoDaNuvemAPI.userResource.update(user);
    notifyListeners();
    return "Usuário atualizado com sucesso!";
  }

  Future updateGroupAdmins(List<String> emails) async {
    for (var e in emails) {
      User? user = await _diretoDaNuvemAPI.userResource.get(e);
      if (user == null) {
        user = User.empty();
        user.email = e;
        user.createdBy = currentUser!.uid;
        user.updatedBy = currentUser!.uid;
        user.privileges.isAdmin = true;
        await _diretoDaNuvemAPI.userResource.create(user);
      } else {
        if (!user.privileges.isAdmin) {
          user.privileges.isAdmin = true;
          user.updatedAt = DateTime.now();
          user.updatedBy = currentUser!.uid;
          await _diretoDaNuvemAPI.userResource.update(user);
        }
      }
    }
  }

  List<User> getUsersByPrivilege(Set<String> privileges) {
    if (privileges.isEmpty) return users;

    return users.where((user) {
      final userPrivs = <String>{
        if (user.privileges.isSuperAdmin) 'Super Admin',
        if (user.privileges.isAdmin) 'Admin',
        if (user.privileges.isInstaller) 'Instalador',
      };
      return userPrivs.intersection(privileges).isNotEmpty;
    }).toList();
  }

  List<User> getUsersByPrivilegeAndQuery(Set<String> privileges, String query) {
    final filtered = getUsersByPrivilege(privileges);
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return filtered;
    return filtered.where((u) => 
      u.name.toLowerCase().contains(q) ||
      u.email.toLowerCase().contains(q)
    ).toList();
  }
}
