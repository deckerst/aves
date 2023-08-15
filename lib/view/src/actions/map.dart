import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves_model/aves_model.dart';
import 'package:flutter/widgets.dart';

extension ExtraMapActionView on MapAction {
  String getText(BuildContext context) {
    final l10n = context.l10n;
    return switch (this) {
      MapAction.selectStyle => l10n.mapStyleTooltip,
      MapAction.zoomIn => l10n.mapZoomInTooltip,
      MapAction.zoomOut => l10n.mapZoomOutTooltip,
    };
  }

  Widget getIcon() => Icon(_getIconData());

  IconData _getIconData() {
    return switch (this) {
      MapAction.selectStyle => AIcons.layers,
      MapAction.zoomIn => AIcons.zoomIn,
      MapAction.zoomOut => AIcons.zoomOut,
    };
  }
}
