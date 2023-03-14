import 'package:aves/model/entry/entry.dart';
import 'package:aves/services/media/media_fetch_service.dart';
import 'package:collection/collection.dart';
import 'package:test/fake.dart';

class FakeMediaFetchService extends Fake implements MediaFetchService {
  Set<AvesEntry> entries = {};

  @override
  Future<AvesEntry?> getEntry(String uri, String? mimeType) async {
    return entries.firstWhereOrNull((v) => v.uri == uri);
  }
}
