import 'package:aves/model/entry.dart';
import 'package:aves/widgets/viewer/video/controller.dart';
import 'package:aves/widgets/viewer/video/fijkplayer.dart';
import 'package:fijkplayer/fijkplayer.dart';

class VideoConductor {
  final List<AvesVideoController> _controllers = [];

  static const maxControllerCount = 3;

  VideoConductor() {
    FijkLog.setLevel(FijkLogLevel.Warn);
  }

  Future<void> dispose() async {
    await Future.forEach(_controllers, (controller) => controller.dispose());
    _controllers.clear();
  }

  AvesVideoController getOrCreateController(AvesEntry entry) {
    var controller = getController(entry);
    if (controller != null) {
      _controllers.remove(controller);
    } else {
      controller = IjkPlayerAvesVideoController(entry);
    }
    _controllers.insert(0, controller);
    while (_controllers.length > maxControllerCount) {
      _controllers.removeLast().dispose();
    }
    return controller;
  }

  AvesVideoController getController(AvesEntry entry) {
    return _controllers.firstWhere((c) => c.entry.uri == entry.uri && c.entry.pageId == entry.pageId, orElse: () => null);
  }

  void pauseAll() => _controllers.forEach((controller) => controller.pause());
}
