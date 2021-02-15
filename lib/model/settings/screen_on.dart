import 'package:aves/services/window_service.dart';

enum KeepScreenOn { never, viewerOnly, always }

extension ExtraKeepScreenOn on KeepScreenOn {
  String get name {
    switch (this) {
      case KeepScreenOn.never:
        return 'Never';
      case KeepScreenOn.viewerOnly:
        return 'Viewer page only';
      case KeepScreenOn.always:
        return 'Always';
      default:
        return toString();
    }
  }

  void apply() {
    WindowService.keepScreenOn(this == KeepScreenOn.always);
  }
}
