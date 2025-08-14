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
  bool isLoggedIn = false;
  bool loadingInitialState = true;

  UserController(this._signInService, this._diretoDaNuvemAPI);

  Future<void> init() async {
    loadingInitialState = true;
    notifyListeners();

    if (_signInService.checkIfLoggedIn()) {
      await _getCurrentUserInfo();
      isLoggedIn = true;
      await _loadAllUsers();
    } else {
      isLoggedIn = false;
      currentUser = null;
      profileImageUrl = null;
    }

    loadingInitialState = false;
    notifyListeners();
  }

  login(BuildContext context) async {
    bool signedIn = await _signInService.signInWithGoogle();
    if (!signedIn) {
      currentUser = User.empty();
      isLoggedIn = true;
    } else {
      await _getCurrentUserInfo();
      await _loadAllUsers();
      isLoggedIn = true;
    }

    notifyListeners();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const RedirectionPage()),
      (Route<dynamic> route) => false,
    );
  }

  logout() async {
    if (currentUser!.id.isNotEmpty) {
      await _signInService.signOut();
    }
    currentUser = null;
    profileImageUrl = null;
    users = [];
    isLoggedIn = false;
    notifyListeners();
  }

  _getCurrentUserInfo() async {
    final fbAuthUser = _signInService.getFirebaseAuthUser();
    profileImageUrl = fbAuthUser?.photoURL;
    currentUser = await _diretoDaNuvemAPI.userResource.get(fbAuthUser!.uid);
    loadingInitialState = false;
    notifyListeners();
  }

  _loadAllUsers() async {
    if (currentUser!.privileges.isSuperAdmin || currentUser!.privileges.isAdmin) {
      users = await _diretoDaNuvemAPI.userResource.listAll();
      notifyListeners();
    }
  }

  Future<String> createUser(User user) async {
    if (await _diretoDaNuvemAPI.userResource.create(user)) {
      _loadAllUsers();
      notifyListeners();
      return "Usuário criado com sucesso!";
    }

    return "Usuário já existe.";
  }

  Future<String> updateUser(User user) async {
    await _diretoDaNuvemAPI.userResource.update(user);
    notifyListeners();
    return "Usuário atualizado com sucesso!";
  }

  Future<bool> verifyAdminPrivilege(List<String> emails) async {
    for (var e in emails) {
      if (!await _diretoDaNuvemAPI.userResource.userIsAdmin(e)) {
        return false;
      }
    }
    return true;
  }
}
