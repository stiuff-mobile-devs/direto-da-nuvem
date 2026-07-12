import 'package:ddnuvem/utils/email_regex.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SignInService extends ChangeNotifier {
  final auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  String? accessToken;

  SignInService();

  Future<bool> signInWithGoogle() async {
    try {
      GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        return false;
      }

      if (!iduffEmailHasMatch(googleUser.email)) {
        final bool isAuthorized = await googleSignIn.requestScopes([
          'https://www.googleapis.com/auth/drive.appdata',
        ]);

        if (!isAuthorized) {
          debugPrint("Google Drive permission denied");
          return false;
        }
      }

      return await _signIn(googleUser);
    } catch (e) {
      debugPrint("Error on sign in with google: $e");
      return false;
    }
  }

  Future<bool> signInSilently() async {
    try {
      final googleUser = await googleSignIn.signInSilently();
      if (googleUser == null) {
        return false;
      }

      // if (!iduffEmailHasMatch(googleUser.email)) {
      //   final bool isAuthorized = await googleSignIn.requestScopes([
      //     'https://www.googleapis.com/auth/drive.appdata',
      //   ]);
      //
      //   if (!isAuthorized) {
      //     debugPrint("Google Drive permission denied");
      //     return false;
      //   }
      // }

      return await _signIn(googleUser);
    } catch (e) {
      debugPrint("Error on sign in silently with google: $e");
      return false;
    }
  }

  Future<bool> _signIn(GoogleSignInAccount googleUser) async {
    try {
      final GoogleSignInAuthentication googleAuth = await googleUser
          .authentication;

      accessToken = googleAuth.accessToken;

      final credential = GoogleAuthProvider.credential(
        accessToken: accessToken,
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

  Future<String?> getAccessToken() async {
    if (accessToken == null) {
      await signInSilently();
    }
    return accessToken!;
  }

  bool isExternalUser() {
    return !iduffEmailHasMatch(getFirebaseAuthUser()!.email!);
  }
}
