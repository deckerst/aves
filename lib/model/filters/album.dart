import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/image_entry.dart';
import 'package:aves/utils/android_file_utils.dart';
import 'package:aves/widgets/common/icons.dart';
import 'package:aves/widgets/common/image_providers/app_icon_image_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:path/path.dart';

class AlbumFilter extends CollectionFilter {
  static const type = 'album';

  static final Map<String, Color> _appColors = {};

  final String album;

  final String uniqueName;

  const AlbumFilter(this.album, this.uniqueName);

  @override
  bool filter(ImageEntry entry) => entry.directory == album;

  @override
  String get label => uniqueName ?? album.split(separator).last;

  @override
  String get tooltip => album;

  @override
  Widget iconBuilder(context, size) {
    return IconUtils.getAlbumIcon(context: context, album: album, size: size) ?? Icon(OMIcons.photoAlbum, size: size);
  }

  @override
  Future<Color> color(BuildContext context) {
    // do not use async/await and rely on `SynchronousFuture`
    // to prevent rebuilding of the `FutureBuilder` listening on this future
    if (androidFileUtils.getAlbumType(album) == AlbumType.App) {
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
  String get typeKey => type;

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is AlbumFilter && other.album == album;
  }

  @override
  int get hashCode => hashValues('AlbumFilter', album);
}
