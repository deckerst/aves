import 'package:aves/widgets/common/icons.dart';
import 'package:flutter/widgets.dart';

enum ChipAction {
  sort,
}

enum AlbumAction {
  pin,
  unpin,
  rename,
}

extension ExtraAlbumAction on AlbumAction {
  String getText() {
    switch (this) {
      case AlbumAction.pin:
        return 'Pin to top';
      case AlbumAction.unpin:
        return 'Unpin from top';
      case AlbumAction.rename:
        return 'Rename';
    }
    return null;
  }

  IconData getIcon() {
    switch (this) {
      case AlbumAction.pin:
      case AlbumAction.unpin:
        return AIcons.pin;
      case AlbumAction.rename:
        return AIcons.rename;
    }
    return null;
  }
}
