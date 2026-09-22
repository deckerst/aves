import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves_model/aves_model.dart';
import 'package:flutter/widgets.dart';

extension ExtraThumbnailOverlayTagIconView on ThumbnailOverlayTagIcon {
  String getName(BuildContext context) {
    final l10n = context.l10n;
    return switch (this) {
      .tagged => l10n.filterTaggedLabel,
      .untagged => l10n.filterNoTagLabel,
      .none => l10n.settingsDisabled,
    };
  }

  IconData getIcon(BuildContext context) {
    return switch (this) {
      .tagged => AIcons.tag,
      .untagged => AIcons.tagUntagged,
      .none => AIcons.tag,
    };
  }
}
