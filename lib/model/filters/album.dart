import 'package:aves/image_providers/app_icon_image_provider.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/utils/android_file_utils.dart';
import 'package:aves/widgets/common/identity/aves_icons.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:palette_generator/palette_generator.dart';

class AlbumFilter extends CollectionFilter {
  static const type = 'album';

  static final Map<String, Color> _appColors = {};

  final String album;
  final String? displayName;

  @override
  List<Object?> get props => [album];

  const AlbumFilter(this.album, this.displayName);

  AlbumFilter.fromMap(Map<String, dynamic> json)
      : this(
          json['album'],
          json['uniqueName'],
        );

  @override
  Map<String, dynamic> toMap() => {
        'type': type,
        'album': album,
        'uniqueName': displayName,
      };

  @override
  EntryFilter get test => (entry) => entry.directory == album;

  @override
  String get universalLabel => displayName ?? pContext.split(album).last;

  @override
  String getTooltip(BuildContext context) => album;

  @override
  Widget? iconBuilder(BuildContext context, double size, {bool showGenericIcon = true}) {
    return IconUtils.getAlbumIcon(
          context: context,
          albumPath: album,
          size: size,
        ) ??
        (showGenericIcon ? Icon(AIcons.album, size: size) : null);
  }

  @override
  Future<Color> color(BuildContext context) {
    // do not use async/await and rely on `SynchronousFuture`
    // to prevent rebuilding of the `FutureBuilder` listening on this future
    if (androidFileUtils.getAlbumType(album) == AlbumType.app) {
      if (_appColors.containsKey(album)) return SynchronousFuture(_appColors[album]!);

      final packageName = androidFileUtils.getAlbumAppPackageName(album);
      if (packageName != null) {
        return PaletteGenerator.fromImageProvider(
          AppIconImage(packageName: packageName, size: 24),
        ).then((palette) async {
          // `dominantColor` is most representative but can have low contrast with a dark background
          // `vibrantColor` is usually representative and has good contrast with a dark background
          final color = palette.vibrantColor?.color ?? (await super.color(context));
          _appColors[album] = color;
          return color;
        });
      }
    }
    return super.color(context);
  }

  @override
  String get category => type;

  // key `album-{path}` is expected by test driver
  @override
  String get key => '$type-$album';
}
