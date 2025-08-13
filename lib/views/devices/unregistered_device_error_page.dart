import 'package:ddnuvem/controllers/user_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class UnregisteredDeviceErrorPage extends StatefulWidget {
  const UnregisteredDeviceErrorPage({super.key});

  @override
  State<UnregisteredDeviceErrorPage> createState() =>
      _UnregisteredDeviceErrorPageState();
}

class _UnregisteredDeviceErrorPageState
    extends State<UnregisteredDeviceErrorPage> {
  bool showView = true;
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<String> assetImages = [
    'assets/001.png',
    'assets/002.png',
    'assets/003.png',
    'assets/004.png',
  ];

  @override
  void initState() {
    super.initState();
    _startAutoPage();
  }

  void _startAutoPage() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 10));
      if (!mounted || !showView) return false;
      if (_pageController.hasClients) {
        _currentPage = (_currentPage + 1) % assetImages.length;
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
      return showView;
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _showInfoPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
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
            const Text("Seja bem vindo ao Direto da Nuvem!\nParece que o seu dispositivo não está cadastrado.\nSe está prestes a cadastrá-lo, certifique-se de que a sua conta é instaladora.\nCaso esse dispositivo já esteja cadastrado, entre em contato com o nosso suporte."),
            const SizedBox(height: 25),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  showView = true;
                  _startAutoPage();
                });
                Navigator.of(context).pop();
              },
              child: const Text("Tocar demonstração"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<UserController>().logout();
              },
              child: const Text("Sair"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (showView) {
      return GestureDetector(
        onTap: () {
          _showInfoPopup(context);
        },
        child: PageView(
          controller: _pageController,
          children: assetImages.map((path) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Image.asset(path, fit: BoxFit.contain),
              ),
            );
          }).toList(),
        ),
      );
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () {
            setState(() {
              showView = true;
              _startAutoPage();
            });
          },
          child: const Text("Play"),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            context.read<UserController>().logout();
          },
          child: const Text("Sair"),
        ),
      ],
    );
  }
}
