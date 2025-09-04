import 'package:ddnuvem/controllers/device_controller.dart';
import 'package:ddnuvem/models/user.dart';
import 'package:ddnuvem/services/direto_da_nuvem/direto_da_nuvem_service.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';

class SignInService {
  BuildContext context;
  final DiretoDaNuvemAPI _diretoDaNuvemAPI;
  SignInService(this.context, this._diretoDaNuvemAPI);

  final auth = fb_auth.FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  Future<bool> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser;
    User? user;

    try {
      googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        return false;
      }

      user = await _diretoDaNuvemAPI.userResource.get(googleUser.email);

      if (user == null) {
        debugPrint("Usuário não autorizado");
        return true;
      }

      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      final credential = fb_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await auth.signInWithCredential(credential);
    } catch (e) {
      debugPrint("ERRO ao logar: $e");
      return false;
    }

    // Usuário está logando pela primeira vez, registrar uid no Firestore
    if (user.uid.isEmpty) {
      user.uid = auth.currentUser!.uid;
      user.name = googleUser.displayName ?? "";
      user.updatedAt = DateTime.now();
      user.updatedBy = auth.currentUser!.uid;
      await _diretoDaNuvemAPI.userResource.update(user);
    }

    return true;
  }

  Future signOut() async {
    try {
      await auth.signOut();
      await googleSignIn.signOut();
      if (context.mounted) {
        context.read<DeviceController>().resetInMemory();
      }
      debugPrint('Deslogado');
    } catch (e) {
      debugPrint("ERRO deslogando:\n$e");
    }
  }

  bool checkIfLoggedIn() {
    final user = getFirebaseAuthUser();
    return user != null;
  }

  fb_auth.User? getFirebaseAuthUser() {
    return auth.currentUser;
  }
}
