import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:tuple/tuple.dart';

final ServicePolicy servicePolicy = ServicePolicy._private();

class ServicePolicy {
  final Map<Object, Tuple2<int, _Task>> _paused = {};
  final SplayTreeMap<int, Queue<_Task>> _queues = SplayTreeMap();
  _Task _running;

  ServicePolicy._private();

  Future<T> call<T>(
    Future<T> Function() platformCall, {
    int priority = ServiceCallPriority.normal,
    String debugLabel,
    Object key,
  }) {
    _Task task;
    final priorityTask = _paused.remove(key);
    if (priorityTask != null) {
      debugPrint('resume task with key=$key');
      priority = priorityTask.item1;
      task = priorityTask.item2;
    }
    var completer = task?.completer ?? Completer<T>();
    task ??= _Task(
      () async {
        if (debugLabel != null) debugPrint('$runtimeType $debugLabel start');
        try {
          completer.complete(await platformCall());
        } catch (error, stackTrace) {
          completer.completeError(error, stackTrace);
        }
        if (debugLabel != null) debugPrint('$runtimeType $debugLabel completed');
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

  Future<T> resume<T>(Object key) {
    final priorityTask = _paused.remove(key);
    if (priorityTask == null) return null;
    final priority = priorityTask.item1;
    final task = priorityTask.item2;
    _getQueue(priority).addLast(task);
    _pickNext();
    return task.completer.future;
  }

  Queue<_Task> _getQueue(int priority) => _queues.putIfAbsent(priority, () => Queue<_Task>());

  void _pickNext() {
    if (_running != null) return;
    final queue = _queues.entries.firstWhere((kv) => kv.value.isNotEmpty, orElse: () => null)?.value;
    _running = queue?.removeFirst();
    _running?.callback?.call();
  }

  bool _takeOut(Object key, Iterable<int> priorities, void Function(int priority, _Task task) action) {
    var out = false;
    priorities.forEach((priority) {
      final queue = _getQueue(priority);
      final tasks = queue.where((task) => task.key == key).toList();
      tasks.forEach((task) {
        if (queue.remove(task)) {
          out = true;
          action(priority, task);
        }
      });
    });
    return out;
  }

  bool cancel(Object key, Iterable<int> priorities) {
    return _takeOut(key, priorities, (priority, task) => task.completer.completeError(CancelledException()));
  }

  bool pause(Object key, Iterable<int> priorities) {
    return _takeOut(key, priorities, (priority, task) => _paused.putIfAbsent(key, () => Tuple2(priority, task)));
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

class ServiceCallPriority {
  static const int getFastThumbnail = 100;
  static const int getSizedThumbnail = 200;
  static const int normal = 500;
  static const int getMetadata = 1000;
  static const int getLocation = 1000;
}
