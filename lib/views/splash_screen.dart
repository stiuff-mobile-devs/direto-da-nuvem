import 'package:ddnuvem/controllers/device_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  final String group;
  final String queue;
  final String packageVersion;

  const SplashScreen({
    super.key,
    required this.group,
    required this.packageVersion,
    required this.queue});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    _show();
  }

  _show() async {
    await Future.delayed(const Duration(seconds: 2));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DeviceController>().splashScreenComplete();
    });
    setState(() {});
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
                      if (widget.group.isNotEmpty) ...[
                        Text("Grupo: ${widget.group}",
                            style: const TextStyle(fontSize: 20)),
                        Text("Fila ativa: ${widget.queue}",
                            style: const TextStyle(fontSize: 20)),
                        const SizedBox(height: 15),
                      ],
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
                      Expanded(
                        child: Column(
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
                            const SizedBox(width: 25),
                            if (widget.group.isNotEmpty) ...[
                              Text("Grupo: ${widget.group}",
                                  style: const TextStyle(fontSize: 20)),
                              Text("Fila ativa: ${widget.queue}",
                                  style: const TextStyle(fontSize: 20)),
                              const SizedBox(height: 10),
                            ],
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
