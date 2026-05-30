import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves_model/aves_model.dart';
import 'package:flutter/material.dart';

extension ExtraChipSetActionView on ChipSetAction {
  String getText(BuildContext context) {
    final l10n = context.l10n;
    return switch (this) {
      // general
      .configureView => l10n.menuActionConfigureView,
      .select => l10n.menuActionSelect,
      .selectAll => l10n.menuActionSelectAll,
      .selectNone => l10n.menuActionSelectNone,
      // browsing
      .search => MaterialLocalizations.of(context).searchFieldLabel,
      .toggleTitleSearch =>
        // different data depending on toggle state
        l10n.collectionActionShowTitleSearch,
      .createGroup => l10n.chipActionCreateGroup,
      .createAlbum => l10n.chipActionCreateAlbum,
      .createVault => l10n.chipActionCreateVault,
      // browsing or selecting
      .map => l10n.menuActionMap,
      .slideshow => l10n.menuActionSlideshow,
      .stats => l10n.menuActionStats,
      // selecting (single/multiple filters)
      .delete => l10n.chipActionDelete,
      .remove => l10n.chipActionRemove,
      .hide => l10n.chipActionHide,
      .pin => l10n.chipActionPin,
      .unpin => l10n.chipActionUnpin,
      .group => l10n.chipActionGroup,
      .lockVault => l10n.chipActionLock,
      .showCountryStates => l10n.chipActionShowCountryStates,
      .showCollection => l10n.chipActionShowCollection,
      // selecting (single filter)
      .rename => l10n.chipActionRename,
      .setCover => l10n.chipActionSetCover,
      .configureVault => l10n.chipActionConfigureVault,
    };
  }

  Widget getIcon() => Icon(_getIconData());

  IconData _getIconData() {
    return switch (this) {
      // general
      .configureView => AIcons.view,
      .select => AIcons.select,
      .selectAll => AIcons.selected,
      .selectNone => AIcons.unselected,
      // browsing
      .search => AIcons.search,
      .toggleTitleSearch =>
        // different data depending on toggle state
        AIcons.filter,
      .createGroup => AIcons.add,
      .createAlbum => AIcons.add,
      .createVault => AIcons.vaultAdd,
      // browsing or selecting
      .map => AIcons.map,
      .slideshow => AIcons.slideshow,
      .stats => AIcons.stats,
      // selecting (single/multiple filters)
      .delete => AIcons.delete,
      .remove => AIcons.remove,
      .hide => AIcons.hide,
      .pin => AIcons.pin,
      .unpin => AIcons.unpin,
      .group => AIcons.group,
      .lockVault => AIcons.vaultLock,
      .showCountryStates => AIcons.state,
      .showCollection => AIcons.allCollection,
      // selecting (single filter)
      .rename => AIcons.rename,
      .setCover => AIcons.setCover,
      .configureVault => AIcons.vaultConfigure,
    };
  }
}
