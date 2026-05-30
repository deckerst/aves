import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves_model/aves_model.dart';
import 'package:flutter/widgets.dart';

extension ExtraMapActionView on MapAction {
  String getText(BuildContext context) {
    final l10n = context.l10n;
    return switch (this) {
      .selectStyle => l10n.mapStyleTooltip,
      .openMapApp => l10n.entryActionOpenMap,
      .zoomIn => l10n.mapZoomInTooltip,
      .zoomOut => l10n.mapZoomOutTooltip,
      .addShortcut => l10n.collectionActionAddShortcut,
    };
  }

  Widget getIcon() => Icon(_getIconData());

  IconData _getIconData() {
    return switch (this) {
      .selectStyle => AIcons.layers,
      .openMapApp => AIcons.openOutside,
      .zoomIn => AIcons.zoomIn,
      .zoomOut => AIcons.zoomOut,
      .addShortcut => AIcons.addShortcut,
    };
  }
}
