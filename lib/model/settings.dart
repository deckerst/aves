import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

final Settings settings = Settings._private();

typedef void SettingsCallback(String key, dynamic oldValue, dynamic newValue);

class Settings {
  static SharedPreferences prefs;

  ObserverList<SettingsCallback> _listeners = ObserverList<SettingsCallback>();

  Settings._private();

  // preferences
  static const infoMapZoomKey = 'info_map_zoom';

  init() async {
    prefs = await SharedPreferences.getInstance();
  }

  void addListener(SettingsCallback listener) => _listeners.add(listener);

  void removeListener(SettingsCallback listener) => _listeners.remove(listener);

  void notifyListeners(String key, dynamic oldValue, dynamic newValue) {
    debugPrint('$runtimeType notifyListeners key=$key, old=$oldValue, new=$newValue');
    if (_listeners != null) {
      final List<SettingsCallback> localListeners = _listeners.toList();
      for (SettingsCallback listener in localListeners) {
        try {
          if (_listeners.contains(listener)) {
            listener(key, oldValue, newValue);
          }
        } catch (exception, stack) {
          debugPrint('$runtimeType failed to notify listeners with exception=$exception\n$stack');
        }
      }
    }
  }

  double get infoMapZoom => prefs.getDouble(infoMapZoomKey) ?? 12;

  set infoMapZoom(double newValue) => setAndNotify(infoMapZoomKey, newValue);

  // convenience methods

  bool getBoolOrDefault(String key, bool defaultValue) => prefs.getKeys().contains(key) ? prefs.getBool(key) : defaultValue;

  setAndNotify(String key, dynamic newValue) {
    var oldValue = prefs.get(key);
    if (newValue == null) {
      prefs.remove(key);
    } else if (newValue is String) {
      oldValue = prefs.getString(key);
      prefs.setString(key, newValue);
    } else if (newValue is int) {
      oldValue = prefs.getInt(key);
      prefs.setInt(key, newValue);
    } else if (newValue is double) {
      oldValue = prefs.getDouble(key);
      prefs.setDouble(key, newValue);
    } else if (newValue is bool) {
      oldValue = prefs.getBool(key);
      prefs.setBool(key, newValue);
    }
    if (oldValue != newValue) {
      notifyListeners(key, oldValue, newValue);
    }
  }
}
