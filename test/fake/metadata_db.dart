import 'package:aves/model/covers.dart';
import 'package:aves/model/db/db_metadata.dart';
import 'package:aves/model/entry.dart';
import 'package:aves/model/favourites.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/metadata/address.dart';
import 'package:aves/model/metadata/catalog.dart';
import 'package:aves/model/metadata/trash.dart';
import 'package:flutter/foundation.dart';
import 'package:test/fake.dart';

class FakeMetadataDb extends Fake implements MetadataDb {
  static int _lastId = 0;

  @override
  int get nextId => ++_lastId;

  @override
  int get timestampSecs => DateTime.now().millisecondsSinceEpoch ~/ 1000;

  @override
  Future<void> init() => SynchronousFuture(null);

  @override
  Future<void> removeIds(Iterable<int> ids, {Set<EntryDataType>? dataTypes}) => SynchronousFuture(null);

  // entries

  @override
  Future<Set<AvesEntry>> loadEntries({String? directory}) => SynchronousFuture({});

  @override
  Future<void> saveEntries(Iterable<AvesEntry> entries) => SynchronousFuture(null);

  @override
  Future<void> updateEntry(int id, AvesEntry entry) => SynchronousFuture(null);

  // date taken

  @override
  Future<Map<int?, int?>> loadDates() => SynchronousFuture({});

  // catalog metadata

  @override
  Future<Set<CatalogMetadata>> loadCatalogMetadata() => SynchronousFuture({});

  @override
  Future<void> saveCatalogMetadata(Set<CatalogMetadata> metadataEntries) => SynchronousFuture(null);

  @override
  Future<void> updateCatalogMetadata(int id, CatalogMetadata? metadata) => SynchronousFuture(null);

  // address

  @override
  Future<Set<AddressDetails>> loadAddresses() => SynchronousFuture({});

  @override
  Future<void> saveAddresses(Set<AddressDetails> addresses) => SynchronousFuture(null);

  @override
  Future<void> updateAddress(int id, AddressDetails? address) => SynchronousFuture(null);

  // trash

  @override
  Future<void> clearTrashDetails() => SynchronousFuture(null);

  @override
  Future<Set<TrashDetails>> loadAllTrashDetails() => SynchronousFuture({});

  @override
  Future<void> updateTrash(int id, TrashDetails? details) => SynchronousFuture(null);

  // favourites

  @override
  Future<Set<FavouriteRow>> loadAllFavourites() => SynchronousFuture({});

  @override
  Future<void> addFavourites(Iterable<FavouriteRow> rows) => SynchronousFuture(null);

  @override
  Future<void> updateFavouriteId(int id, FavouriteRow row) => SynchronousFuture(null);

  @override
  Future<void> removeFavourites(Iterable<FavouriteRow> rows) => SynchronousFuture(null);

  // covers

  @override
  Future<Set<CoverRow>> loadAllCovers() => SynchronousFuture({});

  @override
  Future<void> addCovers(Iterable<CoverRow> rows) => SynchronousFuture(null);

  @override
  Future<void> updateCoverEntryId(int id, CoverRow row) => SynchronousFuture(null);

  @override
  Future<void> removeCovers(Set<CollectionFilter> filters) => SynchronousFuture(null);

  // video playback

  @override
  Future<void> removeVideoPlayback(Iterable<int> ids) => SynchronousFuture(null);
}
