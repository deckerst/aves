import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves_model/aves_model.dart';
import 'package:flutter/widgets.dart';

extension ExtraDateEditActionView on DateEditAction {
  String getText(BuildContext context) {
    final l10n = context.l10n;
    return switch (this) {
      .setCustom => l10n.editEntryDateDialogSetCustom,
      .copyField => l10n.editEntryDateDialogCopyField,
      .copyItem => l10n.editEntryDialogCopyFromItem,
      .extractFromFileName => l10n.editEntryDateDialogExtractFromTitle,
      .shift => l10n.editEntryDateDialogShift,
      .remove => l10n.actionRemove,
    };
  }
}
