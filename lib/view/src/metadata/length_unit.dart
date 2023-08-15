import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves_model/aves_model.dart';
import 'package:flutter/widgets.dart';

extension ExtraLengthUnitView on LengthUnit {
  String getText(BuildContext context) {
    final l10n = context.l10n;
    return switch (this) {
      LengthUnit.px => l10n.lengthUnitPixel,
      LengthUnit.percent => l10n.lengthUnitPercent,
    };
  }
}
