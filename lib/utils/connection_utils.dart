import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;

Future<bool> hasInternetConnection() async {
  try {
    var connectivity = await Connectivity().checkConnectivity();
    if (connectivity == ConnectivityResult.none) {
      return false;
    }

    try {
      final result = await http
          .get(Uri.parse('https://www.google.com'))
          .timeout(const Duration(seconds: 5));
      if (result.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (_) {
      return false;
    }
  } catch (e) {
    return false;
  }
}
