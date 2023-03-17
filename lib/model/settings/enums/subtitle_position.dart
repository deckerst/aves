import 'package:aves/model/settings/enums/enums.dart';
import 'package:flutter/widgets.dart';

extension ExtraSubtitlePosition on SubtitlePosition {
  TextAlignVertical toTextAlignVertical() {
    switch (this) {
      case SubtitlePosition.top:
        return TextAlignVertical.top;
      case SubtitlePosition.bottom:
        return TextAlignVertical.bottom;
    }
  }
}
