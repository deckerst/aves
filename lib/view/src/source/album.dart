import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves_model/aves_model.dart';
import 'package:flutter/widgets.dart';

extension ExtraAlbumTypeView on AlbumType {
  String? getName(BuildContext context) {
    final l10n = context.l10n;
    return switch (this) {
      .camera => l10n.albumCamera,
      .download => l10n.albumDownload,
      .screenshots => l10n.albumScreenshots,
      .screenRecordings => l10n.albumScreenRecordings,
      .videoCaptures => l10n.albumVideoCaptures,
      .regular || .vault || .app => null,
    };
  }
}
