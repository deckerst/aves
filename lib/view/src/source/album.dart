import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves_model/aves_model.dart';
import 'package:flutter/widgets.dart';

extension ExtraAlbumTypeView on AlbumType {
  String? getName(BuildContext context) {
    switch (this) {
      case AlbumType.camera:
        return context.l10n.albumCamera;
      case AlbumType.download:
        return context.l10n.albumDownload;
      case AlbumType.screenshots:
        return context.l10n.albumScreenshots;
      case AlbumType.screenRecordings:
        return context.l10n.albumScreenRecordings;
      case AlbumType.videoCaptures:
        return context.l10n.albumVideoCaptures;
      case AlbumType.regular:
      case AlbumType.vault:
      case AlbumType.app:
        return null;
    }
  }
}
