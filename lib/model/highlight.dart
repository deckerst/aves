import 'package:event_bus/event_bus.dart';
import 'package:flutter/foundation.dart';

class HighlightInfo extends ChangeNotifier {
  final EventBus eventBus = EventBus();

  void trackItem<T>(
    T item, {
    required bool animate,
    Object? highlight,
  }) =>
      eventBus.fire(TrackEvent<T>(item, animate, highlight));

  Object? _item;

  void set(Object item) {
    if (_item == item) return;
    _item = item;
    notifyListeners();
  }

  Object? clear() {
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

@immutable
class TrackEvent<T> {
  final T item;
  final bool animate;
  final Object? highlight;

  const TrackEvent(this.item, this.animate, this.highlight);
}
