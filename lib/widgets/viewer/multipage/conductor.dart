import 'package:aves/model/entry/entry.dart';
import 'package:aves/widgets/viewer/multipage/controller.dart';
import 'package:collection/collection.dart';

class MultiPageConductor {
  final List<MultiPageController> _controllers = [];

  static const maxControllerCount = 3;

  Future<void> dispose() async {
    await Future.forEach<MultiPageController>(_controllers, (controller) => controller.dispose());
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
}
