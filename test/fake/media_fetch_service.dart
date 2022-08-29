import 'package:aves/model/entry.dart';
import 'package:aves/services/media/media_fetch_service.dart';
import 'package:collection/collection.dart';
import 'package:test/fake.dart';

class FakeMediaFetchService extends Fake implements MediaFetchService {
  Duration latency = Duration.zero;
  Set<AvesEntry> entries = {};

  @override
  Future<AvesEntry?> getEntry(String uri, String? mimeType) async {
    await Future.delayed(latency);
    return entries.firstWhereOrNull((v) => v.uri == uri);
  }
}
