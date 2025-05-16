import 'package:ddnuvem/controllers/user_controller.dart';
import 'package:ddnuvem/services/local_storage/booleans.dart';
import 'package:ddnuvem/services/local_storage/local_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
    return OrientationBuilder(
      builder: (context, orientation) {
        if (orientation == Orientation.portrait){
          return Scaffold(
              body: SafeArea(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(25.0),
                          child: SvgPicture.asset(
                              height: 120,
                              'assets/DiretoDaNuvem-JustLogo.svg',
                              semanticsLabel: 'Logo Direto da Nuvem'
                          ),
                        ),
                        const SizedBox(height: 25),
                        const Text("Bem vindo ao Direto da Nuvem.\nPara utilizar os nossos serviços é necessária uma conta institucional iduff.\nApós o Login:\nCertifique-se que a sua conta é instaladora.\nEscreva o nome da televisão na qual está sendo instalado, e a adicione a um grupo já existente."),
                        const SizedBox(height: 25,),
                        SignInButton(
                          Buttons.googleDark,
                          text: "Entrar com o Google",
                          onPressed: () {
                            userController.login(context);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              )
          );
        } else {
          return Scaffold(
            body: SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(25.0),
                        child: SvgPicture.asset(
                          height: 120,
                          'assets/DiretoDaNuvem-JustLogo.svg',
                          semanticsLabel: 'Logo Direto da Nuvem',
                        ),
                      ),
                      Expanded( // Wrap the Column with Expanded
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(width: 25),
                            const Text(
                              "Bem vindo ao Direto da Nuvem.\nPara utilizar os nossos serviços é necessária uma conta institucional iduff.\nApós o Login:\nCertifique-se que a sua conta é instaladora.\nEscreva o nome da televisão na qual está sendo instalado, e a adicione a um grupo já existente.",
                              softWrap: true,
                              overflow: TextOverflow.fade,
                            ),
                            const SizedBox(height: 25),
                            SignInButton(
                              Buttons.googleDark,
                              text: "Entrar com o Google",
                              onPressed: () {
                                userController.login(context);
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }
      }
    );
  }
}
