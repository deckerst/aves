import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:flutter/widgets.dart';

enum ChipSetAction {
  group,
  sort,
  stats,
}

enum ChipAction {
  delete,
  hide,
  pin,
  unpin,
  rename,
  setCover,
  goToAlbumPage,
  goToCountryPage,
  goToTagPage,
}

extension ExtraChipAction on ChipAction {
  String getText(BuildContext context) {
    switch (this) {
      case ChipAction.delete:
        return context.l10n.chipActionDelete;
      case ChipAction.goToAlbumPage:
        return context.l10n.chipActionGoToAlbumPage;
      case ChipAction.goToCountryPage:
        return context.l10n.chipActionGoToCountryPage;
      case ChipAction.goToTagPage:
        return context.l10n.chipActionGoToTagPage;
      case ChipAction.hide:
        return context.l10n.chipActionHide;
      case ChipAction.pin:
        return context.l10n.chipActionPin;
      case ChipAction.unpin:
        return context.l10n.chipActionUnpin;
      case ChipAction.rename:
        return context.l10n.chipActionRename;
      case ChipAction.setCover:
        return context.l10n.chipActionSetCover;
    }
    return null;
  }

  IconData getIcon() {
    switch (this) {
      case ChipAction.delete:
        return AIcons.delete;
      case ChipAction.goToAlbumPage:
        return AIcons.album;
      case ChipAction.goToCountryPage:
        return AIcons.location;
      case ChipAction.goToTagPage:
        return AIcons.tag;
      case ChipAction.hide:
        return AIcons.hide;
      case ChipAction.pin:
      case ChipAction.unpin:
        return AIcons.pin;
      case ChipAction.rename:
        return AIcons.rename;
      case ChipAction.setCover:
        return AIcons.setCover;
    }
    return null;
  }
}
