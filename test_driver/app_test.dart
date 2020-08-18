import 'dart:io';

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

    final appBarTitleFinder = find.byValueKey('appbar-title');

    test('agree to terms and reach home', () async {
      await driver.scroll(find.text('Terms of Service'), 0, -300, Duration(milliseconds: 500));

      final buttonFinder = find.byValueKey('continue-button');
      expect(await isEnabled(driver, buttonFinder), equals(false));

      await driver.tap(find.byValueKey('agree-checkbox'));
      await driver.waitUntilNoTransientCallbacks();
      expect(await isEnabled(driver, buttonFinder), equals(true));

      await driver.tap(buttonFinder);
      await driver.waitUntilNoTransientCallbacks();
      expect(await driver.getText(appBarTitleFinder), 'Aves');
    });

    test('sort and group', () async {
      await driver.tap(find.byValueKey('menu-button'));
      await driver.waitUntilNoTransientCallbacks();

      await driver.tap(find.byValueKey('menu-sort'));
      await driver.waitUntilNoTransientCallbacks();

      await driver.tap(find.byValueKey(SortFactor.date.toString()));
      await driver.tap(find.byValueKey('apply-button'));

      await driver.tap(find.byValueKey('menu-button'));
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
      sleep(Duration(seconds: 5));
    });
  }, timeout: Timeout(Duration(seconds: 10)));
}
