import 'dart:async';

import 'package:aves/model/entry/entry.dart';
import 'package:aves/widgets/viewer/multipage/controller.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';

class MultiPageConductor {
  final List<MultiPageController> _controllers = [];

  static const maxControllerCount = 3;

  MultiPageConductor() {
    if (kFlutterMemoryAllocationsEnabled) {
      FlutterMemoryAllocations.instance.dispatchObjectCreated(
        library: 'aves',
        className: '$MultiPageConductor',
        object: this,
      );
    }
  }

  Future<void> dispose() async {
    if (kFlutterMemoryAllocationsEnabled) {
      FlutterMemoryAllocations.instance.dispatchObjectDisposed(object: this);
    }
    await _disposeAll();
    _controllers.clear();
  }

  MultiPageController getOrCreateController(AvesEntry entry) {
    var controller = getController(entry);
    if (controller != null) {
      _controllers.remove(controller);
    } else {
      controller = MultiPageController(entry);
    }
    _controllers.insert(0, controller);
    while (_controllers.length > maxControllerCount) {
      _controllers.removeLast().dispose();
    }
    return controller;
  }

  MultiPageController? getController(AvesEntry entry) {
    return _controllers.firstWhereOrNull((c) => c.entry.uri == entry.uri && c.entry.pageId == entry.pageId);
  }

  Future<void> _applyToAll(FutureOr Function(MultiPageController controller) action) => Future.forEach<MultiPageController>(_controllers, action);

  Future<void> _disposeAll() => _applyToAll((controller) => controller.dispose());
}
