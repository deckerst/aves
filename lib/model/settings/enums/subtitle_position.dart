import 'package:aves_model/aves_model.dart';
import 'package:flutter/painting.dart';

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
