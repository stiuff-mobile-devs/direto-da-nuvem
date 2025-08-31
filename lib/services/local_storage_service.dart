import 'package:shared_preferences/shared_preferences.dart';

enum LocalStorageBooleans {
  firstTime;
}

class LocalStorageService {
  final Future<SharedPreferences> _sharedPreferences = SharedPreferences.getInstance();

  Future<bool> clear() async {
    SharedPreferences s = await _sharedPreferences;
    return s.clear();
  }

  Future<bool> saveBool(LocalStorageBooleans name, bool value) async {
    SharedPreferences s = await _sharedPreferences;
    return s.setBool(name.name, value);
  }

  Future<bool?> readBool(LocalStorageBooleans name) async {
    SharedPreferences s = await _sharedPreferences;
    return s.getBool(name.name);
  }
}