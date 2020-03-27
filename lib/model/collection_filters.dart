import 'package:aves/model/image_entry.dart';
import 'package:aves/utils/android_file_utils.dart';
import 'package:aves/utils/color_utils.dart';
import 'package:aves/widgets/common/icons.dart';
import 'package:aves/widgets/common/image_providers/app_icon_image_provider.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:path/path.dart';

abstract class CollectionFilter implements Comparable<CollectionFilter> {
  static const List<String> collectionFilterOrder = [
    VideoFilter.type,
    GifFilter.type,
    AlbumFilter.type,
    CountryFilter.type,
    TagFilter.type,
    QueryFilter.type,
  ];

  const CollectionFilter();

  bool filter(ImageEntry entry);

  String get label;

  Widget iconBuilder(BuildContext context, double size);

  Future<Color> color(BuildContext context) => SynchronousFuture(stringToColor(label));

  String get typeKey;

  int get displayPriority => collectionFilterOrder.indexOf(typeKey);

  @override
  int compareTo(CollectionFilter other) {
    final c = displayPriority.compareTo(other.displayPriority);
    return c != 0 ? c : compareAsciiUpperCase(label, other.label);
  }
}

class AlbumFilter extends CollectionFilter {
  static const type = 'album';

  final String album;

  const AlbumFilter(this.album);

  @override
  bool filter(ImageEntry entry) => entry.directory == album;

  @override
  String get label => album.split(separator).last;

  @override
  Widget iconBuilder(context, size) {
    return IconUtils.getAlbumIcon(context: context, album: album, size: size) ?? Icon(OMIcons.photoAlbum, size: size);
  }

  Future<Color> color(BuildContext context) async {
    Color color;
    if (androidFileUtils.getAlbumType(album) == AlbumType.App) {
      final palette = await PaletteGenerator.fromImageProvider(
        AppIconImage(
          packageName: androidFileUtils.getAlbumAppPackageName(album),
          size: 24,
        ),
      );
      color = palette.dominantColor?.color;
    }
    return color ?? super.color(context);
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

class TagFilter extends CollectionFilter {
  static const type = 'tag';

  final String tag;

  const TagFilter(this.tag);

  @override
  bool filter(ImageEntry entry) => entry.xmpSubjects.contains(tag);

  @override
  String get label => tag;

  @override
  Widget iconBuilder(context, size) => Icon(OMIcons.localOffer, size: size);

  @override
  String get typeKey => type;

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is TagFilter && other.tag == tag;
  }

  @override
  int get hashCode => hashValues('TagFilter', tag);
}

class CountryFilter extends CollectionFilter {
  static const type = 'country';

  final String country;

  const CountryFilter(this.country);

  @override
  bool filter(ImageEntry entry) => entry.isLocated && entry.addressDetails.countryName == country;

  @override
  String get label => country;

  @override
  Widget iconBuilder(context, size) => Icon(OMIcons.place, size: size);

  @override
  String get typeKey => type;

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is CountryFilter && other.country == country;
  }

  @override
  int get hashCode => hashValues('CountryFilter', country);
}

class VideoFilter extends CollectionFilter {
  static const type = 'video';

  @override
  bool filter(ImageEntry entry) => entry.isVideo;

  @override
  String get label => 'Video';

  @override
  Widget iconBuilder(context, size) => Icon(OMIcons.movie, size: size);

  @override
  String get typeKey => type;

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is VideoFilter;
  }

  @override
  int get hashCode => 'VideoFilter'.hashCode;
}

class GifFilter extends CollectionFilter {
  static const type = 'gif';

  @override
  bool filter(ImageEntry entry) => entry.isGif;

  @override
  String get label => 'GIF';

  @override
  Widget iconBuilder(context, size) => Icon(OMIcons.gif, size: size);

  @override
  String get typeKey => type;

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is GifFilter;
  }

  @override
  int get hashCode => 'GifFilter'.hashCode;
}

class QueryFilter extends CollectionFilter {
  static const type = 'query';

  final String query;

  const QueryFilter(this.query);

  @override
  bool filter(ImageEntry entry) => entry.search(query);

  @override
  String get label => '${query}';

  @override
  Widget iconBuilder(context, size) => Icon(OMIcons.formatQuote, size: size);

  @override
  String get typeKey => type;

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is QueryFilter && other.query == query;
  }

  @override
  int get hashCode => hashValues('MetadataFilter', query);
}
