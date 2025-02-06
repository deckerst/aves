import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves_model/aves_model.dart';
import 'package:flutter/widgets.dart';

extension ExtraLocationEditActionView on LocationEditAction {
  String getText(BuildContext context) {
    final l10n = context.l10n;
    return switch (this) {
      LocationEditAction.chooseOnMap => l10n.editEntryLocationDialogChooseOnMap,
      LocationEditAction.copyItem => l10n.editEntryDialogCopyFromItem,
      LocationEditAction.setCustom => l10n.editEntryLocationDialogSetCustom,
      LocationEditAction.importGpx => l10n.editEntryLocationDialogImportGpx,
      LocationEditAction.remove => l10n.actionRemove,
    };
  }
}
