import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/entry/extensions/props.dart';
import 'package:aves/widgets/viewer/visual/state.dart';
import 'package:aves_magnifier/aves_magnifier.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:tuple/tuple.dart';

class ViewStateConductor {
  final List<Tuple2<String, ValueNotifier<ViewState>>> _controllers = [];
  Size _viewportSize = Size.zero;

  static const maxControllerCount = 3;

  Future<void> dispose() async {
    _controllers.clear();
  }

  set viewportSize(Size size) => _viewportSize = size;

  ValueNotifier<ViewState> getOrCreateController(AvesEntry entry) {
    var controller = _controllers.firstOrNull;
    if (controller == null || controller.item1 != entry.uri) {
      controller = _controllers.firstWhereOrNull((kv) => kv.item1 == entry.uri);
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
            childSize: entry.displaySize,
          ).initialScale,
          viewportSize: _viewportSize,
          contentSize: entry.displaySize,
        );
        controller = Tuple2(entry.uri, ValueNotifier<ViewState>(initialValue));
      }
      _controllers.insert(0, controller);
      while (_controllers.length > maxControllerCount) {
        _controllers.removeLast().item2.dispose();
      }
    }
    return controller.item2;
  }

  void reset(AvesEntry entry) {
    final uris = <AvesEntry>{
      entry,
      ...?entry.burstEntries,
    }.map((v) => v.uri).toSet();
    _controllers.removeWhere((kv) => uris.contains(kv.item1));
  }
}
