import 'package:ddnuvem/models/user.dart';
import 'package:ddnuvem/services/direto_da_nuvem/direto_da_nuvem_service.dart';
import 'package:ddnuvem/services/sign_in_service.dart';
import 'package:ddnuvem/views/redirection_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserController extends ChangeNotifier {
  final SignInService _signInService;
  final DiretoDaNuvemAPI _diretoDaNuvemAPI;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  UserController(this._signInService, this._diretoDaNuvemAPI) {
    loadingInitialState = true;
    isLoggedIn = _signInService.checkUserLoggedIn();
    if (isLoggedIn) {
      getUserPrivileges();
    } else {
      isLoggedIn = false;
      uid = null;
      loadingInitialState = false;
      notifyListeners();
    }
  }

  bool isAdmin = false;
  bool isSuperAdmin = false;
  bool isInstaller = false;
  late bool isLoggedIn;
  bool loadingInitialState = true;
  String? userEmail;
  String? uid;

  getUserPrivileges() async {
    UserPrivilege privilege = await _diretoDaNuvemAPI.userResource
        .getUserPrivileges(_firebaseAuth.currentUser!.uid);

    userEmail = _firebaseAuth.currentUser!.email;
    isAdmin = privilege.isAdmin;
    isSuperAdmin = privilege.isSuperAdmin;
    isInstaller = privilege.isInstaller;
    uid = _firebaseAuth.currentUser!.uid;
    loadingInitialState = false;
    notifyListeners();
  }

  login(BuildContext context) async {
    await _signInService.signInWithGoogle();
    await getUserPrivileges();
    isLoggedIn = true;
    uid = _firebaseAuth.currentUser!.uid;
    notifyListeners();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const RedirectionPage()),
      (Route<dynamic> route) => false,
    );
  }

  logout() async {
    await _signInService.signOut();
    uid = null;
    isLoggedIn = false;
    notifyListeners();
  }
}
