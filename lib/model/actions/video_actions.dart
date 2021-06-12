import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:flutter/widgets.dart';

enum VideoAction {
  togglePlay,
  setSpeed,
}

class VideoActions {
  static const all = [
    VideoAction.togglePlay,
    VideoAction.setSpeed,
  ];
}

extension ExtraVideoAction on VideoAction {
  String getText(BuildContext context) {
    switch (this) {
      case VideoAction.togglePlay:
        // different data depending on toggle state
        return context.l10n.videoActionPlay;
      case VideoAction.setSpeed:
        return context.l10n.videoActionSetSpeed;
    }
  }

  IconData? getIcon() {
    switch (this) {
      case VideoAction.togglePlay:
        // different data depending on toggle state
        return AIcons.play;
      case VideoAction.setSpeed:
        return AIcons.speed;
    }
  }
}
