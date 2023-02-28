import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:flutter/widgets.dart';

enum ChipAction {
  goToAlbumPage,
  goToCountryPage,
  goToPlacePage,
  goToTagPage,
  reverse,
  hide,
  lockVault,
}

extension ExtraChipAction on ChipAction {
  String getText(BuildContext context) {
    switch (this) {
      case ChipAction.goToAlbumPage:
        return context.l10n.chipActionGoToAlbumPage;
      case ChipAction.goToCountryPage:
        return context.l10n.chipActionGoToCountryPage;
      case ChipAction.goToPlacePage:
        return context.l10n.chipActionGoToPlacePage;
      case ChipAction.goToTagPage:
        return context.l10n.chipActionGoToTagPage;
      case ChipAction.reverse:
        // different data depending on state
        return context.l10n.chipActionFilterOut;
      case ChipAction.hide:
        return context.l10n.chipActionHide;
      case ChipAction.lockVault:
        return context.l10n.chipActionLock;
    }
  }

  Widget getIcon() => Icon(_getIconData());

  IconData _getIconData() {
    switch (this) {
      case ChipAction.goToAlbumPage:
        return AIcons.album;
      case ChipAction.goToCountryPage:
        return AIcons.country;
      case ChipAction.goToPlacePage:
        return AIcons.place;
      case ChipAction.goToTagPage:
        return AIcons.tag;
      case ChipAction.reverse:
        return AIcons.reverse;
      case ChipAction.hide:
        return AIcons.hide;
      case ChipAction.lockVault:
        return AIcons.vaultLock;
    }
  }
}
