import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves_model/aves_model.dart';
import 'package:flutter/widgets.dart';

extension ExtraVaultLockTypeView on VaultLockType {
  String getText(BuildContext context) {
    switch (this) {
      case VaultLockType.system:
        return context.l10n.settingsSystemDefault;
      case VaultLockType.pattern:
        return context.l10n.vaultLockTypePattern;
      case VaultLockType.pin:
        return context.l10n.vaultLockTypePin;
      case VaultLockType.password:
        return context.l10n.vaultLockTypePassword;
    }
  }
}
