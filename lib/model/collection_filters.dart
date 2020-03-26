import 'package:aves/model/image_entry.dart';
import 'package:flutter/widgets.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:path/path.dart';

abstract class CollectionFilter {
  const CollectionFilter();

  bool filter(ImageEntry entry);

  String get label;

  IconData get icon => null;
}

class AlbumFilter extends CollectionFilter {
  final String album;

  const AlbumFilter(this.album);

  @override
  bool filter(ImageEntry entry) => entry.directory == album;

  @override
  String get label => album.split(separator).last;

  @override
  IconData get icon => OMIcons.photoAlbum;

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is AlbumFilter && other.album == album;
  }

  @override
  int get hashCode => hashValues('AlbumFilter', album);
}

class TagFilter extends CollectionFilter {
  final String tag;

  const TagFilter(this.tag);

  @override
  bool filter(ImageEntry entry) => entry.xmpSubjects.contains(tag);

  @override
  String get label => tag;

  @override
  IconData get icon => OMIcons.localOffer;

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is TagFilter && other.tag == tag;
  }

  @override
  int get hashCode => hashValues('TagFilter', tag);
}

class CountryFilter extends CollectionFilter {
  final String country;

  const CountryFilter(this.country);

  @override
  bool filter(ImageEntry entry) => entry.isLocated && entry.addressDetails.countryName == country;

  @override
  String get label => country;

  @override
  IconData get icon => OMIcons.place;

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is CountryFilter && other.country == country;
  }

  @override
  int get hashCode => hashValues('CountryFilter', country);
}

class VideoFilter extends CollectionFilter {
  @override
  bool filter(ImageEntry entry) => entry.isVideo;

  @override
  String get label => 'Video';

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is VideoFilter;
  }

  @override
  int get hashCode => 'VideoFilter'.hashCode;
}

class GifFilter extends CollectionFilter {
  @override
  bool filter(ImageEntry entry) => entry.isGif;

  @override
  String get label => 'GIF';

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is GifFilter;
  }

  @override
  int get hashCode => 'GifFilter'.hashCode;
}

class MetadataFilter extends CollectionFilter {
  final String query;

  const MetadataFilter(this.query);

  @override
  bool filter(ImageEntry entry) => entry.search(query);

  @override
  String get label => '"${query}"';

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is MetadataFilter && other.query == query;
  }

  @override
  int get hashCode => hashValues('MetadataFilter', query);
}
