import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves_model/aves_model.dart';
import 'package:flutter/widgets.dart';

extension ExtraShareActionView on ShareAction {
  String getText(BuildContext context) {
    switch (this) {
      case ShareAction.imageOnly:
        return context.l10n.entryActionShareImageOnly;
      case ShareAction.videoOnly:
        return context.l10n.entryActionShareVideoOnly;
    }
  }

  Widget getIcon() => Icon(_getIconData());

  IconData _getIconData() {
    switch (this) {
      case ShareAction.imageOnly:
        return AIcons.image;
      case ShareAction.videoOnly:
        return AIcons.video;
    }
  }
}
