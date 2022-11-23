import 'dart:async';

import 'package:aves/model/entry.dart';
import 'package:aves/widgets/viewer/video/controller.dart';
import 'package:aves/widgets/viewer/video/fijkplayer.dart';
import 'package:collection/collection.dart';

class VideoConductor {
  final List<AvesVideoController> _controllers = [];
  final bool persistPlayback;

  static const _defaultMaxControllerCount = 3;

  VideoConductor({required this.persistPlayback});

  Future<void> dispose() async {
    await Future.forEach<AvesVideoController>(_controllers, (controller) => controller.dispose());
    _controllers.clear();
  }

  AvesVideoController getOrCreateController(AvesEntry entry, {int? maxControllerCount}) {
    var controller = getController(entry);
    if (controller != null) {
      _controllers.remove(controller);
    } else {
      controller = IjkPlayerAvesVideoController(entry, persistPlayback: persistPlayback);
    }
    _controllers.insert(0, controller);
    while (_controllers.length > (maxControllerCount ?? _defaultMaxControllerCount)) {
      _controllers.removeLast().dispose();
    }
    return controller;
  }

  AvesVideoController? getController(AvesEntry entry) {
    return _controllers.firstWhereOrNull((c) => c.entry.uri == entry.uri && c.entry.pageId == entry.pageId);
  }

  Future<void> _applyToAll(FutureOr Function(AvesVideoController controller) action) => Future.forEach<AvesVideoController>(_controllers, action);

  Future<void> pauseAll() => _applyToAll((controller) => controller.pause());

  Future<void> muteAll(bool muted) => _applyToAll((controller) => controller.mute(muted));
}
