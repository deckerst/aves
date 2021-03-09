import 'package:aves/image_providers/app_icon_image_provider.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/utils/android_file_utils.dart';
import 'package:aves/widgets/common/identity/aves_icons.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:path/path.dart';

class AlbumFilter extends CollectionFilter {
  static const type = 'album';

  static final Map<String, Color> _appColors = {};

  final String album;
  final String uniqueName;

  const AlbumFilter(this.album, this.uniqueName);

  AlbumFilter.fromMap(Map<String, dynamic> json)
      : this(
          json['album'],
          json['uniqueName'],
        );

  @override
  Map<String, dynamic> toMap() => {
        'type': type,
        'album': album,
        'uniqueName': uniqueName,
      };

  @override
  EntryFilter get test => (entry) => entry.directory == album;

  @override
  String get universalLabel => uniqueName ?? album.split(separator).last;

  @override
  String getTooltip(BuildContext context) => album;

  @override
  Widget iconBuilder(BuildContext context, double size, {bool showGenericIcon = true, bool embossed = false}) {
    return IconUtils.getAlbumIcon(
          context: context,
          album: album,
          size: size,
          embossed: embossed,
        ) ??
        (showGenericIcon ? Icon(AIcons.album, size: size) : null);
  }

  @override
  Future<Color> color(BuildContext context) {
    // do not use async/await and rely on `SynchronousFuture`
    // to prevent rebuilding of the `FutureBuilder` listening on this future
    if (androidFileUtils.getAlbumType(album) == AlbumType.app) {
      if (_appColors.containsKey(album)) return SynchronousFuture(_appColors[album]);

      return PaletteGenerator.fromImageProvider(
        AppIconImage(
          packageName: androidFileUtils.getAlbumAppPackageName(album),
          size: 24,
        ),
      ).then((palette) {
        final color = palette.dominantColor?.color ?? super.color(context);
        _appColors[album] = color;
        return color;
      });
    } else {
      return super.color(context);
    }
  }

  @override
  String get category => type;

  // key `album-{path}` is expected by test driver
  @override
  String get key => '$type-$album';

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is AlbumFilter && other.album == album;
  }

  @override
  int get hashCode => hashValues(type, album);

  @override
  String toString() => '$runtimeType#${shortHash(this)}{album=$album}';
}
