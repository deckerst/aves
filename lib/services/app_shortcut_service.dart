import 'dart:convert';

import 'package:aves/model/filters/filters.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class AppShortcutService {
  static const platform = MethodChannel('deckers.thibault/aves/shortcut');

  // this ability will not change over the lifetime of the app
  static bool _canPin;

  static Future<bool> canPin() async {
    if (_canPin != null) {
      return SynchronousFuture(_canPin);
    }

    try {
      _canPin = await platform.invokeMethod('canPin');
      return _canPin;
    } on PlatformException catch (e) {
      debugPrint('canPin failed with code=${e.code}, exception=${e.message}, details=${e.details}}');
    }
    return false;
  }

  static Future<void> pin(String label, Set<CollectionFilter> filters) async {
    try {
      await platform.invokeMethod('pin', <String, dynamic>{
        'label': label,
        'filters': filters.map((filter) => jsonEncode(filter.toJson())).toList(),
      });
    } on PlatformException catch (e) {
      debugPrint('pin failed with code=${e.code}, exception=${e.message}, details=${e.details}');
    }
  }
}
