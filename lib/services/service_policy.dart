import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';

final ServicePolicy servicePolicy = ServicePolicy._private();

class ServicePolicy {
  final Map<Object, _Task> _paused = {};
  final Queue<_Task> _asapQueue = Queue(), _normalQueue = Queue(), _backgroundQueue = Queue();
  List<Queue<_Task>> _queues;
  _Task _running;

  ServicePolicy._private() {
    _queues = [_asapQueue, _normalQueue, _backgroundQueue];
  }

  Future<T> call<T>(
    Future<T> Function() platformCall, {
    ServiceCallPriority priority = ServiceCallPriority.normal,
    String debugLabel,
    Object key,
  }) {
    var task = _paused.remove(key);
    if (task != null) {
      debugPrint('resume task with key=$key');
    }
    var completer = task?.completer ?? Completer<T>();
    task ??= _Task(
      () async {
//      if (debugLabel != null) debugPrint('$runtimeType $debugLabel start');
        final result = await platformCall();
        completer.complete(result);
//      if (debugLabel != null) debugPrint('$runtimeType $debugLabel completed');
        _running = null;
        _pickNext();
      },
      completer,
      key,
    );
    _getQueue(priority).addLast(task);
    _pickNext();
    return completer.future;
  }

  Future<T> resume<T>(Object key, ServiceCallPriority priority) {
    var task = _paused.remove(key);
    if (task == null) return null;
    _getQueue(priority).addLast(task);
    _pickNext();
    return task.completer.future;
  }

  Queue<_Task> _getQueue(ServiceCallPriority priority) {
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
    return queue;
  }

  void _pickNext() {
    if (_running != null) return;
    final queue = _queues.firstWhere((q) => q.isNotEmpty, orElse: () => null);
    _running = queue?.removeFirst();
    _running?.callback?.call();
  }

  bool cancel(Object key, ServiceCallPriority priority) {
    var cancelled = false;
    final queue = _getQueue(priority);
    final tasks = queue.where((task) => task.key == key).toList();
    tasks.forEach((task) {
      if (queue.remove(task)) {
        cancelled = true;
        task.completer.completeError(CancelledException());
      }
    });
    return cancelled;
  }

  bool pause(Object key, ServiceCallPriority priority) {
    var paused = false;
    final queue = _getQueue(priority);
    final tasks = queue.where((task) => task.key == key).toList();
    tasks.forEach((task) {
      if (queue.remove(task)) {
        paused = true;
        _paused.putIfAbsent(key, () => task);
      }
    });
    return paused;
  }

  bool isPaused(Object key) => _paused.containsKey(key);
}

class _Task {
  final VoidCallback callback;
  final Completer completer;
  final Object key;

  const _Task(this.callback, this.completer, this.key);
}

class CancelledException {}

enum ServiceCallPriority { asap, normal, background }
