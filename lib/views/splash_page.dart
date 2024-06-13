import 'package:ddnuvem/views/login_page.dart';
import 'package:flutter/material.dart';

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
  Future<bool> tryLogin() async {
    return false;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
        future: tryLogin(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              return handleRedirection();
            case ConnectionState.waiting:
              return loading();
            default:
              return const Placeholder();
          }
        });
  }

  Widget loading() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget handleRedirection() {
    return const LoginPage();
  }
}
