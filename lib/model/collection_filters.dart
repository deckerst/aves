import 'package:aves/model/image_entry.dart';
import 'package:aves/widgets/common/icons.dart';
import 'package:flutter/widgets.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:path/path.dart';

abstract class CollectionFilter {
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

  Widget iconBuilder(BuildContext context);

  String get typeKey;

  int get displayPriority => collectionFilterOrder.indexOf(typeKey);
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
  Widget iconBuilder(context) => IconUtils.getAlbumIcon(context, album) ?? Icon(OMIcons.photoAlbum);

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
  Widget iconBuilder(context) => Icon(OMIcons.localOffer);

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
  Widget iconBuilder(context) => Icon(OMIcons.place);

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
  Widget iconBuilder(context) => Icon(OMIcons.movie);

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
  Widget iconBuilder(context) => Icon(OMIcons.gif);

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
  Widget iconBuilder(context) => Icon(OMIcons.formatQuote);

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
