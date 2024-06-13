import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/google_sign_in.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late GoogleSignInHandler _googleSignInHandler;

  @override
  void initState() {
    _googleSignInHandler =
        Provider.of<GoogleSignInHandler>(context, listen: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.all(25.0),
              child: Text("Conectado"),
            ),
            const SizedBox(height: 25),
            SizedBox(
              height: 40,
              child: ElevatedButton(
                onPressed: _googleSignInHandler.signInWithGoogle,
                child: const Text("Sair"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
