import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves_model/aves_model.dart';
import 'package:flutter/material.dart';

extension ExtraChipSetActionView on ChipSetAction {
  String getText(BuildContext context) {
    final l10n = context.l10n;
    return switch (this) {
      // general
      ChipSetAction.configureView => l10n.menuActionConfigureView,
      ChipSetAction.select => l10n.menuActionSelect,
      ChipSetAction.selectAll => l10n.menuActionSelectAll,
      ChipSetAction.selectNone => l10n.menuActionSelectNone,
      // browsing
      ChipSetAction.search => MaterialLocalizations.of(context).searchFieldLabel,
      ChipSetAction.toggleTitleSearch =>
        // different data depending on toggle state
        l10n.collectionActionShowTitleSearch,
      ChipSetAction.createGroup => l10n.chipActionCreateGroup,
      ChipSetAction.createAlbum => l10n.chipActionCreateAlbum,
      ChipSetAction.createVault => l10n.chipActionCreateVault,
      // browsing or selecting
      ChipSetAction.map => l10n.menuActionMap,
      ChipSetAction.slideshow => l10n.menuActionSlideshow,
      ChipSetAction.stats => l10n.menuActionStats,
      // selecting (single/multiple filters)
      ChipSetAction.delete => l10n.chipActionDelete,
      ChipSetAction.remove => l10n.chipActionRemove,
      ChipSetAction.hide => l10n.chipActionHide,
      ChipSetAction.pin => l10n.chipActionPin,
      ChipSetAction.unpin => l10n.chipActionUnpin,
      ChipSetAction.group => l10n.chipActionGroup,
      ChipSetAction.lockVault => l10n.chipActionLock,
      ChipSetAction.showCountryStates => l10n.chipActionShowCountryStates,
      ChipSetAction.showCollection => l10n.chipActionShowCollection,
      // selecting (single filter)
      ChipSetAction.rename => l10n.chipActionRename,
      ChipSetAction.setCover => l10n.chipActionSetCover,
      ChipSetAction.configureVault => l10n.chipActionConfigureVault,
    };
  }

  Widget getIcon() => Icon(_getIconData());

  IconData _getIconData() {
    return switch (this) {
      // general
      ChipSetAction.configureView => AIcons.view,
      ChipSetAction.select => AIcons.select,
      ChipSetAction.selectAll => AIcons.selected,
      ChipSetAction.selectNone => AIcons.unselected,
      // browsing
      ChipSetAction.search => AIcons.search,
      ChipSetAction.toggleTitleSearch =>
        // different data depending on toggle state
        AIcons.filter,
      ChipSetAction.createGroup => AIcons.add,
      ChipSetAction.createAlbum => AIcons.add,
      ChipSetAction.createVault => AIcons.vaultAdd,
      // browsing or selecting
      ChipSetAction.map => AIcons.map,
      ChipSetAction.slideshow => AIcons.slideshow,
      ChipSetAction.stats => AIcons.stats,
      // selecting (single/multiple filters)
      ChipSetAction.delete => AIcons.delete,
      ChipSetAction.remove => AIcons.remove,
      ChipSetAction.hide => AIcons.hide,
      ChipSetAction.pin => AIcons.pin,
      ChipSetAction.unpin => AIcons.unpin,
      ChipSetAction.group => AIcons.group,
      ChipSetAction.lockVault => AIcons.vaultLock,
      ChipSetAction.showCountryStates => AIcons.state,
      ChipSetAction.showCollection => AIcons.allCollection,
      // selecting (single filter)
      ChipSetAction.rename => AIcons.rename,
      ChipSetAction.setCover => AIcons.setCover,
      ChipSetAction.configureVault => AIcons.vaultConfigure,
    };
  }
}
