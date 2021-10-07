import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:flutter/widgets.dart';

import 'enums.dart';

extension ExtraUnitSystem on UnitSystem {
  String getName(BuildContext context) {
    switch (this) {
      case UnitSystem.metric:
        return context.l10n.unitSystemMetric;
      case UnitSystem.imperial:
        return context.l10n.unitSystemImperial;
    }
  }
}
