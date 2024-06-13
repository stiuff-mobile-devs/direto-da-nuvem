import 'package:ddnuvem/routes/route_paths.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:sign_in_button/sign_in_button.dart';
import 'package:flutter/material.dart';

import '../services/google_sign_in.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late GoogleSignInHandler _googleSignInHandler;
  String packageVersion = "";

  @override
  void initState() {
    getPackageVersion();
    _googleSignInHandler = Provider.of<GoogleSignInHandler>(context,listen: false);
    super.initState();
  }

  Future<void> getPackageVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      packageVersion = packageInfo.version;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<bool>(
        future: _googleSignInHandler.checkUserLoggedIn(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.data == true) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushNamedAndRemoveUntil(
                  context, RoutePaths.dashboard, (route) => false);
            });
            return Container();
          } else {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(25.0),
                    child: Text("Desconectado"),
                  ),
                  const SizedBox(height: 25),
                  SizedBox(
                    height: 40,
                    child: SignInButton(
                      Buttons.googleDark,
                      text: "Entrar com o Google",
                      onPressed: _googleSignInHandler.signInWithGoogle,
                    ),
                  ),
                  const SizedBox(height: 25),
                  Text("v $packageVersion"),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
