import 'package:aves_model/aves_model.dart';
import 'package:collection/collection.dart';

mixin SettingsAccess {
  bool get initialized;

  SettingsStore get store;

  Stream<SettingsChangedEvent> get updateStream;

  void notifyKeyChange(String key, dynamic oldValue, dynamic newValue);

  void notifyListeners();

  void set(String key, dynamic newValue) {
    var oldValue = store.get(key);
    if (newValue == null) {
      store.remove(key);
    } else if (newValue is String) {
      oldValue = getString(key);
      store.setString(key, newValue);
    } else if (newValue is List<String>) {
      oldValue = getStringList(key);
      store.setStringList(key, newValue);
    } else if (newValue is int) {
      oldValue = getInt(key);
      store.setInt(key, newValue);
    } else if (newValue is double) {
      oldValue = getDouble(key);
      store.setDouble(key, newValue);
    } else if (newValue is bool) {
      oldValue = getBool(key);
      store.setBool(key, newValue);
    }
    if (oldValue != newValue) {
      notifyKeyChange(key, oldValue, newValue);
      notifyListeners();
    }
  }

  // getters

  bool? getBool(String key) {
    try {
      return store.getBool(key);
    } catch (error) {
      // ignore, could be obsolete value of different type
      return null;
    }
  }

  int? getInt(String key) {
    try {
      return store.getInt(key);
    } catch (error) {
      // ignore, could be obsolete value of different type
      return null;
    }
  }

  double? getDouble(String key) {
    try {
      return store.getDouble(key);
    } catch (error) {
      // ignore, could be obsolete value of different type
      return null;
    }
  }

  String? getString(String key) {
    try {
      return store.getString(key);
    } catch (error) {
      // ignore, could be obsolete value of different type
      return null;
    }
  }

  List<String>? getStringList(String key) {
    try {
      return store.getStringList(key);
    } catch (error) {
      // ignore, could be obsolete value of different type
      return null;
    }
  }

  T getEnumOrDefault<T>(String key, T defaultValue, Iterable<T> values) {
    try {
      final valueString = store.getString(key);
      for (final v in values) {
        if (v.toString() == valueString) {
          return v;
        }
      }
    } catch (error) {
      // ignore, could be obsolete value of different type
    }
    return defaultValue;
  }

  List<T> getEnumListOrDefault<T extends Object>(String key, List<T> defaultValue, Iterable<T> values) {
    return store.getStringList(key)?.map((s) => values.firstWhereOrNull((v) => v.toString() == s)).whereNotNull().toList() ?? defaultValue;
  }
}
