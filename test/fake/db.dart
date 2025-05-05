import 'package:aves/model/covers.dart';
import 'package:aves/model/db/db.dart';
import 'package:aves/model/dynamic_albums.dart';
import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/favourites.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/metadata/address.dart';
import 'package:aves/model/metadata/catalog.dart';
import 'package:aves/model/metadata/trash.dart';
import 'package:aves/model/vaults/details.dart';
import 'package:flutter/foundation.dart';
import 'package:test/fake.dart';

class FakeAvesDb extends Fake implements LocalMediaDb {
  static int _lastId = 0;

  @override
  int get nextId => ++_lastId;

  @override
  Future<void> init() => SynchronousFuture(null);

  @override
  Future<void> removeIds(Set<int> ids, {Set<EntryDataType>? dataTypes}) => SynchronousFuture(null);

  // entries

  @override
  Future<Set<AvesEntry>> loadEntries({int? origin, String? directory}) => SynchronousFuture({});

  @override
  Future<void> insertEntries(Set<AvesEntry> entries) => SynchronousFuture(null);

  @override
  Future<void> updateEntry(int id, AvesEntry entry) => SynchronousFuture(null);

  @override
  Future<Set<AvesEntry>> searchLiveDuplicates(int origin, Set<AvesEntry>? entries) => SynchronousFuture({});

  // date taken

  @override
  Future<void> clearDates() => SynchronousFuture(null);

  @override
  Future<Map<int?, int?>> loadDates() => SynchronousFuture({});

  // catalog metadata

  @override
  Future<void> clearCatalogMetadata() => SynchronousFuture(null);

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

  // vaults

  @override
  Future<Set<VaultDetails>> loadAllVaults() => SynchronousFuture({});

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
  Future<void> addFavourites(Set<FavouriteRow> rows) => SynchronousFuture(null);

  @override
  Future<void> updateFavouriteId(int id, FavouriteRow row) => SynchronousFuture(null);

  @override
  Future<void> removeFavourites(Set<FavouriteRow> rows) => SynchronousFuture(null);

  // covers

  @override
  Future<Set<CoverRow>> loadAllCovers() => SynchronousFuture({});

  @override
  Future<void> addCovers(Set<CoverRow> rows) => SynchronousFuture(null);

  @override
  Future<void> updateCoverEntryId(int id, CoverRow row) => SynchronousFuture(null);

  @override
  Future<void> removeCovers(Set<CollectionFilter> filters) => SynchronousFuture(null);

  @override
  Future<Set<DynamicAlbumRow>> loadAllDynamicAlbums() => SynchronousFuture({});

  // dynamic albums

  @override
  Future<void> clearDynamicAlbums() => SynchronousFuture(null);

  @override
  Future<void> addDynamicAlbums(Set<DynamicAlbumRow> rows) => SynchronousFuture(null);

  // video playback

  @override
  Future<void> removeVideoPlayback(Set<int> ids) => SynchronousFuture(null);
}
