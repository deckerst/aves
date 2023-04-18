import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves_model/aves_model.dart';
import 'package:flutter/widgets.dart';

extension ExtraSlideshowActionView on SlideshowAction {
  String getText(BuildContext context) {
    switch (this) {
      case SlideshowAction.resume:
        return context.l10n.slideshowActionResume;
      case SlideshowAction.showInCollection:
        return context.l10n.slideshowActionShowInCollection;
      case SlideshowAction.settings:
        return context.l10n.viewerActionSettings;
    }
  }

  Widget getIcon() => Icon(_getIconData());

  IconData _getIconData() {
    switch (this) {
      case SlideshowAction.resume:
        return AIcons.play;
      case SlideshowAction.showInCollection:
        return AIcons.allCollection;
      case SlideshowAction.settings:
        return AIcons.settings;
    }
  }
}
