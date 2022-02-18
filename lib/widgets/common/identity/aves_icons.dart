import 'package:aves/image_providers/app_icon_image_provider.dart';
import 'package:aves/model/entry.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/utils/android_file_utils.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/grid/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class VideoIcon extends StatelessWidget {
  final AvesEntry entry;

  const VideoIcon({
    Key? key,
    required this.entry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final gridTheme = context.watch<GridThemeData>();
    final showDuration = gridTheme.showVideoDuration;
    Widget child = OverlayIcon(
      icon: entry.is360 ? AIcons.threeSixty : AIcons.videoThumb,
      text: showDuration ? entry.durationText : null,
      iconScale: entry.is360 && showDuration ? .9 : 1,
    );
    if (showDuration) {
      child = DefaultTextStyle(
        style: TextStyle(
          color: Colors.grey.shade200,
          fontSize: gridTheme.fontSize,
        ),
        child: child,
      );
    }
    return child;
  }
}

class AnimatedImageIcon extends StatelessWidget {
  const AnimatedImageIcon({Key? key}) : super(key: key);

  static const scale = .8;

  @override
  Widget build(BuildContext context) {
    return const OverlayIcon(
      icon: AIcons.animated,
      iconScale: scale,
    );
  }
}

class GeoTiffIcon extends StatelessWidget {
  const GeoTiffIcon({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const OverlayIcon(
      icon: AIcons.geo,
    );
  }
}

class SphericalImageIcon extends StatelessWidget {
  const SphericalImageIcon({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const OverlayIcon(
      icon: AIcons.threeSixty,
    );
  }
}

class FavouriteIcon extends StatelessWidget {
  const FavouriteIcon({Key? key}) : super(key: key);

  static const scale = .9;

  @override
  Widget build(BuildContext context) {
    return const OverlayIcon(
      icon: AIcons.favourite,
      iconScale: scale,
    );
  }
}

class GpsIcon extends StatelessWidget {
  const GpsIcon({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const OverlayIcon(
      icon: AIcons.location,
    );
  }
}

class RawIcon extends StatelessWidget {
  const RawIcon({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const OverlayIcon(
      icon: AIcons.raw,
    );
  }
}

class MotionPhotoIcon extends StatelessWidget {
  const MotionPhotoIcon({Key? key}) : super(key: key);

  static const scale = .8;

  @override
  Widget build(BuildContext context) {
    return const OverlayIcon(
      icon: AIcons.motionPhoto,
      iconScale: scale,
    );
  }
}

class MultiPageIcon extends StatelessWidget {
  final AvesEntry entry;

  static const scale = .8;

  const MultiPageIcon({
    Key? key,
    required this.entry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String? text;
    if (entry.isBurst) {
      text = '${entry.burstEntries?.length}';
    }
    final child = OverlayIcon(
      icon: AIcons.multiPage,
      iconScale: scale,
      text: text,
    );
    return DefaultTextStyle(
      style: TextStyle(
        color: Colors.grey.shade200,
        fontSize: context.select<GridThemeData, double>((t) => t.fontSize),
      ),
      child: child,
    );
  }
}

class RatingIcon extends StatelessWidget {
  final AvesEntry entry;

  const RatingIcon({
    Key? key,
    required this.entry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final gridTheme = context.watch<GridThemeData>();
    return DefaultTextStyle(
      style: TextStyle(
        color: Colors.grey.shade200,
        fontSize: gridTheme.fontSize,
      ),
      child: OverlayIcon(
        icon: AIcons.rating,
        text: '${entry.rating}',
      ),
    );
  }
}

class TrashIcon extends StatelessWidget {
  final int? trashDaysLeft;

  const TrashIcon({
    Key? key,
    required this.trashDaysLeft,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final child = OverlayIcon(
      icon: AIcons.bin,
      text: trashDaysLeft != null ? context.l10n.timeDays(trashDaysLeft!) : null,
    );

    return DefaultTextStyle(
      style: TextStyle(
        color: Colors.grey.shade200,
        fontSize: context.select<GridThemeData, double>((t) => t.fontSize),
      ),
      child: child,
    );
  }
}

class OverlayIcon extends StatelessWidget {
  final IconData icon;
  final String? text;
  final double iconScale;
  final EdgeInsets margin;

  const OverlayIcon({
    Key? key,
    required this.icon,
    this.iconScale = 1,
    this.text,
    // default margin for multiple icons in a `Column`
    this.margin = const EdgeInsets.only(left: 1, right: 1, bottom: 1),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = context.select<GridThemeData, double>((t) => t.iconSize);
    final iconChild = Icon(
      icon,
      size: size,
      // consistent with the color used for the text next to it
      color: DefaultTextStyle.of(context).style.color,
    );
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
      margin: margin,
      padding: text != null ? EdgeInsetsDirectional.only(end: size / 4) : null,
      decoration: BoxDecoration(
        color: const Color(0xBB000000),
        borderRadius: BorderRadius.all(Radius.circular(size)),
      ),
      child: text == null
          ? iconBox
          : Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                iconBox,
                const SizedBox(width: 2),
                Text(text!),
              ],
            ),
    );
  }
}

class IconUtils {
  static Widget? getAlbumIcon({
    required BuildContext context,
    required String albumPath,
    double? size,
  }) {
    size ??= IconTheme.of(context).size;
    Widget buildIcon(IconData icon) => Icon(icon, size: size);
    switch (androidFileUtils.getAlbumType(albumPath)) {
      case AlbumType.camera:
        return buildIcon(AIcons.cameraAlbum);
      case AlbumType.screenshots:
      case AlbumType.videoCaptures:
        return buildIcon(AIcons.screenshotAlbum);
      case AlbumType.screenRecordings:
        return buildIcon(AIcons.recordingAlbum);
      case AlbumType.download:
        return buildIcon(AIcons.downloadAlbum);
      case AlbumType.app:
        return Image(
          image: AppIconImage(
            packageName: androidFileUtils.getAlbumAppPackageName(albumPath)!,
            size: size!,
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
