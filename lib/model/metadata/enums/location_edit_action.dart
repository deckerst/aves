import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves_model/aves_model.dart';
import 'package:flutter/widgets.dart';

extension ExtraLocationEditAction on LocationEditAction {
  String getText(BuildContext context) {
    switch (this) {
      case LocationEditAction.chooseOnMap:
        return context.l10n.editEntryLocationDialogChooseOnMap;
      case LocationEditAction.copyItem:
        return context.l10n.editEntryDialogCopyFromItem;
      case LocationEditAction.setCustom:
        return context.l10n.editEntryLocationDialogSetCustom;
      case LocationEditAction.remove:
        return context.l10n.actionRemove;
    }
  }
}
