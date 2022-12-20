import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:flutter/widgets.dart';

enum MapClusterAction {
  editLocation,
  removeLocation,
}

extension ExtraMapClusterAction on MapClusterAction {
  String getText(BuildContext context) {
    switch (this) {
      case MapClusterAction.editLocation:
        return context.l10n.entryInfoActionEditLocation;
      case MapClusterAction.removeLocation:
        return context.l10n.entryInfoActionRemoveLocation;
    }
  }

  Widget getIcon() => Icon(_getIconData());

  IconData _getIconData() {
    switch (this) {
      case MapClusterAction.editLocation:
        return AIcons.edit;
      case MapClusterAction.removeLocation:
        return AIcons.clear;
    }
  }
}
