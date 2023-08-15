import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves_model/aves_model.dart';
import 'package:flutter/widgets.dart';

extension ExtraDateEditActionView on DateEditAction {
  String getText(BuildContext context) {
    final l10n = context.l10n;
    return switch (this) {
      DateEditAction.setCustom => l10n.editEntryDateDialogSetCustom,
      DateEditAction.copyField => l10n.editEntryDateDialogCopyField,
      DateEditAction.copyItem => l10n.editEntryDialogCopyFromItem,
      DateEditAction.extractFromTitle => l10n.editEntryDateDialogExtractFromTitle,
      DateEditAction.shift => l10n.editEntryDateDialogShift,
      DateEditAction.remove => l10n.actionRemove,
    };
  }
}
