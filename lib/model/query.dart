import 'dart:async';

import 'package:aves/utils/change_notifier.dart';
import 'package:flutter/foundation.dart';

class Query extends ChangeNotifier {
  Query({required String? initialValue}) {
    if (initialValue != null && initialValue.isNotEmpty) {
      _enabled = true;
      queryNotifier.value = initialValue;
    }
  }

  bool _enabled = false;

  bool get enabled => _enabled;

  set enabled(bool value) {
    _enabled = value;
    _enabledStreamController.add(_enabled);
    queryNotifier.value = '';
    notifyListeners();

    if (_enabled) {
      focusRequestNotifier.notifyListeners();
    }
  }

  void toggle() => enabled = !enabled;

  final StreamController<bool> _enabledStreamController = StreamController.broadcast();

  Stream<bool> get enabledStream => _enabledStreamController.stream;

  final AChangeNotifier focusRequestNotifier = AChangeNotifier();

  final ValueNotifier<String> queryNotifier = ValueNotifier('');
}
