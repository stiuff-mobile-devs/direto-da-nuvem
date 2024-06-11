import 'package:flutter/material.dart';

//TODO:
//   | Logado | Cadastrado | Admin |
//       V         V           V   | AdminPage
//       V         V           F   | ViewPage
//       V         F           V   | CadastrarDevice
//       V         F           F   | Erro e Mensagem
//       F         V           F   | Login
//       F         F           V   | Login
//       F         F           F   | Login
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}