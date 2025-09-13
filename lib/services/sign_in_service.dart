import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SignInService extends ChangeNotifier {
  final auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  SignInService();

  Future<bool> signInWithGoogle() async {
    try {
      GoogleSignInAccount? googleUser;
      googleUser = await googleSignIn.signInSilently();
      googleUser ??= await googleSignIn.signIn();
      if (googleUser == null) return false;

      final GoogleSignInAuthentication googleAuth = await googleUser
          .authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await auth.signInWithCredential(credential);
      debugPrint("Usuário logado");
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint("ERRO ao logar: $e");
      return false;
    }
  }

  signOut() async {
    try {
      await auth.signOut();
      googleSignIn.disconnect();
      debugPrint('Deslogado');
      notifyListeners();
    } catch (e) {
      debugPrint("ERRO deslogando:\n$e");
    }
  }

  User? getFirebaseAuthUser() {
    return auth.currentUser;
  }

  bool isLoggedIn() {
    return getFirebaseAuthUser() != null;
  }
}
