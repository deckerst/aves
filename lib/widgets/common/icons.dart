import 'dart:ui';

import 'package:aves/model/image_entry.dart';
import 'package:aves/utils/android_file_utils.dart';
import 'package:aves/widgets/common/image_providers/app_icon_image_provider.dart';
import 'package:flutter/material.dart';
import 'package:outline_material_icons/outline_material_icons.dart';

class AIcons {
  static const IconData allMedia = OMIcons.collections;
  static const IconData image = OMIcons.photo;
  static const IconData video = OMIcons.movie;
  static const IconData vector = OMIcons.code;

  static const IconData checked = OMIcons.done;
  static const IconData date = OMIcons.calendarToday;
  static const IconData disc = Icons.fiber_manual_record;
  static const IconData error = OMIcons.errorOutline;
  static const IconData location = OMIcons.place;
  static const IconData shooting = OMIcons.camera;
  static const IconData removableStorage = OMIcons.sdStorage;
  static const IconData text = OMIcons.formatQuote;
  static const IconData tag = OMIcons.localOffer;

  // actions
  static const IconData clear = OMIcons.clear;
  static const IconData collapse = OMIcons.expandLess;
  static const IconData debug = OMIcons.whatshot;
  static const IconData delete = OMIcons.delete;
  static const IconData expand = OMIcons.expandMore;
  static const IconData favourite = OMIcons.favoriteBorder;
  static const IconData favouriteActive = OMIcons.favorite;
  static const IconData goUp = OMIcons.arrowUpward;
  static const IconData info = OMIcons.info;
  static const IconData openInNew = OMIcons.openInNew;
  static const IconData print = OMIcons.print;
  static const IconData rename = OMIcons.title;
  static const IconData rotateLeft = OMIcons.rotateLeft;
  static const IconData rotateRight = OMIcons.rotateRight;
  static const IconData search = OMIcons.search;
  static const IconData select = OMIcons.selectAll;
  static const IconData share = OMIcons.share;
  static const IconData sort = OMIcons.sort;
  static const IconData stats = OMIcons.pieChart;
  static const IconData zoomIn = OMIcons.add;
  static const IconData zoomOut = OMIcons.remove;

  // albums
  static const IconData album = OMIcons.photoAlbum;
  static const IconData cameraAlbum = OMIcons.photoCamera;
  static const IconData downloadAlbum = Icons.file_download;
  static const IconData screenshotAlbum = OMIcons.smartphone;

  // thumbnail overlay
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
      case AlbumType.camera:
        return Icon(AIcons.cameraAlbum, size: size);
      case AlbumType.screenshots:
      case AlbumType.screenRecordings:
        return Icon(AIcons.screenshotAlbum, size: size);
      case AlbumType.download:
        return Icon(AIcons.downloadAlbum, size: size);
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
