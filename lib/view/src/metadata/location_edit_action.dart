import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves_model/aves_model.dart';
import 'package:flutter/widgets.dart';

extension ExtraLocationEditActionView on LocationEditAction {
  String getText(BuildContext context) {
    final l10n = context.l10n;
    return switch (this) {
      .chooseOnMap => l10n.editEntryLocationDialogChooseOnMap,
      .copyItem => l10n.editEntryDialogCopyFromItem,
      .setCustom => l10n.editEntryLocationDialogSetCustom,
      .importGpx => l10n.editEntryLocationDialogImportGpx,
      .remove => l10n.actionRemove,
    };
  }
}
