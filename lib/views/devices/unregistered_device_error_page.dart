import 'package:ddnuvem/views/devices/register_device_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class UnregisteredDeviceErrorPage extends StatefulWidget {
  const UnregisteredDeviceErrorPage({super.key});

  @override
  State<UnregisteredDeviceErrorPage> createState() => _UnregisteredDeviceErrorPageState();
}

class _UnregisteredDeviceErrorPageState extends State<UnregisteredDeviceErrorPage> {
  @override
  Widget build(BuildContext context) {
    // TODO: Unregistered device error page
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
    const Text("Bem vindo ao Direto da Nuvem.\nParece que o seu dispositivo não está cadastrado.\n Se está prestes a cadastra-lo, certifique-se que a sua conta é instaladora.\nCaso esse dispositivo já esteja cadastrado, entre em contato com o nosso suporte."),
    const SizedBox(height: 25,),
              ElevatedButton(
                  onPressed: () {

                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RegisterDevicePage()),
                    );
                  },
                  child: Text('Registrar Dispositivo'),
              )
    ]
    )
    )
    )
    )
    );
}
}