import 'dart:async';
import 'dart:collection';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:tuple/tuple.dart';

final ServicePolicy servicePolicy = ServicePolicy._private();

class ServicePolicy {
  final StreamController<QueueState> _queueStreamController = StreamController.broadcast();
  final Map<Object, Tuple2<int, _Task>> _paused = {};
  final SplayTreeMap<int, LinkedHashMap<Object, _Task>> _queues = SplayTreeMap();
  final LinkedHashMap<Object, _Task> _runningQueue = LinkedHashMap();

  // magic number
  static const concurrentTaskMax = 4;

  Stream<QueueState> get queueStream => _queueStreamController.stream;

  ServicePolicy._private();

  Future<T> call<T>(
    Future<T> Function() platformCall, {
    int priority = ServiceCallPriority.normal,
    Object? key,
  }) {
    Completer<T> completer;
    _Task<T> task;
    key ??= platformCall.hashCode;
    final toResume = _paused.remove(key);
    if (toResume != null) {
      priority = toResume.item1;
      task = toResume.item2 as _Task<T>;
      completer = task.completer;
    } else {
      completer = Completer<T>();
      task = _Task<T>(
        () async {
          try {
            completer.complete(await platformCall());
          } catch (error, stack) {
            completer.completeError(error, stack);
          }
          _runningQueue.remove(key);
          _pickNext();
        },
        completer,
      );
    }
    _getQueue(priority)[key] = task;
    _pickNext();
    return completer.future;
  }

  Future<T>? resume<T>(Object key) {
    final toResume = _paused.remove(key);
    if (toResume != null) {
      final priority = toResume.item1;
      final task = toResume.item2 as _Task<T>;
      _getQueue(priority)[key] = task;
      _pickNext();
      return task.completer.future;
    } else {
      return null;
    }
  }

  LinkedHashMap<Object, _Task> _getQueue(int priority) => _queues.putIfAbsent(priority, LinkedHashMap.new);

  void _pickNext() {
    _notifyQueueState();
    if (_runningQueue.length >= concurrentTaskMax) return;
    final queue = _queues.entries.firstWhereOrNull((kv) => kv.value.isNotEmpty)?.value;
    if (queue != null && queue.isNotEmpty) {
      final key = queue.keys.first;
      final task = queue.remove(key)!;
      _runningQueue[key] = task;
      task.callback();
    }
  }

  bool _takeOut(Object key, Iterable<int> priorities, void Function(int priority, _Task task) action) {
    var out = false;
    priorities.forEach((priority) {
      final task = _getQueue(priority).remove(key);
      if (task != null) {
        out = true;
        action(priority, task);
      }
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
    _queueStreamController.add(QueueState(queueByPriority, _runningQueue.length, _paused.length));
  }
}

class _Task<T> {
  final VoidCallback callback;
  final Completer<T> completer;

  const _Task(this.callback, this.completer);
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
  final int runningCount, pausedCount;

  const QueueState(this.queueByPriority, this.runningCount, this.pausedCount);
}
