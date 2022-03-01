import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:flutter/widgets.dart';

enum ChipAction {
  goToAlbumPage,
  goToCountryPage,
  goToTagPage,
  hide,
}

extension ExtraChipAction on ChipAction {
  String getText(BuildContext context) {
    switch (this) {
      case ChipAction.goToAlbumPage:
        return context.l10n.chipActionGoToAlbumPage;
      case ChipAction.goToCountryPage:
        return context.l10n.chipActionGoToCountryPage;
      case ChipAction.goToTagPage:
        return context.l10n.chipActionGoToTagPage;
      case ChipAction.hide:
        return context.l10n.chipActionHide;
    }
  }

  Widget getIcon() => Icon(_getIconData());

  IconData _getIconData() {
    switch (this) {
      case ChipAction.goToAlbumPage:
        return AIcons.album;
      case ChipAction.goToCountryPage:
        return AIcons.location;
      case ChipAction.goToTagPage:
        return AIcons.tag;
      case ChipAction.hide:
        return AIcons.hide;
    }
  }
}
