import 'package:ddnuvem/services/local_storage/booleans.dart';
import 'package:ddnuvem/services/local_storage/doubles.dart';
import 'package:ddnuvem/services/local_storage/ints.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  Future<bool> saveInt(LocalStorageInts name,int value) async {
    SharedPreferences s = await _sharedPreferences;
    return s.setInt(name.name, value);
  }

  Future<bool> saveDouble(LocalStorageDoubles name, double value) async {
    SharedPreferences s = await _sharedPreferences;
    return s.setDouble(name.name, value);
  }
}