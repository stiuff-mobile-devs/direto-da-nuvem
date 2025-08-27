import 'package:ddnuvem/models/user.dart';
import 'package:ddnuvem/services/direto_da_nuvem/direto_da_nuvem_service.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SignInService {
  BuildContext context;
  final DiretoDaNuvemAPI _diretoDaNuvemAPI;
  SignInService(this.context, this._diretoDaNuvemAPI);

  final auth = fb_auth.FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

    if (googleUser == null) {
      return;
    }

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final credential = fb_auth.GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    await auth.signInWithCredential(credential);

    User? user = await _diretoDaNuvemAPI.userResource.get(googleUser.email);

    if (user == null) {
      return;
    }

    // Usuário está logando pela primeira vez, registrar uid no Firestore
    if (user.uid.isEmpty) {
      user.uid = auth.currentUser!.uid;
      user.name = googleUser.displayName ?? "";
      user.updatedAt = DateTime.now();
      user.updatedBy = auth.currentUser!.uid;
      await _diretoDaNuvemAPI.userResource.update(user);
    }
  }

  Future signOut() async {
    try {
      await auth.signOut();
      await googleSignIn.signOut();
      debugPrint('Deslogado');
    } catch (e) {
      debugPrint("ERRO deslogando:\n$e");
    }
  }

  bool checkIfLoggedIn() {
    final user = getFirebaseAuthUser();
    return user == null ? false : true;
  }

  fb_auth.User? getFirebaseAuthUser() {
    return auth.currentUser;
  }
}
