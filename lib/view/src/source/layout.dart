import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves_model/aves_model.dart';
import 'package:flutter/widgets.dart';

extension ExtraTileLayoutView on TileLayout {
  String getName(BuildContext context) {
    final l10n = context.l10n;
    return switch (this) {
      TileLayout.mosaic => l10n.tileLayoutMosaic,
      TileLayout.grid => l10n.tileLayoutGrid,
      TileLayout.list => l10n.tileLayoutList,
    };
  }

  IconData get icon {
    return switch (this) {
      TileLayout.mosaic => AIcons.layoutMosaic,
      TileLayout.grid => AIcons.layoutGrid,
      TileLayout.list => AIcons.layoutList,
    };
  }
}
