import 'package:aves/image_providers/app_icon_image_provider.dart';
import 'package:aves/model/covers.dart';
import 'package:aves/model/vaults/vaults.dart';
import 'package:aves/theme/icons.dart';
import 'package:material_ui/material_ui.dart';

class IconUtils {
  static Widget? getAlbumIcon({
    required BuildContext context,
    required String albumPath,
    double? size,
  }) {
    size ??= IconTheme.of(context).size;
    Widget buildIcon(IconData icon) => Icon(icon, size: size);

    switch (covers.effectiveAlbumType(albumPath)) {
      case .camera:
        return buildIcon(AIcons.cameraAlbum);
      case .screenshots:
      case .videoCaptures:
        return buildIcon(AIcons.screenshotAlbum);
      case .screenRecordings:
        return buildIcon(AIcons.recordingAlbum);
      case .download:
        return buildIcon(AIcons.downloadAlbum);
      case .app:
        final package = covers.effectiveAlbumPackage(albumPath);
        return package != null
            ? Image(
          image: AppIconImage(
            packageName: package,
            size: size!,
          ),
          width: size,
          height: size,
        )
            : null;
      case .vault:
        return buildIcon(vaults.isLocked(albumPath) ? AIcons.locked : AIcons.unlocked);
      case .regular:
        return null;
    }
  }
}
