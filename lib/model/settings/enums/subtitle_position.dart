import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:flutter/widgets.dart';

import 'enums.dart';

extension ExtraSubtitlePosition on SubtitlePosition {
  String getName(BuildContext context) {
    switch (this) {
      case SubtitlePosition.top:
        return context.l10n.subtitlePositionTop;
      case SubtitlePosition.bottom:
        return context.l10n.subtitlePositionBottom;
    }
  }

  TextAlignVertical toTextAlignVertical() {
    switch (this) {
      case SubtitlePosition.top:
        return TextAlignVertical.top;
      case SubtitlePosition.bottom:
        return TextAlignVertical.bottom;
    }
  }
}
