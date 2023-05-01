import 'dart:async';

import 'package:aves_utils/aves_utils.dart';
import 'package:flutter/foundation.dart';

class Query extends ChangeNotifier {
  final AChangeNotifier _focusRequestNotifier = AChangeNotifier();
  final ValueNotifier<String> _queryNotifier = ValueNotifier('');
  final StreamController<bool> _enabledStreamController = StreamController.broadcast();

  Query({required bool enabled, required String? initialValue}) {
    _enabled = enabled;
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

  Stream<bool> get enabledStream => _enabledStreamController.stream;

  AChangeNotifier get focusRequestNotifier => _focusRequestNotifier;

  ValueNotifier<String> get queryNotifier => _queryNotifier;
}
