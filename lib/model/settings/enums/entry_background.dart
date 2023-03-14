import 'package:aves/model/settings/enums/enums.dart';
import 'package:flutter/material.dart';

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
        return Colors.white;
      case EntryBackground.black:
      default:
        return Colors.black;
    }
  }
}
