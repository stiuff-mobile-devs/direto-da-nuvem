import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class ConnectionService extends ChangeNotifier {
  bool connectionStatus = false;
  StreamSubscription<InternetStatus>? _subscription;

  ConnectionService() {
    _checkInitialConnection();

    _subscription = InternetConnection().onStatusChange.listen((InternetStatus status) {
      bool newStatus = status == InternetStatus.connected;
      if (newStatus != connectionStatus) {
        connectionStatus = newStatus;
        notifyListeners();
      }
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

  _checkInitialConnection() async {
    if (kIsWeb) {
      connectionStatus = true;
      notifyListeners();
      return;
    }
    bool newStatus = await isConnected();
    if (newStatus != connectionStatus) {
      connectionStatus = newStatus;
      notifyListeners();
    }
  }

  static Future<bool> isConnected() async {
    if (kIsWeb) return true;
    return await InternetConnection().hasInternetAccess;
  }
}
