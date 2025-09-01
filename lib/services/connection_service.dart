import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;

class ConnectionService extends ChangeNotifier {
  final Connectivity _connectivity = Connectivity();

  bool connectionStatus = false;
  StreamSubscription? _subscription;

  ConnectionService() {
    _checkConnection();

    _subscription = _connectivity.onConnectivityChanged.listen((_) {
      _checkConnection();
    },
    onError: (e) {
      debugPrint("Error on listen to connectivity: $e");
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  _checkConnection() async {
    bool newStatus = await isConnected();
    if (newStatus != connectionStatus) {
      connectionStatus = newStatus;
      notifyListeners();
    }
  }

  static Future<bool> isConnected() async {
    try {
      var connectivity = await Connectivity().checkConnectivity();
      if (connectivity == ConnectivityResult.none) {
        return false;
      }

      final result = await http
          .get(Uri.parse('https://www.google.com'))
          .timeout(const Duration(seconds: 5));
      if (result.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }
}
