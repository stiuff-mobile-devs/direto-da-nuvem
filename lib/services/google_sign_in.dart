import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ddnuvem/routes/route_paths.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInHandler {
  BuildContext context;
  GoogleSignInHandler(this.context);

  final auth = FirebaseAuth.instance;
  final db = FirebaseFirestore.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  UserCredential? userCredential;

  Future<void> signInWithGoogle() async {
    if (auth.currentUser != null) {
      try {
        await auth.signOut();
        await googleSignIn.signOut();
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
        debugPrint('Deslogado');
      } catch(e) {
        debugPrint("ERRO deslogando:\n$e");
      }
    } else {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );
      debugPrint('googleUser: $googleUser');
      debugPrint('googleAuth: $googleAuth');
      userCredential = await auth.signInWithCredential(credential);
      Navigator.pushNamedAndRemoveUntil(context, '/dashboard', (route) => false);
    }
  }

  Future<bool> checkUserLoggedIn() async {
    return auth.currentUser != null;
  }
}