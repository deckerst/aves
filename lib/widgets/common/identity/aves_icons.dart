import 'dart:ui';

import 'package:aves/image_providers/app_icon_image_provider.dart';
import 'package:aves/model/image_entry.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/utils/android_file_utils.dart';
import 'package:aves/utils/constants.dart';
import 'package:decorated_icon/decorated_icon.dart';
import 'package:flutter/material.dart';

class VideoIcon extends StatelessWidget {
  final ImageEntry entry;
  final double iconSize;
  final bool showDuration;

  const VideoIcon({
    Key key,
    this.entry,
    this.iconSize,
    this.showDuration,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OverlayIcon(
      icon: entry.is360 ? AIcons.threesixty : AIcons.play,
      size: iconSize,
      text: showDuration ? entry.durationText : null,
      iconScale: entry.is360 && showDuration ? .9 : 1,
    );
  }
}

class AnimatedImageIcon extends StatelessWidget {
  final double iconSize;

  const AnimatedImageIcon({Key key, this.iconSize}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OverlayIcon(
      icon: AIcons.animated,
      size: iconSize,
      iconScale: .8,
    );
  }
}

class GeotiffIcon extends StatelessWidget {
  final double iconSize;

  const GeotiffIcon({Key key, this.iconSize}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OverlayIcon(
      icon: AIcons.geo,
      size: iconSize,
    );
  }
}

class SphericalImageIcon extends StatelessWidget {
  final double iconSize;

  const SphericalImageIcon({Key key, this.iconSize}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OverlayIcon(
      icon: AIcons.threesixty,
      size: iconSize,
    );
  }
}

class GpsIcon extends StatelessWidget {
  final double iconSize;

  const GpsIcon({Key key, this.iconSize}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OverlayIcon(
      icon: AIcons.location,
      size: iconSize,
    );
  }
}

class RawIcon extends StatelessWidget {
  final double iconSize;

  const RawIcon({Key key, this.iconSize}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OverlayIcon(
      icon: AIcons.raw,
      size: iconSize,
    );
  }
}

class MultipageIcon extends StatelessWidget {
  final double iconSize;

  const MultipageIcon({Key key, this.iconSize}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OverlayIcon(
      icon: AIcons.multipage,
      size: iconSize,
      iconScale: .8,
    );
  }
}

class OverlayIcon extends StatelessWidget {
  final IconData icon;
  final double size;
  final String text;
  final double iconScale;

  const OverlayIcon({
    Key key,
    @required this.icon,
    @required this.size,
    this.iconScale = 1,
    this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final iconChild = Icon(icon, size: size);
    final iconBox = SizedBox(
      width: size,
      height: size,
      // using a transform is better than modifying the icon size to properly center the scaled icon
      child: iconScale != 1
          ? Transform.scale(
              scale: iconScale,
              child: iconChild,
            )
          : iconChild,
    );

    return Container(
      margin: EdgeInsets.all(1),
      padding: text != null ? EdgeInsets.only(right: size / 4) : null,
      decoration: BoxDecoration(
        color: Color(0xBB000000),
        borderRadius: BorderRadius.circular(size),
      ),
      child: text == null
          ? iconBox
          : Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                iconBox,
                SizedBox(width: 2),
                Text(text),
              ],
            ),
    );
  }
}

class IconUtils {
  static Widget getAlbumIcon({
    @required BuildContext context,
    @required String album,
    double size = 24,
    bool embossed = false,
  }) {
    Widget buildIcon(IconData icon) => embossed ? DecoratedIcon(icon, shadows: [Constants.embossShadow], size: size) : Icon(icon, size: size);
    switch (androidFileUtils.getAlbumType(album)) {
      case AlbumType.camera:
        return buildIcon(AIcons.cameraAlbum);
      case AlbumType.screenshots:
      case AlbumType.screenRecordings:
        return buildIcon(AIcons.screenshotAlbum);
      case AlbumType.download:
        return buildIcon(AIcons.downloadAlbum);
      case AlbumType.app:
        return Image(
          image: AppIconImage(
            packageName: androidFileUtils.getAlbumAppPackageName(album),
            size: size,
          ),
          width: size,
          height: size,
        );
      case AlbumType.regular:
      default:
        return null;
    }
  }
}
