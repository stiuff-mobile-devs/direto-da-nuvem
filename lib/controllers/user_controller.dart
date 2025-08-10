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

  String? userEmail;
  String? uid;
  bool isAdmin = false;
  bool isSuperAdmin = false;
  bool isInstaller = false;
  late bool isLoggedIn;
  bool loadingInitialState = true;

  UserController(this._signInService, this._diretoDaNuvemAPI) {
    loadingInitialState = true;
    isLoggedIn = _signInService.checkUserLoggedIn();

    if (isLoggedIn) {
      _getUserPrivileges();
    } else {
      isLoggedIn = false;
      uid = null;
      userEmail = null;
      loadingInitialState = false;
      notifyListeners();
    }
  }

  login(BuildContext context) async {
    bool signedIn = await _signInService.signInWithGoogle();
    if (!signedIn) {
      return;
    }

    final currentUser = _firebaseAuth.currentUser;
    uid = currentUser!.uid;
    userEmail = currentUser.email;
    await _getUserPrivileges();
    isLoggedIn = true;
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
    userEmail = null;
    isLoggedIn = false;
    notifyListeners();
  }

  _getUserPrivileges() async {
    final currentUser = _firebaseAuth.currentUser;
    userEmail = currentUser!.email;
    uid = currentUser.uid;

    UserPrivileges privileges = await _diretoDaNuvemAPI.userResource
        .getUserPrivileges(currentUser.uid);

    isAdmin = privileges.isAdmin;
    isSuperAdmin = privileges.isSuperAdmin;
    isInstaller = privileges.isInstaller;

    loadingInitialState = false;
    notifyListeners();
  }
}
