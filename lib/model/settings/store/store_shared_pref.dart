import 'package:aves/model/settings/store/store.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefSettingsStore implements SettingsStore {
  static SharedPreferences? _prefs;

  @override
  bool get initialized => _prefs != null;

  @override
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  @override
  Future<bool> clear() => _prefs!.clear();

  @override
  Future<bool> remove(String key) => _prefs!.remove(key);

  // get

  @override
  Set<String> getKeys() => _prefs!.getKeys();

  @override
  Object? get(String key) => _prefs!.get(key);

  @override
  bool? getBool(String key) => _prefs!.getBool(key);

  @override
  int? getInt(String key) => _prefs!.getInt(key);

  @override
  double? getDouble(String key) => _prefs!.getDouble(key);

  @override
  String? getString(String key) => _prefs!.getString(key);

  @override
  List<String>? getStringList(String key) => _prefs!.getStringList(key);

  // set

  @override
  Future<bool> setBool(String key, bool value) => _prefs!.setBool(key, value);

  @override
  Future<bool> setInt(String key, int value) => _prefs!.setInt(key, value);

  @override
  Future<bool> setDouble(String key, double value) => _prefs!.setDouble(key, value);

  @override
  Future<bool> setString(String key, String value) => _prefs!.setString(key, value);

  @override
  Future<bool> setStringList(String key, List<String> value) => _prefs!.setStringList(key, value);
}
