import 'package:aves/theme/text.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves_model/aves_model.dart';
import 'package:flutter/widgets.dart';

extension ExtraConvertDimensionView on ConvertDimension {
  String getText(BuildContext context) {
    final l10n = context.l10n;
    return switch (this) {
      .width => l10n.exportEntryDialogWidth,
      .height => l10n.exportEntryDialogHeight,
      .both => '${l10n.exportEntryDialogWidth}${AText.resolutionSeparator}${l10n.exportEntryDialogHeight}',
    };
  }
}
