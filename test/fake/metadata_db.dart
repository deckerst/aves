import 'package:aves/model/covers.dart';
import 'package:aves/model/entry.dart';
import 'package:aves/model/favourites.dart';
import 'package:aves/model/metadata.dart';
import 'package:aves/model/metadata_db.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeMetadataDb extends Fake implements MetadataDb {
  @override
  Future<void> init() => null;

  @override
  Future<void> removeIds(Set<int> contentIds, {@required bool metadataOnly}) => null;

  @override
  Future<Set<AvesEntry>> loadEntries() => SynchronousFuture({});

  @override
  Future<void> saveEntries(Iterable<AvesEntry> entries) => null;

  @override
  Future<void> updateEntryId(int oldId, AvesEntry entry) => null;

  @override
  Future<List<DateMetadata>> loadDates() => SynchronousFuture([]);

  @override
  Future<List<CatalogMetadata>> loadMetadataEntries() => SynchronousFuture([]);

  @override
  Future<void> saveMetadata(Iterable<CatalogMetadata> metadataEntries) => null;

  @override
  Future<void> updateMetadataId(int oldId, CatalogMetadata metadata) => null;

  @override
  Future<List<AddressDetails>> loadAddresses() => SynchronousFuture([]);

  @override
  Future<void> updateAddressId(int oldId, AddressDetails address) => null;

  @override
  Future<Set<FavouriteRow>> loadFavourites() => SynchronousFuture({});

  @override
  Future<void> addFavourites(Iterable<FavouriteRow> rows) => null;

  @override
  Future<void> updateFavouriteId(int oldId, FavouriteRow row) => null;

  @override
  Future<void> removeFavourites(Iterable<FavouriteRow> rows) => null;

  @override
  Future<Set<CoverRow>> loadCovers() => SynchronousFuture({});

  @override
  Future<void> addCovers(Iterable<CoverRow> rows) => null;

  @override
  Future<void> updateCoverEntryId(int oldId, CoverRow row) => null;

  @override
  Future<void> removeCovers(Iterable<CoverRow> rows) => null;
}
