import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves_model/aves_model.dart';
import 'package:flutter/widgets.dart';

extension ExtraChipActionView on ChipAction {
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
      case ChipAction.ratingOrGreater:
      case ChipAction.ratingOrLower:
        // different data depending on state
        return toString();
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

  IconData _getIconData() => switch (this) {
        ChipAction.goToAlbumPage => AIcons.album,
        ChipAction.goToCountryPage => AIcons.country,
        ChipAction.goToPlacePage => AIcons.place,
        ChipAction.goToTagPage => AIcons.tag,
        ChipAction.ratingOrGreater || ChipAction.ratingOrLower => AIcons.rating,
        ChipAction.reverse => AIcons.reverse,
        ChipAction.hide => AIcons.hide,
        ChipAction.lockVault => AIcons.vaultLock,
      };
}
