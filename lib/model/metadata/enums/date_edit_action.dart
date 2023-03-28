import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves_model/aves_model.dart';
import 'package:flutter/widgets.dart';

extension ExtraDateEditAction on DateEditAction {
  String getText(BuildContext context) {
    switch (this) {
      case DateEditAction.setCustom:
        return context.l10n.editEntryDateDialogSetCustom;
      case DateEditAction.copyField:
        return context.l10n.editEntryDateDialogCopyField;
      case DateEditAction.copyItem:
        return context.l10n.editEntryDialogCopyFromItem;
      case DateEditAction.extractFromTitle:
        return context.l10n.editEntryDateDialogExtractFromTitle;
      case DateEditAction.shift:
        return context.l10n.editEntryDateDialogShift;
      case DateEditAction.remove:
        return context.l10n.actionRemove;
    }
  }
}
