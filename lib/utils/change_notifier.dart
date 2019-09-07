import 'package:flutter/foundation.dart';

// reimplemented ChangeNotifier so that it can be used anywhere, not just as a mixin
class AChangeNotifier implements Listenable {
  ObserverList<VoidCallback> _listeners = ObserverList<VoidCallback>();

  @override
  void addListener(VoidCallback listener) => _listeners.add(listener);

  @override
  void removeListener(VoidCallback listener) => _listeners.remove(listener);

  void dispose() => _listeners = null;

  @protected
  void notifyListeners() {
    if (_listeners == null) return;
    final localListeners = List<VoidCallback>.from(_listeners);
    for (final listener in localListeners) {
      try {
        if (_listeners.contains(listener)) listener();
      } catch (exception, stack) {
        debugPrint('$runtimeType failed to notify listeners with exception=$exception\n$stack');
      }
    }
  }
}
