import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves_model/aves_model.dart';
import 'package:flutter/material.dart';

extension ExtraExplorerActionView on ExplorerAction {
  String getText(BuildContext context) {
    final l10n = context.l10n;
    return switch (this) {
      ExplorerAction.addShortcut => l10n.collectionActionAddShortcut,
      ExplorerAction.setHome => l10n.collectionActionSetHome,
      ExplorerAction.hide => l10n.chipActionHide,
      ExplorerAction.stats => l10n.menuActionStats,
    };
  }

  Widget getIcon() => Icon(_getIconData());

  IconData _getIconData() {
    return switch (this) {
      ExplorerAction.addShortcut => AIcons.addShortcut,
      ExplorerAction.setHome => AIcons.home,
      ExplorerAction.hide => AIcons.hide,
      ExplorerAction.stats => AIcons.stats,
    };
  }
}
