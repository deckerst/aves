import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves_model/aves_model.dart';
import 'package:flutter/widgets.dart';

extension ExtraAlbumTypeView on AlbumType {
  String? getName(BuildContext context) {
    final l10n = context.l10n;
    return switch (this) {
      AlbumType.camera => l10n.albumCamera,
      AlbumType.download => l10n.albumDownload,
      AlbumType.screenshots => l10n.albumScreenshots,
      AlbumType.screenRecordings => l10n.albumScreenRecordings,
      AlbumType.videoCaptures => l10n.albumVideoCaptures,
      AlbumType.regular || AlbumType.vault || AlbumType.app => null,
    };
  }
}
