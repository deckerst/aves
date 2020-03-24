import 'package:aves/model/image_entry.dart';

abstract class CollectionFilter {
  const CollectionFilter();

  bool filter(ImageEntry entry);
}

class AlbumFilter extends CollectionFilter {
  final String album;

  const AlbumFilter(this.album);

  @override
  bool filter(ImageEntry entry) => entry.directory == album;
}

class TagFilter extends CollectionFilter {
  final String tag;

  const TagFilter(this.tag);

  @override
  bool filter(ImageEntry entry) => entry.xmpSubjects.contains(tag);
}

class CountryFilter extends CollectionFilter {
  final String country;

  const CountryFilter(this.country);

  @override
  bool filter(ImageEntry entry) => entry.isLocated && entry.addressDetails.countryName == country;
}

class VideoFilter extends CollectionFilter {
  @override
  bool filter(ImageEntry entry) => entry.isVideo;
}

class GifFilter extends CollectionFilter {
  @override
  bool filter(ImageEntry entry) => entry.isGif;
}

class MetadataFilter extends CollectionFilter {
  final String value;

  const MetadataFilter(this.value);

  @override
  bool filter(ImageEntry entry) => entry.search(value);
}
