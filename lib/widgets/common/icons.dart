import 'dart:ui';

import 'package:aves/model/image_entry.dart';
import 'package:aves/utils/android_file_utils.dart';
import 'package:aves/widgets/common/image_providers/app_icon_image_provider.dart';
import 'package:flutter/material.dart';

class AIcons {
  static const IconData allCollection = Icons.collections_outlined;
  static const IconData image = Icons.photo_outlined;
  static const IconData video = Icons.movie_outlined;
  static const IconData vector = Icons.code_outlined;

  static const IconData android = Icons.android;
  static const IconData checked = Icons.done_outlined;
  static const IconData date = Icons.calendar_today_outlined;
  static const IconData disc = Icons.fiber_manual_record;
  static const IconData error = Icons.error_outline;
  static const IconData location = Icons.place_outlined;
  static const IconData shooting = Icons.camera_outlined;
  static const IconData removableStorage = Icons.sd_storage_outlined;
  static const IconData settings = Icons.settings_outlined;
  static const IconData text = Icons.format_quote_outlined;
  static const IconData tag = Icons.local_offer_outlined;

  // actions
  static const IconData addShortcut = Icons.bookmark_border;
  static const IconData clear = Icons.clear_outlined;
  static const IconData collapse = Icons.expand_less_outlined;
  static const IconData createAlbum = Icons.add_circle_outline;
  static const IconData debug = Icons.whatshot_outlined;
  static const IconData delete = Icons.delete_outlined;
  static const IconData expand = Icons.expand_more_outlined;
  static const IconData favourite = Icons.favorite_border;
  static const IconData favouriteActive = Icons.favorite;
  static const IconData goUp = Icons.arrow_upward_outlined;
  static const IconData group = Icons.group_work_outlined;
  static const IconData info = Icons.info_outlined;
  static const IconData layers = Icons.layers_outlined;
  static const IconData openInNew = Icons.open_in_new_outlined;
  static const IconData pin = Icons.push_pin_outlined;
  static const IconData print = Icons.print_outlined;
  static const IconData refresh = Icons.refresh_outlined;
  static const IconData rename = Icons.title_outlined;
  static const IconData rotateLeft = Icons.rotate_left_outlined;
  static const IconData rotateRight = Icons.rotate_right_outlined;
  static const IconData search = Icons.search_outlined;
  static const IconData select = Icons.select_all_outlined;
  static const IconData share = Icons.share_outlined;
  static const IconData sort = Icons.sort_outlined;
  static const IconData stats = Icons.pie_chart_outlined;
  static const IconData zoomIn = Icons.add_outlined;
  static const IconData zoomOut = Icons.remove_outlined;

  // albums
  static const IconData album = Icons.photo_album_outlined;
  static const IconData cameraAlbum = Icons.photo_camera_outlined;
  static const IconData downloadAlbum = Icons.file_download;
  static const IconData screenshotAlbum = Icons.smartphone_outlined;

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
      margin: EdgeInsets.all(1),
      padding: text != null ? EdgeInsets.only(right: size / 4) : null,
      decoration: BoxDecoration(
        color: Color(0xBB000000),
        borderRadius: BorderRadius.circular(size),
      ),
      child: text == null
          ? iconChild
          : Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                iconChild,
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
