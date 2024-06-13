import 'package:ddnuvem/services/local_storage/booleans.dart';
import 'package:ddnuvem/services/local_storage/local_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../views/login_page.dart';

class IntroPage extends StatefulWidget {
  const IntroPage({super.key});

  @override
  State<IntroPage> createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
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
        body: Center(
          child: Row(
            children: [
              Container(
                child: Image(image: AssetImage('assets/direto_da_nuvem_icon.png')),
              ),
              Container(
                child: Text("Bem vindo ao Direto da Nuvem."),
              ),
              Container(
                child: Text("Para utilizar os nossos serviços é necessária uma conta institucional iduff "),
              ),
              Container(
                child: Text(" Após o Login: "),
              ),
              Container(
                child: Text(" Certifique-se que a sua conta é instaladora "),
              ),
              Container(
                child: Text(" Escreva o nome da televisão na qual está sendo instalado, e a adicione a um grupo já existente "),
              ),
              FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                },
                child: Text("Vamos começar."),
              ),

            ],
          ),
        )
    );

  }
}
