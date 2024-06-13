import 'package:flutter/material.dart';
import '../views/login_page.dart';

class IntroductionPage extends StatefulWidget {
  const IntroductionPage({super.key});

  @override
  State<IntroductionPage> createState() => _IntroductionPage();
}

class _IntroductionPage extends State<IntroductionPage> {
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