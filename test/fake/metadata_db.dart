import 'package:aves/model/covers.dart';
import 'package:aves/model/entry.dart';
import 'package:aves/model/favourites.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/metadata.dart';
import 'package:aves/model/metadata_db.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeMetadataDb extends Fake implements MetadataDb {
  @override
  Future<void> init() => SynchronousFuture(null);

  @override
  Future<void> removeIds(Set<int> contentIds, {required bool metadataOnly}) => SynchronousFuture(null);

  @override
  Future<Set<AvesEntry>> loadEntries() => SynchronousFuture({});

  @override
  Future<void> saveEntries(Iterable<AvesEntry> entries) => SynchronousFuture(null);

  @override
  Future<void> updateEntryId(int oldId, AvesEntry entry) => SynchronousFuture(null);

  @override
  Future<List<DateMetadata>> loadDates() => SynchronousFuture([]);

  @override
  Future<List<CatalogMetadata>> loadMetadataEntries() => SynchronousFuture([]);

  @override
  Future<void> saveMetadata(Set<CatalogMetadata> metadataEntries) => SynchronousFuture(null);

  @override
  Future<void> updateMetadataId(int oldId, CatalogMetadata? metadata) => SynchronousFuture(null);

  @override
  Future<List<AddressDetails>> loadAddresses() => SynchronousFuture([]);

  @override
  Future<void> updateAddressId(int oldId, AddressDetails? address) => SynchronousFuture(null);

  @override
  Future<Set<FavouriteRow>> loadFavourites() => SynchronousFuture({});

  @override
  Future<void> addFavourites(Iterable<FavouriteRow> rows) => SynchronousFuture(null);

  @override
  Future<void> updateFavouriteId(int oldId, FavouriteRow row) => SynchronousFuture(null);

  @override
  Future<void> removeFavourites(Iterable<FavouriteRow> rows) => SynchronousFuture(null);

  @override
  Future<Set<CoverRow>> loadCovers() => SynchronousFuture({});

  @override
  Future<void> addCovers(Iterable<CoverRow> rows) => SynchronousFuture(null);

  @override
  Future<void> updateCoverEntryId(int oldId, CoverRow row) => SynchronousFuture(null);

  @override
  Future<void> removeCovers(Set<CollectionFilter> filters) => SynchronousFuture(null);
}
