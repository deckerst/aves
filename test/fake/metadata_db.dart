import 'package:aves/model/covers.dart';
import 'package:aves/model/entry.dart';
import 'package:aves/model/favourites.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/metadata/address.dart';
import 'package:aves/model/metadata/catalog.dart';
import 'package:aves/model/db/db_metadata.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeMetadataDb extends Fake implements MetadataDb {
  @override
  Future<void> init() => SynchronousFuture(null);

  @override
  Future<void> removeIds(Set<int> contentIds, {Set<EntryDataType>? dataTypes}) => SynchronousFuture(null);

  // entries

  @override
  Future<Set<AvesEntry>> loadAllEntries() => SynchronousFuture({});

  @override
  Future<void> saveEntries(Iterable<AvesEntry> entries) => SynchronousFuture(null);

  @override
  Future<void> updateEntryId(int oldId, AvesEntry entry) => SynchronousFuture(null);

  // date taken

  @override
  Future<Map<int?, int?>> loadDates() => SynchronousFuture({});

  // catalog metadata

  @override
  Future<List<CatalogMetadata>> loadAllMetadataEntries() => SynchronousFuture([]);

  @override
  Future<void> saveMetadata(Set<CatalogMetadata> metadataEntries) => SynchronousFuture(null);

  @override
  Future<void> updateMetadataId(int oldId, CatalogMetadata? metadata) => SynchronousFuture(null);

  // address

  @override
  Future<List<AddressDetails>> loadAllAddresses() => SynchronousFuture([]);

  @override
  Future<void> saveAddresses(Set<AddressDetails> addresses) => SynchronousFuture(null);

  @override
  Future<void> updateAddressId(int oldId, AddressDetails? address) => SynchronousFuture(null);

  // favourites

  @override
  Future<Set<FavouriteRow>> loadAllFavourites() => SynchronousFuture({});

  @override
  Future<void> addFavourites(Iterable<FavouriteRow> rows) => SynchronousFuture(null);

  @override
  Future<void> updateFavouriteId(int oldId, FavouriteRow row) => SynchronousFuture(null);

  @override
  Future<void> removeFavourites(Iterable<FavouriteRow> rows) => SynchronousFuture(null);

  // covers

  @override
  Future<Set<CoverRow>> loadAllCovers() => SynchronousFuture({});

  @override
  Future<void> addCovers(Iterable<CoverRow> rows) => SynchronousFuture(null);

  @override
  Future<void> updateCoverEntryId(int oldId, CoverRow row) => SynchronousFuture(null);

  @override
  Future<void> removeCovers(Set<CollectionFilter> filters) => SynchronousFuture(null);

  // video playback

  @override
  Future<void> updateVideoPlaybackId(int oldId, int? newId) => SynchronousFuture(null);

  @override
  Future<void> removeVideoPlayback(Set<int> contentIds) => SynchronousFuture(null);
}
