import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:flutter/widgets.dart';

import 'enums.dart';

extension ExtraConfirmationDialog on ConfirmationDialog {
  String getName(BuildContext context) {
    switch (this) {
      case ConfirmationDialog.delete:
        return context.l10n.settingsConfirmationDialogDeleteItems;
      case ConfirmationDialog.moveToBin:
        return context.l10n.settingsConfirmationDialogMoveToBinItems;
    }
  }
}
