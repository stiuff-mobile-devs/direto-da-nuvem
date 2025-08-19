import 'package:ddnuvem/services/direto_da_nuvem/direto_da_nuvem_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SignInService {
  BuildContext context;
  final DiretoDaNuvemAPI _diretoDaNuvemAPI;
  SignInService(this.context, this._diretoDaNuvemAPI);

  final auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  Future signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

    if (googleUser == null) {
      return;
    }

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    await auth.signInWithCredential(credential);

    final validUser = await _diretoDaNuvemAPI.userResource
        .checkAuthorizedLogin(googleUser.email);

    if (validUser == null) {
      return;
    }

    // Usuário está logando pela primeira vez, registrar uid no Firestore
    if (validUser['uid']!.isEmpty) {
      await _diretoDaNuvemAPI.userResource
          .updateAuthenticatedUser(validUser['id']!,
          auth.currentUser!.uid,
          googleUser.displayName ?? ""
      );
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

  User? getFirebaseAuthUser() {
    return auth.currentUser;
  }
}
