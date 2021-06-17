import 'dart:ui';

import 'package:aves/image_providers/app_icon_image_provider.dart';
import 'package:aves/model/entry.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/utils/android_file_utils.dart';
import 'package:aves/utils/constants.dart';
import 'package:aves/widgets/collection/thumbnail/theme.dart';
import 'package:decorated_icon/decorated_icon.dart';
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
    final thumbnailTheme = context.watch<ThumbnailThemeData>();
    final showDuration = thumbnailTheme.showVideoDuration;
    Widget child = OverlayIcon(
      icon: entry.is360 ? AIcons.threeSixty : AIcons.videoThumb,
      size: thumbnailTheme.iconSize,
      text: showDuration ? entry.durationText : null,
      iconScale: entry.is360 && showDuration ? .9 : 1,
    );
    if (showDuration) {
      child = DefaultTextStyle(
        style: TextStyle(
          color: Colors.grey.shade200,
          fontSize: thumbnailTheme.fontSize,
        ),
        child: child,
      );
    }
    return child;
  }
}

class AnimatedImageIcon extends StatelessWidget {
  const AnimatedImageIcon({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OverlayIcon(
      icon: AIcons.animated,
      size: context.select<ThumbnailThemeData, double>((t) => t.iconSize),
      iconScale: .8,
    );
  }
}

class GeotiffIcon extends StatelessWidget {
  const GeotiffIcon({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OverlayIcon(
      icon: AIcons.geo,
      size: context.select<ThumbnailThemeData, double>((t) => t.iconSize),
    );
  }
}

class SphericalImageIcon extends StatelessWidget {
  const SphericalImageIcon({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OverlayIcon(
      icon: AIcons.threeSixty,
      size: context.select<ThumbnailThemeData, double>((t) => t.iconSize),
    );
  }
}

class GpsIcon extends StatelessWidget {
  const GpsIcon({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OverlayIcon(
      icon: AIcons.location,
      size: context.select<ThumbnailThemeData, double>((t) => t.iconSize),
    );
  }
}

class RawIcon extends StatelessWidget {
  const RawIcon({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OverlayIcon(
      icon: AIcons.raw,
      size: context.select<ThumbnailThemeData, double>((t) => t.iconSize),
    );
  }
}

class MultiPageIcon extends StatelessWidget {
  final AvesEntry entry;

  const MultiPageIcon({
    Key? key,
    required this.entry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OverlayIcon(
      icon: entry.isMotionPhoto ? AIcons.motionPhoto : AIcons.multiPage,
      size: context.select<ThumbnailThemeData, double>((t) => t.iconSize),
      iconScale: .8,
    );
  }
}

class OverlayIcon extends StatelessWidget {
  final IconData icon;
  final double size;
  final String? text;
  final double iconScale;

  const OverlayIcon({
    Key? key,
    required this.icon,
    required this.size,
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
      margin: const EdgeInsets.all(1),
      padding: text != null ? EdgeInsets.only(right: size / 4) : null,
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
    bool embossed = false,
  }) {
    size ??= IconTheme.of(context).size;
    Widget buildIcon(IconData icon) => embossed
        ? MediaQuery(
            // `DecoratedIcon` internally uses `Text`,
            // which size depends on the ambient `textScaleFactor`
            // but we already accommodate for it upstream
            data: context.read<MediaQueryData>().copyWith(textScaleFactor: 1.0),
            child: DecoratedIcon(
              icon,
              shadows: Constants.embossShadows,
              size: size,
            ),
          )
        : Icon(
            icon,
            size: size,
          );
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
