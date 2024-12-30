import 'package:event_bus/event_bus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

class HighlightInfo extends ChangeNotifier {
  final EventBus eventBus = EventBus();

  HighlightInfo() {
    if (kFlutterMemoryAllocationsEnabled) ChangeNotifier.maybeDispatchObjectCreation(this);
  }

  void trackItem<T>(
    T? item, {
    TrackPredicate? predicate,
    Alignment? alignment,
    bool? animate,
    Object? highlightItem,
  }) {
    if (item != null) {
      eventBus.fire(TrackEvent<T>(
        item,
        predicate ?? (_) => true,
        alignment ?? Alignment.center,
        animate ?? true,
        highlightItem,
      ));
    }
  }

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
  final TrackPredicate predicate;
  final Alignment alignment;
  final bool animate;
  final Object? highlightItem;

  const TrackEvent(
    this.item,
    this.predicate,
    this.alignment,
    this.animate,
    this.highlightItem,
  );
}

// `itemVisibility`: percent of the item tracked already visible in viewport
// return whether to proceed with tracking
typedef TrackPredicate = bool Function(double itemVisibility);
