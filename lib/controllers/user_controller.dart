import 'package:ddnuvem/models/user.dart';
import 'package:ddnuvem/services/direto_da_nuvem/direto_da_nuvem_service.dart';
import 'package:ddnuvem/services/sign_in_service.dart';
import 'package:ddnuvem/views/redirection_page.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:flutter/material.dart';

class UserController extends ChangeNotifier {
  final SignInService _signInService;
  final DiretoDaNuvemAPI _diretoDaNuvemAPI;
  final fb_auth.FirebaseAuth _firebaseAuth = fb_auth.FirebaseAuth.instance;

  User? currentUser;
  bool isLoggedIn = false;
  bool loadingInitialState = true;

  UserController(this._signInService, this._diretoDaNuvemAPI) {
    loadingInitialState = true;
    isLoggedIn = _firebaseAuth.currentUser != null;

    if (isLoggedIn) {
      _getCurrentUserInfo();
    } else {
      currentUser = null;
      loadingInitialState = false;
      notifyListeners();
    }
  }

  login(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);

    bool signedIn = await _signInService.signInWithGoogle();
    if (!signedIn) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text("Usuário não autorizado!"),
          backgroundColor: Colors.red,
        ),
      );
      isLoggedIn = false;
    } else {
      await _getCurrentUserInfo();
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
    await _signInService.signOut();
    currentUser = null;
    isLoggedIn = false;
    notifyListeners();
  }

  _getCurrentUserInfo() async {
    final fbAuthUser = _firebaseAuth.currentUser;
    currentUser = await _diretoDaNuvemAPI.userResource.get(fbAuthUser!.uid);
    loadingInitialState = false;
    notifyListeners();
  }

  Future<String> createUser(User user) async {
    return await _diretoDaNuvemAPI.userResource.create(user);
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
