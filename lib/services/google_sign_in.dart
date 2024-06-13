import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ddnuvem/routes/route_paths.dart';
import 'package:ddnuvem/services/direto_da_nuvem/direto_da_nuvem_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:ddnuvem/models/user.dart' as models;

class GoogleSignInHandler {
  BuildContext context;
  DiretoDaNuvemAPI diretoDaNuvemAPI;
  GoogleSignInHandler(this.context, this.diretoDaNuvemAPI);

  final auth = FirebaseAuth.instance;
  final db = FirebaseFirestore.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  UserCredential? userCredential;

  Future<void> signInWithGoogle() async {
    if (auth.currentUser != null) {
      try {
        await auth.signOut();
        await googleSignIn.signOut();
        Navigator.pushNamedAndRemoveUntil(
            context, RoutePaths.login, (route) => false);
        debugPrint('Deslogado');
      } catch (e) {
        debugPrint("ERRO deslogando:\n$e");
      }
    } else {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );
      debugPrint('googleUser: $googleUser');
      debugPrint('googleAuth: $googleAuth');
      userCredential = await auth.signInWithCredential(credential);
      await diretoDaNuvemAPI.userResource
          .create(models.User.fromFirebaseUser(auth.currentUser!));
      Navigator.pushReplacementNamed(
          context, RoutePaths.dashboard);
    }
  }

  Future<bool> checkUserLoggedIn() async {
    return auth.currentUser != null;
  }
}
