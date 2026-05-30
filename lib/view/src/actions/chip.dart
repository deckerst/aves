import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves_model/aves_model.dart';
import 'package:flutter/widgets.dart';

extension ExtraChipActionView on ChipAction {
  String getText(BuildContext context) {
    final l10n = context.l10n;
    return switch (this) {
      .goToAlbumPage => l10n.chipActionGoToAlbumPage,
      .goToCountryPage => l10n.chipActionGoToCountryPage,
      .goToPlacePage => l10n.chipActionGoToPlacePage,
      .goToTagPage => l10n.chipActionGoToTagPage,
      .goToExplorerPage => l10n.chipActionGoToExplorerPage,
      .ratingOrGreater || .ratingOrLower =>
        // different data depending on state
        toString(),
      .decompose => l10n.chipActionDecompose,
      .reverse =>
        // different data depending on state
        l10n.chipActionFilterOut,
      .hide => l10n.chipActionHide,
      .lockVault => l10n.chipActionLock,
    };
  }

  Widget getIcon() => Icon(_getIconData());

  IconData _getIconData() => switch (this) {
    .goToAlbumPage => AIcons.album,
    .goToCountryPage => AIcons.country,
    .goToPlacePage => AIcons.place,
    .goToTagPage => AIcons.tag,
    .goToExplorerPage => AIcons.explorer,
    .ratingOrGreater || .ratingOrLower => AIcons.rating,
    .decompose => AIcons.split,
    .reverse => AIcons.reverse,
    .hide => AIcons.hide,
    .lockVault => AIcons.vaultLock,
  };
}
