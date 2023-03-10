import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:flutter/widgets.dart';

import 'enums.dart';

extension ExtraVideoBackgroundMode on VideoBackgroundMode {
  String getName(BuildContext context) {
    switch (this) {
      case VideoBackgroundMode.disabled:
        return context.l10n.settingsDisabled;
      case VideoBackgroundMode.pip:
        return context.l10n.videoBackgroundModePip;
    }
  }
}
