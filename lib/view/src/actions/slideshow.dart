import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves_model/aves_model.dart';
import 'package:flutter/widgets.dart';

extension ExtraSlideshowActionView on SlideshowAction {
  String getText(BuildContext context) {
    final l10n = context.l10n;
    return switch (this) {
      SlideshowAction.resume => l10n.slideshowActionResume,
      SlideshowAction.showInCollection => l10n.slideshowActionShowInCollection,
      SlideshowAction.cast => l10n.entryActionCast,
      SlideshowAction.settings => l10n.viewerActionSettings,
    };
  }

  Widget getIcon() => Icon(_getIconData());

  IconData _getIconData() {
    return switch (this) {
      SlideshowAction.resume => AIcons.play,
      SlideshowAction.showInCollection => AIcons.allCollection,
      SlideshowAction.cast => AIcons.cast,
      SlideshowAction.settings => AIcons.settings,
    };
  }
}
