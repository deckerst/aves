import 'package:aves/widgets/common/icons.dart';
import 'package:flutter/widgets.dart';

enum ChipSetAction {
  sort,
}

enum ChipAction {
  pin,
  unpin,
  rename,
}

extension ExtraChipAction on ChipAction {
  String getText() {
    switch (this) {
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
      case ChipAction.pin:
      case ChipAction.unpin:
        return AIcons.pin;
      case ChipAction.rename:
        return AIcons.rename;
    }
    return null;
  }
}
