import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SignInService {
  final auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  SignInService();

  Future<GoogleSignInAccount?> signInWithGoogle() async {
    try {
      return await googleSignIn.signIn();
    } catch (e) {
      debugPrint("ERRO ao pegar dados da conta do Google: $e");
      return null;
    }
  }

  Future<bool> completeSignIn(GoogleSignInAccount googleUser) async {
    try {
      final GoogleSignInAuthentication googleAuth = await googleUser
          .authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await auth.signInWithCredential(credential);
      debugPrint("Usuário logado");
      return true;
    } catch (e) {
      debugPrint("ERRO ao logar: $e");
      return false;
    }
  }

  signOut() async {
    try {
      await auth.signOut();
      await googleSignIn.signOut();
      debugPrint('Deslogado');
    } catch (e) {
      debugPrint("ERRO deslogando:\n$e");
    }
  }

  User? getFirebaseAuthUser() {
    return auth.currentUser;
  }
}
