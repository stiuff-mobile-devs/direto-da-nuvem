import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ddnuvem/services/direto_da_nuvem/direto_da_nuvem_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:ddnuvem/models/user.dart' as models;

class SignInService {
  BuildContext context;
  final DiretoDaNuvemAPI _diretoDaNuvemAPI;
  SignInService(this.context, this._diretoDaNuvemAPI);

  final auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  Future<bool> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

    final validUser = await _diretoDaNuvemAPI.userResource
        .userIsValid(googleUser!.email);
    if (validUser == null) {
      await googleSignIn.disconnect();
      return false;
    }

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    await auth.signInWithCredential(credential);

    // Usuário está logando pela primeira vez, registrar uid no Firestore
    if (validUser['uid']!.isEmpty) {
      await _diretoDaNuvemAPI.userResource
          .updateAuthenticatedUser(validUser['id']!,
          auth.currentUser!.uid,
          googleUser.displayName ?? ""
      );
    }

    return true;
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
}
