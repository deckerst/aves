import 'package:aves/theme/icons.dart';
import 'package:flutter/widgets.dart';

enum ChipSetAction {
  group,
  sort,
  refresh,
  stats,
}

enum ChipAction {
  delete,
  hide,
  pin,
  unpin,
  rename,
  goToAlbumPage,
  goToCountryPage,
  goToTagPage,
}

extension ExtraChipAction on ChipAction {
  String getText() {
    switch (this) {
      case ChipAction.delete:
        return 'Delete';
      case ChipAction.goToAlbumPage:
        return 'Show in Albums';
      case ChipAction.goToCountryPage:
        return 'Show in Countries';
      case ChipAction.goToTagPage:
        return 'Show in Tags';
      case ChipAction.hide:
        return 'Hide';
      case ChipAction.pin:
        return 'Pin to top';
      case ChipAction.unpin:
        return 'Unpin from top';
      case ChipAction.rename:
        return 'Rename';
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
    }
    return null;
  }
}
