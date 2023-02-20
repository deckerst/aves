import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:flutter/widgets.dart';

enum VaultLockType { system, pin, password }

extension ExtraVaultLockType on VaultLockType {
  String getText(BuildContext context) {
    switch (this) {
      case VaultLockType.system:
        return context.l10n.settingsSystemDefault;
      case VaultLockType.pin:
        return context.l10n.vaultLockTypePin;
      case VaultLockType.password:
        return context.l10n.vaultLockTypePassword;
    }
  }
}
