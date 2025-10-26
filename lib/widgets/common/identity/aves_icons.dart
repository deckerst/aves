import 'package:aves/image_providers/app_icon_image_provider.dart';
import 'package:aves/model/covers.dart';
import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/entry/extensions/multipage.dart';
import 'package:aves/model/entry/extensions/props.dart';
import 'package:aves/model/vaults/vaults.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/extensions/theme.dart';
import 'package:aves/widgets/common/grid/theme.dart';
import 'package:aves_model/aves_model.dart';
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
      icon: entry.is360 ? AIcons.sphericalVideo : AIcons.videoPlay,
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

class HdrIcon extends StatelessWidget {
  const HdrIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return const OverlayIcon(
      icon: AIcons.hdr,
    );
  }
}

class PanoramaIcon extends StatelessWidget {
  const PanoramaIcon({super.key});

  static const scale = .85;

  @override
  Widget build(BuildContext context) {
    return const OverlayIcon(
      icon: AIcons.panorama,
      iconScale: scale,
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
  final IconData icon;

  const TagIcon._private({required this.icon});

  factory TagIcon.tagged() => const TagIcon._private(icon: AIcons.tag);

  factory TagIcon.untagged() => TagIcon._private(icon: AIcons.tagUntagged);

  static const scale = .9;

  @override
  Widget build(BuildContext context) {
    return OverlayIcon(
      icon: icon,
      iconScale: scale,
      relativeOffset: const Offset(.05, .05),
    );
  }
}

class LocationIcon extends StatelessWidget {
  final IconData icon;

  const LocationIcon._private({required this.icon});

  factory LocationIcon.located() => const LocationIcon._private(icon: AIcons.location);

  factory LocationIcon.unlocated() => const LocationIcon._private(icon: AIcons.locationUnlocated);

  @override
  Widget build(BuildContext context) {
    return OverlayIcon(
      icon: icon,
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
    if (entry.isStack) {
      text = '${entry.stackedEntries?.length}';
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
    return DefaultTextStyle(
      style: TextStyle(
        fontSize: context.select<GridThemeData, double>((t) => t.fontSize),
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

  static const defaultMargin = EdgeInsets.only(left: 1, right: 1, bottom: 1);

  const OverlayIcon({
    super.key,
    required this.icon,
    this.iconScale = 1,
    this.text,
    // default margin for multiple icons in a `Column`
    this.margin = defaultMargin,
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
        color: Theme.of(context).isDark ? const Color(0xAA000000) : const Color(0xCCFFFFFF),
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
                Flexible(
                  child: Text(
                    text!,
                    // consistent with the color used for the icon next to it
                    style: TextStyle(color: IconTheme.of(context).color),
                    softWrap: false,
                    overflow: TextOverflow.fade,
                    maxLines: 1,
                  ),
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
      case AlbumType.vault:
        return buildIcon(vaults.isLocked(albumPath) ? AIcons.locked : AIcons.unlocked);
      case AlbumType.regular:
        return null;
    }
  }
}
