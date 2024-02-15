import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/view_state.dart';
import 'package:aves/widgets/viewer/view/controller.dart';
import 'package:aves_magnifier/aves_magnifier.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

class ViewStateConductor {
  final List<ViewStateController> _controllers = [];
  Size _viewportSize = Size.zero;

  static const maxControllerCount = 3;

  ViewStateConductor() {
    if (kFlutterMemoryAllocationsEnabled) {
      FlutterMemoryAllocations.instance.dispatchObjectCreated(
        library: 'aves',
        className: '$ViewStateConductor',
        object: this,
      );
    }
  }

  Future<void> dispose() async {
    if (kFlutterMemoryAllocationsEnabled) {
      FlutterMemoryAllocations.instance.dispatchObjectDisposed(object: this);
    }
    _controllers.forEach((v) => v.dispose());
    _controllers.clear();
  }

  set viewportSize(Size size) => _viewportSize = size;

  ViewStateController getOrCreateController(AvesEntry entry) {
    var controller = getController(entry);
    if (controller != null) {
      _controllers.remove(controller);
    } else {
      // try to initialize the view state to match magnifier initial state
      const initialScale = ScaleLevel(ref: ScaleReference.contained);
      final initialValue = ViewState(
        position: Offset.zero,
        scale: ScaleBoundaries(
          allowOriginalScaleBeyondRange: true,
          minScale: initialScale,
          maxScale: initialScale,
          initialScale: initialScale,
          viewportSize: _viewportSize,
          contentSize: entry.displaySize,
        ).initialScale,
        viewportSize: _viewportSize,
        contentSize: entry.displaySize,
      );
      controller = ViewStateController(
        entry: entry,
        viewStateNotifier: ValueNotifier<ViewState>(initialValue),
      );
    }
    _controllers.insert(0, controller);
    while (_controllers.length > maxControllerCount) {
      _controllers.removeLast().dispose();
    }
    return controller;
  }

  ViewStateController? getController(AvesEntry entry) {
    return _controllers.firstWhereOrNull((c) => c.entry.uri == entry.uri && c.entry.pageId == entry.pageId);
  }

  void reset(AvesEntry entry) {
    final uris = <AvesEntry>{
      entry,
      ...?entry.burstEntries,
    }.map((v) => v.uri).toSet();
    final entryControllers = _controllers.where((v) => uris.contains(v.entry.uri)).toSet();
    entryControllers.forEach((controller) {
      _controllers.remove(controller);
      controller.dispose();
    });
  }
}
