import 'package:aves_model/aves_model.dart';
import 'package:aves_utils/aves_utils.dart';

mixin SettingsAccess {
  bool get initialized;

  SettingsStore get store;

  Stream<SettingsChangedEvent> get updateStream;

  void notifyKeyChange(String key, Object? oldValue, Object? newValue);

  void notifyListeners();

  void set(String key, Object? newValue) {
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

  T getEnumOrDefault<T extends Enum>(String key, T defaultValue, Iterable<T> values) {
    try {
      return values.safeByName(store.getString(key)) ?? defaultValue;
    } catch (error) {
      // ignore, could be obsolete value of different type
      return defaultValue;
    }
  }

  List<T> getEnumListOrDefault<T extends Enum>(String key, List<T> defaultValue, Iterable<T> values) {
    return store.getStringList(key)?.map((s) => values.safeByName(s)).nonNulls.toList() ?? defaultValue;
  }
}
