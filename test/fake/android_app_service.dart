import 'package:aves/services/android_app_service.dart';
import 'package:aves/utils/android_file_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:test/fake.dart';

class FakeAndroidAppService extends Fake implements AndroidAppService {
  @override
  Future<Set<Package>> getPackages() => SynchronousFuture({});
}
