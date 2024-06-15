import 'package:ddnuvem/models/user.dart';
import 'package:ddnuvem/services/direto_da_nuvem/direto_da_nuvem_service.dart';
import 'package:ddnuvem/services/sign_in_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserController extends ChangeNotifier {
  final SignInService _signInService;
  final DiretoDaNuvemAPI _diretoDaNuvemAPI;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  UserController(this._signInService, this._diretoDaNuvemAPI) {
    isLoggedIn = _signInService.checkUserLoggedIn();
  }

  bool isAdmin = false;
  bool isSuperAdmin = false;
  bool isInstaller = false;
  late bool isLoggedIn;

  getUserPrivileges() async {
    UserPrivilege privilege = await _diretoDaNuvemAPI.userResource
        .getUserPrivileges(_firebaseAuth.currentUser!.uid);

    isAdmin = privilege.isAdmin;
    isSuperAdmin = privilege.isSuperAdmin;
    isInstaller = privilege.isInstaller;
    notifyListeners();
  }

  login() async {
    await _signInService.signInWithGoogle();
    await getUserPrivileges();
    isLoggedIn = true;
    notifyListeners();
  }

  logout() async {
    await _signInService.signOut();
    isLoggedIn = false;
    notifyListeners();
  }
}
