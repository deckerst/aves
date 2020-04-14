import 'dart:async';
import 'dart:collection';

import 'package:flutter/cupertino.dart';

final ServicePolicy servicePolicy = ServicePolicy._private();

class ServicePolicy {
  final Queue<VoidCallback> _asapQueue = Queue(), _normalQueue = Queue(), _backgroundQueue = Queue();
  VoidCallback _running;

  ServicePolicy._private();

  Future<T> call<T>(Future<T> Function() platformCall, [ServiceCallPriority priority = ServiceCallPriority.normal, String debugLabel]) {
    Queue<VoidCallback> q;
    switch (priority) {
      case ServiceCallPriority.asapFifo:
        q = _asapQueue;
        break;
      case ServiceCallPriority.asapLifo:
        q = _asapQueue;
        break;
      case ServiceCallPriority.background:
        q = _backgroundQueue;
        break;
      case ServiceCallPriority.normal:
      default:
        q = _normalQueue;
        break;
    }
    final completer = Completer<T>();
    final wrapped = () async {
//      if (debugLabel != null) debugPrint('$runtimeType $debugLabel start');
      final result = await platformCall();
      completer.complete(result);
//      if (debugLabel != null) debugPrint('$runtimeType $debugLabel completed');
      _running = null;
      _pickNext();
    };
    if (priority == ServiceCallPriority.asapLifo) {
      q.addFirst(wrapped);
    } else {
      q.addLast(wrapped);
    }

    _pickNext();
    return completer.future;
  }

  void _pickNext() {
    if (_running != null) return;
    final queue = [_asapQueue, _normalQueue, _backgroundQueue].firstWhere((q) => q.isNotEmpty, orElse: () => null);
    _running = queue?.removeFirst();
    _running?.call();
  }
}

enum ServiceCallPriority { asapFifo, asapLifo, normal, background }
