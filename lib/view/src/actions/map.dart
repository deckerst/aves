import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves_model/aves_model.dart';
import 'package:flutter/widgets.dart';

extension ExtraMapActionView on MapAction {
  String getText(BuildContext context) {
    switch (this) {
      case MapAction.selectStyle:
        return context.l10n.mapStyleTooltip;
      case MapAction.zoomIn:
        return context.l10n.mapZoomInTooltip;
      case MapAction.zoomOut:
        return context.l10n.mapZoomOutTooltip;
    }
  }

  Widget getIcon() => Icon(_getIconData());

  IconData _getIconData() {
    switch (this) {
      case MapAction.selectStyle:
        return AIcons.layers;
      case MapAction.zoomIn:
        return AIcons.zoomIn;
      case MapAction.zoomOut:
        return AIcons.zoomOut;
    }
  }
}
