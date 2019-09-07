import 'package:aves/model/image_entry.dart';
import 'package:aves/utils/android_app_service.dart';
import 'package:aves/utils/android_file_utils.dart';
import 'package:aves/widgets/common/app_icon.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';

class VideoIcon extends StatelessWidget {
  final ImageEntry entry;
  final double iconSize;

  const VideoIcon({Key key, this.entry, this.iconSize}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OverlayIcon(
      icon: Icons.play_circle_outline,
      iconSize: iconSize,
      text: entry.durationText,
    );
  }
}

class GifIcon extends StatelessWidget {
  final double iconSize;

  const GifIcon({Key key, this.iconSize}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OverlayIcon(
      icon: Icons.gif,
      iconSize: iconSize,
    );
  }
}

class GpsIcon extends StatelessWidget {
  final double iconSize;

  const GpsIcon({Key key, this.iconSize}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OverlayIcon(
      icon: Icons.place,
      iconSize: iconSize,
    );
  }
}

class OverlayIcon extends StatelessWidget {
  final IconData icon;
  final double iconSize;
  final String text;

  const OverlayIcon({Key key, this.icon, this.iconSize, this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(1),
      padding: text != null ? EdgeInsets.only(right: iconSize / 4) : null,
      decoration: BoxDecoration(
        color: Color(0xBB000000),
        borderRadius: BorderRadius.all(
          Radius.circular(iconSize),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: iconSize,
          ),
          if (text != null) ...[
            SizedBox(width: 2),
            Text(text),
          ]
        ],
      ),
    );
  }
}

class IconUtils {
  static Map appNameMap;

  static init() async {
    appNameMap = await AndroidAppService.getAppNames();
  }

  static Widget _buildAlbumIcon(Widget child) => Material(
        type: MaterialType.circle,
        elevation: 3,
        color: Colors.transparent,
        shadowColor: Colors.black,
        child: child,
      );

  static Widget getAlbumIcon(BuildContext context, String albumDirectory) {
    if (albumDirectory == null) return null;
    if (androidFileUtils.isCameraPath(albumDirectory)) return _buildAlbumIcon(Icon(Icons.photo_camera));
    if (androidFileUtils.isScreenshotsPath(albumDirectory)) return _buildAlbumIcon(Icon(Icons.smartphone));
    if (androidFileUtils.isDownloadPath(albumDirectory)) return _buildAlbumIcon(Icon(Icons.file_download));

    final parts = albumDirectory.split(separator);
    if (albumDirectory.startsWith(androidFileUtils.picturesPath) && appNameMap.keys.contains(parts.last)) {
      final packageName = appNameMap[parts.last];
      return _buildAlbumIcon(AppIcon(
        packageName: packageName,
        size: IconTheme.of(context).size,
        devicePixelRatio: MediaQuery.of(context).devicePixelRatio,
      ));
    }
    return null;
  }
}
