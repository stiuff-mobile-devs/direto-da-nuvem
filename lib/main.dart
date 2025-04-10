import 'package:ddnuvem/app.dart';
import 'package:ddnuvem/controllers/device_controller.dart';
import 'package:ddnuvem/controllers/group_controller.dart';
import 'package:ddnuvem/controllers/queue_controller.dart';
import 'package:ddnuvem/controllers/user_controller.dart';
import 'package:ddnuvem/services/direto_da_nuvem/direto_da_nuvem_service.dart';
import 'package:ddnuvem/services/local_storage/local_storage_service.dart';
import 'package:ddnuvem/services/sign_in_service.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug,
  );

  runApp(MultiProvider(providers: [
    Provider<DiretoDaNuvemAPI>(
      create: (context) => DiretoDaNuvemAPI(),
    ),
    Provider<LocalStorageService>(create: (context) => LocalStorageService()),
    Provider<SignInService>(
      create: (context) => SignInService(context, context.read()),
    ),
    ChangeNotifierProvider<UserController>(create: (context) {
      return UserController(context.read(), context.read());
    }),
    ChangeNotifierProvider<QueueController>(
        create: (context) => QueueController(context.read())..init()),
    ChangeNotifierProvider(
        create: (context) => GroupController(context.read())..init()),
    ChangeNotifierProvider<DeviceController>(
        create: (context) => DeviceController(context.read())..init()),
  ], child: const App()));
}
