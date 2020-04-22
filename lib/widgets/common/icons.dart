import 'dart:ui';

import 'package:aves/model/image_entry.dart';
import 'package:aves/utils/android_file_utils.dart';
import 'package:aves/widgets/common/image_providers/app_icon_image_provider.dart';
import 'package:flutter/material.dart';
import 'package:outline_material_icons/outline_material_icons.dart';

class AIcons {
  static const IconData date = OMIcons.calendarToday;
  static const IconData favourite = OMIcons.favoriteBorder;
  static const IconData favouriteActive = OMIcons.favorite;
  static const IconData location = OMIcons.place;
  static const IconData tag = OMIcons.localOffer;
  static const IconData video = OMIcons.movie;

  static const IconData animated = Icons.slideshow;
  static const IconData play = Icons.play_circle_outline;
  static const IconData selected = Icons.check_circle_outline;
  static const IconData unselected = Icons.radio_button_unchecked;
}

class VideoIcon extends StatelessWidget {
  final ImageEntry entry;
  final double iconSize;

  const VideoIcon({Key key, this.entry, this.iconSize}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OverlayIcon(
      icon: AIcons.play,
      size: iconSize,
      text: entry.durationText,
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
      iconSize: iconSize * .8,
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

class OverlayIcon extends StatelessWidget {
  final IconData icon;
  final double size, iconSize;
  final String text;

  const OverlayIcon({
    Key key,
    @required this.icon,
    @required this.size,
    double iconSize,
    this.text,
  })  : iconSize = iconSize ?? size,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final iconChild = SizedBox(
      width: size,
      height: size,
      child: Icon(
        icon,
        size: iconSize,
      ),
    );

    return Container(
      margin: const EdgeInsets.all(1),
      padding: text != null ? EdgeInsets.only(right: size / 4) : null,
      decoration: BoxDecoration(
        color: const Color(0xBB000000),
        borderRadius: BorderRadius.all(
          Radius.circular(size),
        ),
      ),
      child: text == null
          ? iconChild
          : Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                iconChild,
                const SizedBox(width: 2),
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
  }) {
    switch (androidFileUtils.getAlbumType(album)) {
      case AlbumType.Camera:
        return Icon(OMIcons.photoCamera, size: size);
      case AlbumType.Screenshots:
      case AlbumType.ScreenRecordings:
        return Icon(OMIcons.smartphone, size: size);
      case AlbumType.Download:
        return Icon(Icons.file_download, size: size);
      case AlbumType.App:
        return Image(
          image: AppIconImage(
            packageName: androidFileUtils.getAlbumAppPackageName(album),
            size: size,
          ),
          width: size,
          height: size,
        );
      case AlbumType.Default:
      default:
        return null;
    }
  }
}
