import 'package:aves/model/source/enums.dart';
import 'package:flutter_driver/flutter_driver.dart';
import 'package:path/path.dart' as path;
import 'package:pedantic/pedantic.dart';
import 'package:test/test.dart';

import 'constants.dart';
import 'utils.dart';

void main() {
  group('Aves app', () {
    FlutterDriver driver;

    setUpAll(() async {
      print('adb=${[adb, ...adbDeviceParam].join(' ')}');
      await copyContent(sourcePicturesDir, targetPicturesDir);
      await grantPermissions('deckers.thibault.aves.debug', [
        'android.permission.READ_EXTERNAL_STORAGE',
        'android.permission.WRITE_EXTERNAL_STORAGE',
        'android.permission.ACCESS_MEDIA_LOCATION',
      ]);
      driver = await FlutterDriver.connect();
    });

    tearDownAll(() async {
      await removeDirectory(targetPicturesDir);
      if (driver != null) {
        unawaited(driver.close());
      }
    });

    test('agree to terms and reach home', () async {
      await driver.scroll(find.text('Terms of Service'), 0, -300, Duration(milliseconds: 500));

      final buttonFinder = find.byValueKey('continue-button');
      expect(await isEnabled(driver, buttonFinder), equals(false));

      await driver.tap(find.byValueKey('agree-checkbox'));
      await Future.delayed(Duration(seconds: 1));
      expect(await isEnabled(driver, buttonFinder), equals(true));

      await driver.tap(buttonFinder);
      await driver.waitUntilNoTransientCallbacks();

      expect(await driver.getText(find.byValueKey('appbar-title')), 'Aves');
    });

    test('sort collection', () async {
      await driver.tap(find.byValueKey('appbar-menu-button'));
      await driver.waitUntilNoTransientCallbacks();

      await driver.tap(find.byValueKey('menu-sort'));
      await driver.waitUntilNoTransientCallbacks();

      await driver.tap(find.byValueKey(SortFactor.date.toString()));
      await driver.tap(find.byValueKey('apply-button'));
    });

    test('group collection', () async {
      await driver.tap(find.byValueKey('appbar-menu-button'));
      await driver.waitUntilNoTransientCallbacks();

      await driver.tap(find.byValueKey('menu-group'));
      await driver.waitUntilNoTransientCallbacks();

      await driver.tap(find.byValueKey(GroupFactor.album.toString()));
      await driver.tap(find.byValueKey('apply-button'));
    });

    test('search album', () async {
      await driver.tap(find.byValueKey('search-button'));
      await driver.waitUntilNoTransientCallbacks();

      final album = path.split(targetPicturesDir).last;
      await driver.tap(find.byType('TextField'));
      await driver.enterText(album);

      final albumChipFinder = find.byValueKey('album-$album');
      await driver.waitFor(albumChipFinder);
      await driver.tap(albumChipFinder);
    });

    test('show fullscreen', () async {
      await driver.tap(find.byType('DecoratedThumbnail'));
      await driver.waitUntilNoTransientCallbacks();
      await Future.delayed(Duration(seconds: 2));

      final imageViewFinder = find.byValueKey('imageview');

      print('* hide overlay');
      await driver.tap(imageViewFinder);
      await Future.delayed(Duration(seconds: 1));

      print('* show overlay');
      await driver.tap(imageViewFinder);
      await Future.delayed(Duration(seconds: 1));
    });

    test('show info', () async {
      final verticalPageViewFinder = find.byValueKey('vertical-pageview');

      print('* scroll to info');
      await driver.scroll(verticalPageViewFinder, 0, -600, Duration(milliseconds: 400));
      await Future.delayed(Duration(seconds: 1));

      // TODO TLAD find.pageBack
//      print('* back to image');
//      await driver.tap(find.pageBack());
//      await Future.delayed(Duration(seconds: 5));
    });
  }, timeout: Timeout(Duration(seconds: 10)));
}
