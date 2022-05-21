import 'package:aves/image_providers/app_icon_image_provider.dart';
import 'package:aves/model/covers.dart';
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
    super.key,
    required this.entry,
  });

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
          fontSize: gridTheme.fontSize,
        ),
        child: child,
      );
    }
    return child;
  }
}

class AnimatedImageIcon extends StatelessWidget {
  const AnimatedImageIcon({super.key});

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
  const GeoTiffIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return const OverlayIcon(
      icon: AIcons.geo,
    );
  }
}

class SphericalImageIcon extends StatelessWidget {
  const SphericalImageIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return const OverlayIcon(
      icon: AIcons.threeSixty,
    );
  }
}

class FavouriteIcon extends StatelessWidget {
  const FavouriteIcon({super.key});

  static const scale = .9;

  @override
  Widget build(BuildContext context) {
    return const OverlayIcon(
      icon: AIcons.favourite,
      iconScale: scale,
    );
  }
}

class TagIcon extends StatelessWidget {
  const TagIcon({super.key});

  static const scale = .9;

  @override
  Widget build(BuildContext context) {
    return const OverlayIcon(
      icon: AIcons.tag,
      iconScale: scale,
      relativeOffset: Offset(.05, .05),
    );
  }
}

class GpsIcon extends StatelessWidget {
  const GpsIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return const OverlayIcon(
      icon: AIcons.location,
    );
  }
}

class RawIcon extends StatelessWidget {
  const RawIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return const OverlayIcon(
      icon: AIcons.raw,
    );
  }
}

class MotionPhotoIcon extends StatelessWidget {
  const MotionPhotoIcon({super.key});

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
    super.key,
    required this.entry,
  });

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
        fontSize: context.select<GridThemeData, double>((t) => t.fontSize),
      ),
      child: child,
    );
  }
}

class RatingIcon extends StatelessWidget {
  final AvesEntry entry;

  const RatingIcon({
    super.key,
    required this.entry,
  });

  @override
  Widget build(BuildContext context) {
    final gridTheme = context.watch<GridThemeData>();
    return DefaultTextStyle(
      style: TextStyle(
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
    super.key,
    required this.trashDaysLeft,
  });

  @override
  Widget build(BuildContext context) {
    final child = OverlayIcon(
      icon: AIcons.bin,
      text: trashDaysLeft != null ? context.l10n.timeDays(trashDaysLeft!) : null,
    );

    return DefaultTextStyle(
      style: TextStyle(
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
  final EdgeInsetsGeometry margin;
  final Offset? relativeOffset;

  const OverlayIcon({
    super.key,
    required this.icon,
    this.iconScale = 1,
    this.text,
    // default margin for multiple icons in a `Column`
    this.margin = const EdgeInsets.only(left: 1, right: 1, bottom: 1),
    this.relativeOffset,
  });

  @override
  Widget build(BuildContext context) {
    final size = context.select<GridThemeData, double>((t) => t.iconSize);
    Widget iconChild = Icon(
      icon,
      size: size,
    );

    if (relativeOffset != null) {
      iconChild = FractionalTranslation(
        translation: relativeOffset!,
        child: iconChild,
      );
    }

    if (iconScale != 1) {
      // using a transform is better than modifying the icon size to properly center the scaled icon
      iconChild = Transform.scale(
        scale: iconScale,
        child: iconChild,
      );
    }

    iconChild = SizedBox(
      width: size,
      height: size,
      child: iconChild,
    );

    return Container(
      margin: margin,
      padding: text != null ? EdgeInsetsDirectional.only(end: size / 4) : null,
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark ? const Color(0xAA000000) : const Color(0xCCFFFFFF),
        borderRadius: BorderRadius.all(Radius.circular(size)),
      ),
      child: text == null
          ? iconChild
          : Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                iconChild,
                const SizedBox(width: 2),
                Text(
                  text!,
                  // consistent with the color used for the icon next to it
                  style: TextStyle(color: IconTheme.of(context).color),
                ),
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

    switch (covers.effectiveAlbumType(albumPath)) {
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
      case AlbumType.regular:
      default:
        return null;
    }
  }
}
