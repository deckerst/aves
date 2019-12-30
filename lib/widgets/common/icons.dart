import 'dart:ui';

import 'package:aves/model/image_entry.dart';
import 'package:aves/utils/android_file_utils.dart';
import 'package:aves/widgets/common/app_icon.dart';
import 'package:flutter/material.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:provider/provider.dart';

class VideoIcon extends StatelessWidget {
  final ImageEntry entry;
  final double iconSize;

  const VideoIcon({Key key, this.entry, this.iconSize}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OverlayIcon(
      icon: OMIcons.playCircleOutline,
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
      icon: OMIcons.gif,
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
      icon: OMIcons.place,
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
      margin: const EdgeInsets.all(1),
      padding: text != null ? EdgeInsets.only(right: iconSize / 4) : null,
      decoration: BoxDecoration(
        color: const Color(0xBB000000),
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
            const SizedBox(width: 2),
            Text(text),
          ]
        ],
      ),
    );
  }
}

class IconUtils {
  static Widget getAlbumIcon(BuildContext context, String albumDirectory) {
    switch (androidFileUtils.getAlbumType(albumDirectory)) {
      case AlbumType.Camera:
        return Icon(OMIcons.photoCamera);
      case AlbumType.Screenshots:
      case AlbumType.ScreenRecordings:
        return Icon(OMIcons.smartphone);
      case AlbumType.Download:
        return Icon(Icons.file_download);
      case AlbumType.App:
        return Selector<MediaQueryData, double>(
          selector: (c, mq) => mq.devicePixelRatio,
          builder: (c, devicePixelRatio, child) => AppIcon(
            packageName: androidFileUtils.getAlbumAppPackageName(albumDirectory),
            size: IconTheme.of(context).size,
            devicePixelRatio: devicePixelRatio,
          ),
        );
      case AlbumType.Default:
      default:
        return null;
    }
  }
}
