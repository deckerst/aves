import 'package:aves/model/app_inventory.dart';
import 'package:aves/services/app_service.dart';
import 'package:aves/services/common/services.dart';
import 'package:test/fake.dart';
import 'package:test/test.dart';

import '../common.dart';

class _FakeAppService extends Fake implements AppService {
  @override
  Future<Set<Package>> getPackages() => Future.value({
    Package(
      packageName: 'it.pagopa.io.app',
      currentLabel: 'IO',
      englishLabel: 'IO',
      categoryLauncher: true,
      isSystem: false,
    )..addOwnedDirs({'IO/Images'}),
  });
}

void main() {
  setUpAll(() async {
    await setUpAllServices();
    getIt.unregister<AppService>();
    getIt.registerLazySingleton<AppService>(_FakeAppService.new);
    await appInventory.initAppNames();
  });

  tearDownAll(() async {
    await tearDownAllServices();
  });

  test('detect potential dir', () {
    expect(appInventory.isPotentialAppDir('/storage/io'), true);
    expect(appInventory.isPotentialAppDir('/storage/IO'), true);
    expect(appInventory.isPotentialAppDir('/storage/io/Images'), true);
    expect(appInventory.isPotentialAppDir('/storage/IO/Images'), true);
    expect(appInventory.isPotentialAppDir('/storage/IO/Videos'), false);
    expect(appInventory.isPotentialAppDir('/storage/MINCIO'), false);
  });
}
