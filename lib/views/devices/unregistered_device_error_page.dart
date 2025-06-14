import 'package:ddnuvem/controllers/user_controller.dart';
import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    if (showView) {
      return GestureDetector(
        onTap: () {
          setState(() {
            showView = false;
          });
        },
        child: PageView(
          controller: _pageController,
          children: assetImages.map((path) {
            return Center(
              child: Image.asset(path, fit: BoxFit.contain),
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
            context.read<UserController>().logout();
          },
          child: const Text("Sair"),
        ),
      ],
    );
  }
}
