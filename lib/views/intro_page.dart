import 'package:ddnuvem/controllers/user_controller.dart';
import 'package:ddnuvem/services/local_storage_service.dart';
import 'package:ddnuvem/utils/loading_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:sign_button/sign_button.dart';

class IntroPage extends StatefulWidget {
  final String packageVersion;
  const IntroPage({super.key, required this.packageVersion});

  @override
  State<IntroPage> createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  late UserController userController;
  late LocalStorageService localStorageService;
  bool isFirstTime = false;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _getDependencies();
    _loadData();
  }

  _getDependencies() {
    localStorageService = context.read<LocalStorageService>();
    userController = context.read<UserController>();
  }

  _loadData() async {
    if (kIsWeb) return;
    await _getIsFirstTime();
    _saveIsFirstTime();
    setState(() {
      loading = false;
    });
  }

  _getIsFirstTime() async {
    try {
      isFirstTime =
          await localStorageService.readBool(LocalStorageBooleans.firstTime) ??
              true;
      debugPrint("getIsFirstTime completed: $isFirstTime");
    } catch (e) {
      isFirstTime = true;
      debugPrint("Error while getting isFirstTime: $e");
    }
  }

  _saveIsFirstTime() async {
    if (isFirstTime) {
      try {
        await localStorageService.saveBool(
            LocalStorageBooleans.firstTime, false);
      } catch (e) {
        debugPrint("Error while saving isFirstTime: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return loadingWidget(context);
    }

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
                        isFirstTime
                            ? const Text("Bem vindo ao Direto da Nuvem.\nPara utilizar os nossos serviços é necessária uma conta institucional iduff.\nApós o Login:\nCertifique-se de que a sua conta é instaladora.\nEscreva o nome da televisão na qual está sendo instalado, e a adicione a um grupo já existente.")
                            : const SizedBox.shrink(),
                        const SizedBox(height: 25,),
                        SignInButton(
                          buttonType: ButtonType.googleDark,
                          btnText: "Entrar com o Google",
                          onPressed: () {
                            userController.login(context);
                          },
                        ),
                        const SizedBox(height: 15),
                        Text("v ${widget.packageVersion}"),
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
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(width: 25),
                            isFirstTime
                                ? const Text("Bem vindo ao Direto da Nuvem.\nPara utilizar os nossos serviços é necessária uma conta institucional iduff.\nApós o Login:\nCertifique-se que a sua conta é instaladora.\nEscreva o nome da televisão na qual está sendo instalado, e a adicione a um grupo já existente.",
                                        softWrap: true,
                                        overflow: TextOverflow.fade,
                                )
                                : const SizedBox.shrink(),
                            const SizedBox(height: 25),
                            SignInButton(
                              buttonType: ButtonType.googleDark,
                              btnText: "Entrar com o Google",
                              onPressed: () {
                                userController.login(context);
                              },
                            ),
                            const SizedBox(height: 5),
                            Text("v ${widget.packageVersion}"),
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
