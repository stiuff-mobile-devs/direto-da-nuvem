import 'dart:async';
import 'package:ddnuvem/models/user.dart';
import 'package:ddnuvem/services/direto_da_nuvem/direto_da_nuvem_service.dart';
import 'package:ddnuvem/services/sign_in_service.dart';
import 'package:flutter/foundation.dart';
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

  UserController(this._signInService, this._diretoDaNuvemAPI) {
    _initialize();
  }

  _initialize() async {
    if (_signInService.isLoggedIn()
        || (kIsWeb && await _signInService.signInSilently())) {
      await _loadUserData();
      isLoggedIn = true;
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
    loadingInitialState = true;
    notifyListeners();

    if (await _signInService.signInWithGoogle()) {
      isLoggedIn = true;
      await _getCurrentUserInfo();
      if (isCurrentUserAuthorized() && !currentUser!.authenticated) {
        await updateAuthenticatedUser();
      }
      await _loadAllUsers();
    }

    loadingInitialState = false;
    notifyListeners();
  }

  logout() async {
    await _signInService.signOut();
    currentUser = null;
    profileImageUrl = null;
    users = [];
    _usersSubscription?.cancel();
    isLoggedIn = false;
    notifyListeners();
  }

  _loadUserData() async {
    await _getCurrentUserInfo();
    await _loadAllUsers();
  }

  _getCurrentUserInfo() async {
    final fbAuthUser = _signInService.getFirebaseAuthUser();
    profileImageUrl = fbAuthUser?.photoURL;
    User? user = await _diretoDaNuvemAPI.userResource.get(fbAuthUser!.email!);
    if (user == null) {
      currentUser = User.empty();
      debugPrint("Usuario nao autorizado");
      return;
    }
    currentUser = user;
  }

  _loadAllUsers() async {
    if (!isCurrentUserSuperAdmin()) return;
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

  createUser(User user) async {
    try {
      await _diretoDaNuvemAPI.userResource.create(user);
    } catch (e) {
      rethrow;
    }
  }

  deleteUser(User user) async {
    try {
      await _diretoDaNuvemAPI.userResource.delete(user);
    } catch (e) {
      rethrow;
    }
  }

  updateUser(User user) async {
    try {
      await _diretoDaNuvemAPI.userResource.update(user);
    } catch (e) {
      rethrow;
    }
  }

  // Salva uid e nome de usuário que se autenticou pela primeira vez
  updateAuthenticatedUser() async {
    final authUser = _signInService.getFirebaseAuthUser();
    final uid = authUser?.uid;
    final googleName = authUser?.displayName;
    if (uid == null) return;

    User user = User.copy(currentUser!);
    await _diretoDaNuvemAPI.userResource.delete(user);
    user.id = uid;
    user.name = googleName ?? "";
    user.updatedAt = DateTime.now();
    user.updatedBy = uid;
    user.authenticated = true;
    await _diretoDaNuvemAPI.userResource.createAuthenticatedUser(user);
    currentUser = user;
  }

  // Atualiza ou cria usuário que foi inserido como admin de um grupo
  Future grantAdminPrivilege(List<String> emails) async {
    for (var e in emails) {
      User? user = await _diretoDaNuvemAPI.userResource.get(e);
      if (user == null) {
        user = User.empty();
        user.email = e;
        user.createdBy = currentUser!.id;
        user.updatedBy = currentUser!.id;
        user.privileges.isAdmin = true;
        await _diretoDaNuvemAPI.userResource.create(user);
      } else {
        if (!user.privileges.isAdmin) {
          user.privileges.isAdmin = true;
          user.updatedAt = DateTime.now();
          user.updatedBy = currentUser!.id;
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

  bool isCurrentUserInstaller() {
    if (currentUser == null) return false;
    return currentUser!.privileges.isInstaller;
  }

  bool isCurrentUserAdmin() {
    if (currentUser == null) return false;

    final privilege = currentUser!.privileges;
    return privilege.isSuperAdmin || privilege.isAdmin;
  }

  bool isCurrentUserSuperAdmin() {
    if (currentUser == null) return false;
    return currentUser!.privileges.isSuperAdmin;
  }

  bool isCurrentUserAuthorized() {
    if (currentUser == null) return false;

    final privileges = currentUser!.privileges;
    return privileges.isSuperAdmin
        || privileges.isAdmin
        || privileges.isInstaller;
  }
}
