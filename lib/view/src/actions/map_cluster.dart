import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves_model/aves_model.dart';
import 'package:flutter/widgets.dart';

extension ExtraMapClusterActionView on MapClusterAction {
  String getText(BuildContext context) {
    final l10n = context.l10n;
    return switch (this) {
      MapClusterAction.editLocation => l10n.entryInfoActionEditLocation,
      MapClusterAction.removeLocation => l10n.entryInfoActionRemoveLocation,
    };
  }

  Widget getIcon() => Icon(_getIconData());

  IconData _getIconData() {
    return switch (this) {
      MapClusterAction.editLocation => AIcons.edit,
      MapClusterAction.removeLocation => AIcons.clear,
    };
  }
}
