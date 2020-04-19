import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';

final ServicePolicy servicePolicy = ServicePolicy._private();

class ServicePolicy {
  final Queue<_Task> _asapQueue, _normalQueue, _backgroundQueue;
  List<Queue<_Task>> _queues;
  _Task _running;

  ServicePolicy._private()
      : _asapQueue = Queue(),
        _normalQueue = Queue(),
        _backgroundQueue = Queue() {
    _queues = [_asapQueue, _normalQueue, _backgroundQueue];
  }

  Future<T> call<T>(
    Future<T> Function() platformCall, {
    ServiceCallPriority priority = ServiceCallPriority.normal,
    String debugLabel,
    Object cancellationKey,
  }) {
    Queue<_Task> queue;
    switch (priority) {
      case ServiceCallPriority.asap:
        queue = _asapQueue;
        break;
      case ServiceCallPriority.background:
        queue = _backgroundQueue;
        break;
      case ServiceCallPriority.normal:
      default:
        queue = _normalQueue;
        break;
    }
    final completer = Completer<T>();
    final wrapped = _Task(
      () async {
//      if (debugLabel != null) debugPrint('$runtimeType $debugLabel start');
        final result = await platformCall();
        completer.complete(result);
//      if (debugLabel != null) debugPrint('$runtimeType $debugLabel completed');
        _running = null;
        _pickNext();
      },
      completer,
      cancellationKey,
    );
    queue.addLast(wrapped);

    _pickNext();
    return completer.future;
  }

  void _pickNext() {
    if (_running != null) return;
    final queue = _queues.firstWhere((q) => q.isNotEmpty, orElse: () => null);
    _running = queue?.removeFirst();
    _running?.callback?.call();
  }

  bool cancel(Object cancellationKey) {
    var cancelled = false;
    final tasks = _queues.expand((q) => q.where((task) => task.cancellationKey == cancellationKey)).toList();
    tasks.forEach((task) => _queues.forEach((q) {
          if (q.remove(task)) {
            cancelled = true;
            task.completer.completeError(CancelledException());
          }
        }));
    return cancelled;
  }
}

class _Task {
  final VoidCallback callback;
  final Completer completer;
  final Object cancellationKey;

  const _Task(this.callback, this.completer, this.cancellationKey);
}

class CancelledException {}

enum ServiceCallPriority { asap, normal, background }
