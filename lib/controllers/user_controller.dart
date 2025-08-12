import 'package:ddnuvem/models/user.dart';
import 'package:ddnuvem/services/direto_da_nuvem/direto_da_nuvem_service.dart';
import 'package:ddnuvem/services/sign_in_service.dart';
import 'package:ddnuvem/views/redirection_page.dart';
import 'package:flutter/material.dart';

class UserController extends ChangeNotifier {
  final SignInService _signInService;
  final DiretoDaNuvemAPI _diretoDaNuvemAPI;

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
    } else {
      isLoggedIn = false;
      currentUser = null;
      profileImageUrl = null;
    }

    loadingInitialState = false;
    notifyListeners();
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
    profileImageUrl = null;
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
