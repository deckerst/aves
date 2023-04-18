import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves_model/aves_model.dart';
import 'package:flutter/widgets.dart';

extension ExtraTileLayoutView on TileLayout {
  String getName(BuildContext context) {
    final l10n = context.l10n;
    switch (this) {
      case TileLayout.mosaic:
        return l10n.tileLayoutMosaic;
      case TileLayout.grid:
        return l10n.tileLayoutGrid;
      case TileLayout.list:
        return l10n.tileLayoutList;
    }
  }

  IconData get icon {
    switch (this) {
      case TileLayout.mosaic:
        return AIcons.layoutMosaic;
      case TileLayout.grid:
        return AIcons.layoutGrid;
      case TileLayout.list:
        return AIcons.layoutList;
    }
  }
}
