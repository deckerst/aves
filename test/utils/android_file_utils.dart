import 'package:aves/services/services.dart';
import 'package:aves/services/storage_service.dart';
import 'package:aves/utils/android_file_utils.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import '../fake/storage_service.dart';

void main() {
  setUp(() async {
    // specify Posix style path context for consistent behaviour when running tests on Windows
    getIt.registerLazySingleton<p.Context>(() => p.Context(style: p.Style.posix));

    getIt.registerLazySingleton<StorageService>(() => FakeStorageService());

    await androidFileUtils.init();
  });

  tearDown(() async {
    await getIt.reset();
  });

  test('camera album identification', () {
    expect(androidFileUtils.isCameraPath('${FakeStorageService.primaryPath}DCIM/Camera'), true);
    expect(androidFileUtils.isCameraPath('${FakeStorageService.primaryPath}DCIM/YoloCamera'), false);
  });
}
