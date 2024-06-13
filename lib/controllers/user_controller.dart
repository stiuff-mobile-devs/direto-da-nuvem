import 'package:ddnuvem/services/sign_in_service.dart';
import 'package:flutter/material.dart';

class UserController extends ChangeNotifier {
  final SignInService _signInService;

  UserController(this._signInService) {
    isLoggedIn = _signInService.checkUserLoggedIn();
  }
  
  bool isAdmin = false;
  late bool isLoggedIn;

  login() async {
    await _signInService.signInWithGoogle();
    isLoggedIn = true;
    notifyListeners();
  }

  logout() async {
    await _signInService.signOut();
    isLoggedIn = false;
    notifyListeners();
  }
}