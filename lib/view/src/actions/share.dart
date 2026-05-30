import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves_model/aves_model.dart';
import 'package:flutter/widgets.dart';

extension ExtraShareActionView on ShareAction {
  String getText(BuildContext context) {
    final l10n = context.l10n;
    return switch (this) {
      .imageOnly => l10n.entryActionShareImageOnly,
      .videoOnly => l10n.entryActionShareVideoOnly,
    };
  }

  Widget getIcon() => Icon(_getIconData());

  IconData _getIconData() {
    return switch (this) {
      .imageOnly => AIcons.image,
      .videoOnly => AIcons.video,
    };
  }
}
