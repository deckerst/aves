import 'dart:ui';

import 'package:aves_model/aves_model.dart';

extension ExtraEntryBackground on EntryBackground {
  bool get isColor {
    switch (this) {
      case EntryBackground.black:
      case EntryBackground.white:
        return true;
      default:
        return false;
    }
  }

  Color get color {
    switch (this) {
      case EntryBackground.white:
        return const Color(0xFFFFFFFF);
      case EntryBackground.black:
      default:
        return const Color(0xFF000000);
    }
  }
}
