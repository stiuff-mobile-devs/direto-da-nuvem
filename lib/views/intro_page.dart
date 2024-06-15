import 'package:ddnuvem/controllers/user_controller.dart';
import 'package:ddnuvem/services/local_storage/booleans.dart';
import 'package:ddnuvem/services/local_storage/local_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sign_in_button/sign_in_button.dart';

class IntroPage extends StatefulWidget {
  const IntroPage({super.key});

  @override
  State<IntroPage> createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  late UserController userController;
  late LocalStorageService localStorageService;

  saveFirstTime() async {
    bool firstTime =
        await localStorageService.readBool(LocalStorageBooleans.firstTime) ??
            true;

    if (firstTime) {
      await localStorageService.saveBool(LocalStorageBooleans.firstTime, false);
    }
  }

  getDependencies() {
    localStorageService =
        Provider.of<LocalStorageService>(context, listen: false);
    userController =
        Provider.of<UserController>(context, listen: false);
  }

  @override
  void initState() {
    super.initState();
    getDependencies();
    saveFirstTime();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // TODO: adicionar logo svg
              const Text("Bem vindo ao Direto da Nuvem.\nPara utilizar os nossos serviços é necessária uma conta institucional iduff.\nApós o Login:\nCertifique-se que a sua conta é instaladora.\nEscreva o nome da televisão na qual está sendo instalado, e a adicione a um grupo já existente."),
              const SizedBox(height: 25,),
              SignInButton(
                Buttons.googleDark,
                text: "Entrar com o Google",
                onPressed: userController.login,
              ),
            ],
          ),
        ),
      )
    );
  }
}
