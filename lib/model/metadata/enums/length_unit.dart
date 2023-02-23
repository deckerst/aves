import 'package:aves/model/metadata/enums/enums.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:flutter/widgets.dart';

extension ExtraLengthUnit on LengthUnit {
  String getText(BuildContext context) {
    switch (this) {
      case LengthUnit.px:
        return context.l10n.lengthUnitPixel;
      case LengthUnit.percent:
        return context.l10n.lengthUnitPercent;
    }
  }
}
