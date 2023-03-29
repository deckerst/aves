import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves_model/aves_model.dart';
import 'package:flutter/widgets.dart';

extension ExtraLengthUnitView on LengthUnit {
  String getText(BuildContext context) {
    switch (this) {
      case LengthUnit.px:
        return context.l10n.lengthUnitPixel;
      case LengthUnit.percent:
        return context.l10n.lengthUnitPercent;
    }
  }
}
