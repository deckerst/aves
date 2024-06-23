import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves_model/aves_model.dart';
import 'package:flutter/widgets.dart';

extension ExtraEntryConvertActionView on EntryConvertAction {
  String getText(BuildContext context) {
    final l10n = context.l10n;
    return switch (this) {
      EntryConvertAction.convert => l10n.entryActionConvert,
      EntryConvertAction.convertMotionPhotoToStillImage => l10n.entryActionConvertMotionPhotoToStillImage,
    };
  }

  IconData getIconData() {
    return switch (this) {
      EntryConvertAction.convert => AIcons.convert,
      EntryConvertAction.convertMotionPhotoToStillImage => AIcons.convertToStillImage,
    };
  }
}
