import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ddnuvem/services/direto_da_nuvem/direto_da_nuvem_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:ddnuvem/models/user.dart' as models;

class SignInService {
  BuildContext context;
  DiretoDaNuvemAPI diretoDaNuvemAPI;
  SignInService(this.context, this.diretoDaNuvemAPI);

  final auth = FirebaseAuth.instance;
  final db = FirebaseFirestore.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  UserCredential? userCredential;

  Future<void> signInWithGoogle() async {
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
  }

  Future<bool> trySignIn() async {
    final googleUser = await googleSignIn.signInSilently();
    if (googleUser == null) {
      return false;
    }
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    debugPrint('googleUser: $googleUser');
    debugPrint('googleAuth: $googleAuth');
    userCredential = await auth.signInWithCredential(credential);
    await diretoDaNuvemAPI.userResource
        .create(models.User.fromFirebaseUser(auth.currentUser!));
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

  bool checkUserLoggedIn() {
    return auth.currentUser != null;
  }
}
