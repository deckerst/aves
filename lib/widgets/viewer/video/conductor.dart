import 'dart:async';

import 'package:aves/model/entry.dart';
import 'package:aves/model/settings/enums/enums.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/widgets/viewer/video/controller.dart';
import 'package:aves/widgets/viewer/video/fijkplayer.dart';
import 'package:collection/collection.dart';

class VideoConductor {
  final List<AvesVideoController> _controllers = [];
  final List<StreamSubscription> _subscriptions = [];

  static const _defaultMaxControllerCount = 3;

  VideoConductor();

  Future<void> dispose() async {
    await disposeAll();
    _subscriptions
      ..forEach((sub) => sub.cancel())
      ..clear();
    _controllers.clear();
    if (settings.keepScreenOn == KeepScreenOn.videoPlayback) {
      await windowService.keepScreenOn(false);
    }
  }

  AvesVideoController getOrCreateController(AvesEntry entry, {int? maxControllerCount}) {
    var controller = getController(entry);
    if (controller != null) {
      _controllers.remove(controller);
    } else {
      controller = IjkPlayerAvesVideoController(entry, persistPlayback: true);
      _subscriptions.add(controller.statusStream.listen(_onControllerStatusChanged));
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

  Future<void> _onControllerStatusChanged(VideoStatus status) async {
    if (settings.keepScreenOn == KeepScreenOn.videoPlayback) {
      await windowService.keepScreenOn(status == VideoStatus.playing);
    }
  }

  Future<void> _applyToAll(FutureOr Function(AvesVideoController controller) action) => Future.forEach<AvesVideoController>(_controllers, action);

  Future<void> disposeAll() => _applyToAll((controller) => controller.dispose());

  Future<void> pauseAll() => _applyToAll((controller) => controller.pause());

  Future<void> muteAll(bool muted) => _applyToAll((controller) => controller.mute(muted));
}
