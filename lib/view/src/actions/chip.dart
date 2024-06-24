import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves_model/aves_model.dart';
import 'package:flutter/widgets.dart';

extension ExtraChipActionView on ChipAction {
  String getText(BuildContext context) {
    final l10n = context.l10n;
    return switch (this) {
      ChipAction.goToAlbumPage => l10n.chipActionGoToAlbumPage,
      ChipAction.goToCountryPage => l10n.chipActionGoToCountryPage,
      ChipAction.goToPlacePage => l10n.chipActionGoToPlacePage,
      ChipAction.goToTagPage => l10n.chipActionGoToTagPage,
      ChipAction.goToExplorerPage => l10n.chipActionGoToExplorerPage,
      ChipAction.ratingOrGreater ||
      ChipAction.ratingOrLower =>
        // different data depending on state
        toString(),
      ChipAction.reverse =>
        // different data depending on state
        l10n.chipActionFilterOut,
      ChipAction.hide => l10n.chipActionHide,
      ChipAction.lockVault => l10n.chipActionLock,
    };
  }

  Widget getIcon() => Icon(_getIconData());

  IconData _getIconData() => switch (this) {
        ChipAction.goToAlbumPage => AIcons.album,
        ChipAction.goToCountryPage => AIcons.country,
        ChipAction.goToPlacePage => AIcons.place,
        ChipAction.goToTagPage => AIcons.tag,
        ChipAction.goToExplorerPage => AIcons.explorer,
        ChipAction.ratingOrGreater || ChipAction.ratingOrLower => AIcons.rating,
        ChipAction.reverse => AIcons.reverse,
        ChipAction.hide => AIcons.hide,
        ChipAction.lockVault => AIcons.vaultLock,
      };
}
