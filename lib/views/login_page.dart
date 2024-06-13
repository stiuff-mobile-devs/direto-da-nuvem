import 'package:ddnuvem/controllers/user_controller.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:sign_in_button/sign_in_button.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late UserController userController;
  String packageVersion = "";

  getDependencies() {
    userController =
        Provider.of<UserController>(context, listen: false);
  }

  @override
  void initState() {
    getPackageVersion();
    getDependencies();
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.all(25.0),
              child: Text("Direto da Nuvem"),
            ),
            const SizedBox(height: 25),
            SizedBox(
              height: 40,
              child: SignInButton(
                Buttons.googleDark,
                text: "Entrar com o Google",
                onPressed: userController.login,
              ),
            ),
            const SizedBox(height: 25),
            Text("v $packageVersion"),
          ],
        ),
      ),
    );

    // return Scaffold(
    //   body: FutureBuilder<bool>(
    //     future: _googleSignInHandler.checkUserLoggedIn(),
    //     builder: (context, snapshot) {
    //       if (snapshot.connectionState == ConnectionState.waiting) {
    //         return const Center(child: CircularProgressIndicator());
    //       } else if (snapshot.hasError) {
    //         return Center(child: Text('Error: ${snapshot.error}'));
    //       } else if (snapshot.data == true) {
    //         WidgetsBinding.instance.addPostFrameCallback((_) {
    //           Navigator.pushNamedAndRemoveUntil(
    //               context, RoutePaths.dashboard, (route) => false);
    //         });
    //         return Container();
    //       } else {
    //         return Center(
    //           child: Column(
    //             mainAxisAlignment: MainAxisAlignment.center,
    //             children: [
    //               const Padding(
    //                 padding: EdgeInsets.all(25.0),
    //                 child: Text("Desconectado"),
    //               ),
    //               const SizedBox(height: 25),
    //               SizedBox(
    //                 height: 40,
    //                 child: SignInButton(
    //                   Buttons.googleDark,
    //                   text: "Entrar com o Google",
    //                   onPressed: userController.signInWithGoogle,
    //                 ),
    //               ),
    //               const SizedBox(height: 25),
    //               Text("v $packageVersion"),
    //             ],
    //           ),
    //         );
    //       }
    //     },
    //   ),
    // );
  }
}
