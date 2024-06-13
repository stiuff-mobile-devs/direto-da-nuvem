import 'package:ddnuvem/controllers/user_controller.dart';
import 'package:ddnuvem/services/local_storage/booleans.dart';
import 'package:ddnuvem/services/local_storage/local_storage_service.dart';
import 'package:ddnuvem/services/sign_in_service.dart';
import 'package:ddnuvem/views/dashboard_page.dart';
import 'package:ddnuvem/views/intro_page.dart';
import 'package:ddnuvem/views/login_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RedirectionData {
  bool firstTime;
  bool loggedIn;
  bool isAdmin;
  bool isDeviceRegistered;

  RedirectionData(
      {this.firstTime = false,
      this.loggedIn = false,
      this.isAdmin = false,
      this.isDeviceRegistered = false});
}

//TODO:
//   | Logado | Cadastrado | Admin |
//   |   V    |     V      |   V   | AdminPage
//   |   V    |     V      |   F   | ViewPage
//   |   V    |     F      |   V   | CadastrarDevice
//   |   V    |     F      |   F   | Erro e Mensagem
//   |   F    |     V      |   F   | Login
//   |   F    |     F      |   V   | Login
//   |   F    |     F      |   F   | Login
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  late LocalStorageService localStorageService;
  late SignInService signInService;

  getDependencies() {
    localStorageService =
        Provider.of<LocalStorageService>(context, listen: false);
    signInService = Provider.of<SignInService>(context, listen: false);
  }

  Future<RedirectionData> getRedirectionData() async {
    bool firstTime =
        await localStorageService.readBool(LocalStorageBooleans.firstTime) ??
            true;

    RedirectionData redirectionData = RedirectionData(firstTime: firstTime);

    signInService.signInWithGoogle();

    return redirectionData;
  }

  @override
  void initState() {
    super.initState();
    getDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getRedirectionData(),
        builder: (context, snapshot) {
          if (snapshot.data == null) {
            return const Center(child: CircularProgressIndicator());
          }
          return ChangeNotifierProvider(
            create: (context) => UserController(context.read()),
            child: Consumer<UserController>(
              builder: (context, value, child) {
                snapshot.data!.loggedIn = value.isLoggedIn;
                return handleRedirection(snapshot.data!);
              },
            ),
          );
        });
  }

  Widget loading() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget handleRedirection(RedirectionData redirectionData) {
    if (redirectionData.firstTime) {
      return const IntroPage();
    }
    if (!redirectionData.loggedIn) {
      return const LoginPage();
    }
    return const DashboardPage();
  }
}
