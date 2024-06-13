import 'package:ddnuvem/services/local_storage/booleans.dart';
import 'package:ddnuvem/services/local_storage/local_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
    return const Placeholder(
      child: Text("TODO: IntroPage"),
    );
  }
}
