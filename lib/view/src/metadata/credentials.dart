import 'package:aves/services/media/enums.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:flutter/widgets.dart';

extension ExtraC2paValidityView on C2paValidity {
  String getText(BuildContext context) {
    final l10n = context.l10n;
    return switch (this) {
      .unknown => l10n.filterCredentialsValidityUnknownLabel,
      .invalid => l10n.filterCredentialsValidityInvalidLabel,
      .valid => l10n.filterCredentialsValidityValidLabel,
      .trusted => l10n.filterCredentialsValidityTrustedLabel,
    };
  }

  IconData getIconData() {
    return switch (this) {
      .unknown => AIcons.credentialsUnknown,
      .invalid => AIcons.credentialsInvalid,
      .valid => AIcons.credentialsValid,
      .trusted => AIcons.credentialsTrusted,
    };
  }
}
