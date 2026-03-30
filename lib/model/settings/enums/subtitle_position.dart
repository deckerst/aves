import 'package:aves_model/aves_model.dart';
import 'package:flutter/painting.dart';

extension ExtraSubtitlePosition on SubtitlePosition {
  TextAlignVertical toTextAlignVertical() {
    switch (this) {
      case .top:
        return TextAlignVertical.top;
      case .bottom:
        return TextAlignVertical.bottom;
    }
  }
}
