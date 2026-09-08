import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves_model/aves_model.dart';
import 'package:flutter/widgets.dart';

extension ExtraVaultLockTypeView on VaultLockType {
  String getText(BuildContext context) {
    final l10n = context.l10n;
    return switch (this) {
      .system => l10n.settingsSystemDefault,
      .pattern => l10n.vaultLockTypePattern,
      .pin => l10n.vaultLockTypePin,
      .password => l10n.vaultLockTypePassword,
    };
  }
}
