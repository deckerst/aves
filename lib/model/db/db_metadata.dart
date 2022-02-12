import 'package:aves/model/covers.dart';
import 'package:aves/model/entry.dart';
import 'package:aves/model/favourites.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/metadata/address.dart';
import 'package:aves/model/metadata/catalog.dart';
import 'package:aves/model/video_playback.dart';

abstract class MetadataDb {
  Future<void> init();

  Future<int> dbFileSize();

  Future<void> reset();

  Future<void> removeIds(Set<int> contentIds, {Set<EntryDataType>? dataTypes});

  // entries

  Future<void> clearEntries();

  Future<Set<AvesEntry>> loadAllEntries();

  Future<void> saveEntries(Iterable<AvesEntry> entries);

  Future<void> updateEntryId(int oldId, AvesEntry entry);

  Future<Set<AvesEntry>> searchEntries(String query, {int? limit});

  Future<Set<AvesEntry>> loadEntries(List<int> ids);

  // date taken

  Future<void> clearDates();

  Future<Map<int?, int?>> loadDates();

  // catalog metadata

  Future<void> clearMetadataEntries();

  Future<List<CatalogMetadata>> loadAllMetadataEntries();

  Future<void> saveMetadata(Set<CatalogMetadata> metadataEntries);

  Future<void> updateMetadataId(int oldId, CatalogMetadata? metadata);

  // address

  Future<void> clearAddresses();

  Future<List<AddressDetails>> loadAllAddresses();

  Future<void> saveAddresses(Set<AddressDetails> addresses);

  Future<void> updateAddressId(int oldId, AddressDetails? address);

  // favourites

  Future<void> clearFavourites();

  Future<Set<FavouriteRow>> loadAllFavourites();

  Future<void> addFavourites(Iterable<FavouriteRow> rows);

  Future<void> updateFavouriteId(int oldId, FavouriteRow row);

  Future<void> removeFavourites(Iterable<FavouriteRow> rows);

  // covers

  Future<void> clearCovers();

  Future<Set<CoverRow>> loadAllCovers();

  Future<void> addCovers(Iterable<CoverRow> rows);

  Future<void> updateCoverEntryId(int oldId, CoverRow row);

  Future<void> removeCovers(Set<CollectionFilter> filters);

  // video playback

  Future<void> clearVideoPlayback();

  Future<Set<VideoPlaybackRow>> loadAllVideoPlayback();

  Future<VideoPlaybackRow?> loadVideoPlayback(int? contentId);

  Future<void> addVideoPlayback(Set<VideoPlaybackRow> rows);

  Future<void> updateVideoPlaybackId(int oldId, int? newId);

  Future<void> removeVideoPlayback(Set<int> contentIds);
}
