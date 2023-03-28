import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves_model/aves_model.dart';
import 'package:flutter/material.dart';

extension ExtraChipSetAction on ChipSetAction {
  String getText(BuildContext context) {
    switch (this) {
      // general
      case ChipSetAction.configureView:
        return context.l10n.menuActionConfigureView;
      case ChipSetAction.select:
        return context.l10n.menuActionSelect;
      case ChipSetAction.selectAll:
        return context.l10n.menuActionSelectAll;
      case ChipSetAction.selectNone:
        return context.l10n.menuActionSelectNone;
      // browsing
      case ChipSetAction.search:
        return MaterialLocalizations.of(context).searchFieldLabel;
      case ChipSetAction.toggleTitleSearch:
        // different data depending on toggle state
        return context.l10n.collectionActionShowTitleSearch;
      case ChipSetAction.createAlbum:
        return context.l10n.chipActionCreateAlbum;
      case ChipSetAction.createVault:
        return context.l10n.chipActionCreateVault;
      // browsing or selecting
      case ChipSetAction.map:
        return context.l10n.menuActionMap;
      case ChipSetAction.slideshow:
        return context.l10n.menuActionSlideshow;
      case ChipSetAction.stats:
        return context.l10n.menuActionStats;
      // selecting (single/multiple filters)
      case ChipSetAction.delete:
        return context.l10n.chipActionDelete;
      case ChipSetAction.hide:
        return context.l10n.chipActionHide;
      case ChipSetAction.pin:
        return context.l10n.chipActionPin;
      case ChipSetAction.unpin:
        return context.l10n.chipActionUnpin;
      case ChipSetAction.lockVault:
        return context.l10n.chipActionLock;
      case ChipSetAction.showCountryStates:
        return context.l10n.chipActionShowCountryStates;
      // selecting (single filter)
      case ChipSetAction.rename:
        return context.l10n.chipActionRename;
      case ChipSetAction.setCover:
        return context.l10n.chipActionSetCover;
      case ChipSetAction.configureVault:
        return context.l10n.chipActionConfigureVault;
    }
  }

  Widget getIcon() => Icon(_getIconData());

  IconData _getIconData() {
    switch (this) {
      // general
      case ChipSetAction.configureView:
        return AIcons.view;
      case ChipSetAction.select:
        return AIcons.select;
      case ChipSetAction.selectAll:
        return AIcons.selected;
      case ChipSetAction.selectNone:
        return AIcons.unselected;
      // browsing
      case ChipSetAction.search:
        return AIcons.search;
      case ChipSetAction.toggleTitleSearch:
        // different data depending on toggle state
        return AIcons.filter;
      case ChipSetAction.createAlbum:
        return AIcons.add;
      case ChipSetAction.createVault:
        return AIcons.vaultAdd;
      // browsing or selecting
      case ChipSetAction.map:
        return AIcons.map;
      case ChipSetAction.slideshow:
        return AIcons.slideshow;
      case ChipSetAction.stats:
        return AIcons.stats;
      // selecting (single/multiple filters)
      case ChipSetAction.delete:
        return AIcons.delete;
      case ChipSetAction.hide:
        return AIcons.hide;
      case ChipSetAction.pin:
        return AIcons.pin;
      case ChipSetAction.unpin:
        return AIcons.unpin;
      case ChipSetAction.lockVault:
        return AIcons.vaultLock;
      case ChipSetAction.showCountryStates:
        return AIcons.state;
      // selecting (single filter)
      case ChipSetAction.rename:
        return AIcons.name;
      case ChipSetAction.setCover:
        return AIcons.setCover;
      case ChipSetAction.configureVault:
        return AIcons.vaultConfigure;
    }
  }
}
