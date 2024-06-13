import 'package:ddnuvem/app.dart';
import 'package:ddnuvem/services/direto_da_nuvem/direto_da_nuvem_service.dart';
import 'package:ddnuvem/services/sign_in_service.dart';
import 'package:ddnuvem/services/local_storage/local_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MultiProvider(providers: [
    Provider<DiretoDaNuvemAPI>(
      create: (context) => DiretoDaNuvemAPI(),
    ),
    Provider<LocalStorageService>(create: (context) => LocalStorageService()),
    Provider<SignInService>(
      create: (context) =>
          SignInService(context, context.read<DiretoDaNuvemAPI>()),
    ),
  ], child: const App()));
}
