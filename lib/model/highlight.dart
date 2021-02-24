import 'package:flutter/foundation.dart';

class HighlightInfo extends ChangeNotifier {
  Object _item;

  void set(Object item) {
    if (_item == item) return;
    _item = item;
    notifyListeners();
  }

  Object clear() {
    if (_item == null) return null;
    final item = _item;
    _item = null;
    notifyListeners();
    return item;
  }

  bool contains(Object item) => _item == item;

  @override
  String toString() => '$runtimeType#${shortHash(this)}{item=$_item}';
}
