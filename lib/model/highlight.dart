import 'dart:collection';

import 'package:flutter/foundation.dart';

class HighlightInfo extends ChangeNotifier {
  final Queue<Object> _items = Queue();

  void add(Object item) {
    if (_items.contains(item)) return;

    _items.addFirst(item);
    while (_items.length > 5) {
      _items.removeLast();
    }
    notifyListeners();
  }

  void remove(Object item) {
    _items.removeWhere((element) => element == item);
    notifyListeners();
  }

  bool contains(Object item) => _items.contains(item);
}
