import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:tuple/tuple.dart';

final ServicePolicy servicePolicy = ServicePolicy._private();

class ServicePolicy {
  final StreamController<QueueState> _queueStreamController = StreamController<QueueState>.broadcast();
  final Map<Object, Tuple2<int, _Task>> _paused = {};
  final SplayTreeMap<int, Queue<_Task>> _queues = SplayTreeMap();
  final Queue<_Task> _runningQueue = Queue();

  // magic number
  static const concurrentTaskMax = 4;

  Stream<QueueState> get queueStream => _queueStreamController.stream;

  ServicePolicy._private();

  Future<T> call<T>(
    Future<T> Function() platformCall, {
    int priority = ServiceCallPriority.normal,
    String debugLabel,
    Object key,
  }) {
    _Task task;
    key ??= platformCall.hashCode;
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
        _runningQueue.removeWhere((task) => task.key == key);
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
    _notifyQueueState();
    if (_runningQueue.length >= concurrentTaskMax) return;
    final queue = _queues.entries.firstWhere((kv) => kv.value.isNotEmpty, orElse: () => null)?.value;
    final task = queue?.removeFirst();
    if (task != null) {
      _runningQueue.addLast(task);
      task.callback();
    }
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

  void _notifyQueueState() {
    if (!_queueStreamController.hasListener) return;

    final queueByPriority = Map.fromEntries(_queues.entries.map((kv) => MapEntry(kv.key, kv.value.length)));
    _queueStreamController.add(QueueState(queueByPriority, _runningQueue.length));
  }
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
  static const int getRegion = 150;
  static const int getSizedThumbnail = 200;
  static const int normal = 500;
  static const int getMetadata = 1000;
  static const int getLocation = 1000;
}

class QueueState {
  final Map<int, int> queueByPriority;
  final int runningQueue;

  const QueueState(this.queueByPriority, this.runningQueue);
}
