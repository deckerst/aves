import 'package:aves/services/common/services.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:flutter/widgets.dart';

import 'enums.dart';

extension ExtraKeepScreenOn on KeepScreenOn {
  String getName(BuildContext context) {
    switch (this) {
      case KeepScreenOn.never:
        return context.l10n.keepScreenOnNever;
      case KeepScreenOn.viewerOnly:
        return context.l10n.keepScreenOnViewerOnly;
      case KeepScreenOn.always:
        return context.l10n.keepScreenOnAlways;
    }
  }

  void apply() {
    windowService.keepScreenOn(this == KeepScreenOn.always);
  }
}
