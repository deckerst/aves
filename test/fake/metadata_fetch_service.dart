import 'package:aves/model/entry.dart';
import 'package:aves/model/metadata/catalog.dart';
import 'package:aves/services/metadata/metadata_fetch_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeMetadataFetchService extends Fake implements MetadataFetchService {
  @override
  Future<CatalogMetadata?> getCatalogMetadata(AvesEntry entry, {bool background = false}) => SynchronousFuture(null);
}
