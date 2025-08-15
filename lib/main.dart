import 'package:ddnuvem/app.dart';
import 'package:ddnuvem/controllers/device_controller.dart';
import 'package:ddnuvem/controllers/group_controller.dart';
import 'package:ddnuvem/controllers/queue_controller.dart';
import 'package:ddnuvem/controllers/user_controller.dart';
import 'package:ddnuvem/services/direto_da_nuvem/direto_da_nuvem_service.dart';
import 'package:ddnuvem/services/hive_service.dart';
import 'package:ddnuvem/services/local_storage/local_storage_service.dart';
import 'package:ddnuvem/services/sign_in_service.dart';
import 'package:ddnuvem/views/devices/devices_filter_controller.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Impede o bloqueio automático de tela
  await WakelockPlus.enable();
  // Solicita permissão de execução em segundo plano se necessário
  if (await Permission.ignoreBatteryOptimizations.isDenied) {
    await Permission.ignoreBatteryOptimizations.request();
  }
  // Solicita permissão para sobrepor outros aplicativos
  if (await Permission.systemAlertWindow.isDenied) {
    await Permission.systemAlertWindow.request();
  }
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug,
  );
  await HiveService.initialize();

  runApp(MultiProvider(providers: [
    Provider<DiretoDaNuvemAPI>(
      create: (context) => DiretoDaNuvemAPI(),
    ),
    Provider<LocalStorageService>(create: (context) => LocalStorageService()),
    Provider<SignInService>(
      create: (context) => SignInService(context, context.read()),
    ),
    ChangeNotifierProvider<UserController>(
        create: (context) => UserController(context.read(), context.read())..init()),
    ChangeNotifierProvider<DevicesFilterController>(create: (context) {
      return DevicesFilterController();
    }),
    ChangeNotifierProvider<QueueController>(
        create: (context) => QueueController(context.read())..init()),
    ChangeNotifierProvider<GroupController>(
        create: (context) => GroupController(context.read())..init()),
    ChangeNotifierProvider<DeviceController>(
        create: (context) =>
            DeviceController(context.read(), context.read<GroupController>())
              ..init()),
  ], child: const App()));
}
