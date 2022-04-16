// ignore_for_file: avoid_print
import 'dart:async';
import 'dart:io';

import 'package:aves/widgets/debug/app_debug_action.dart';
import 'package:aves/widgets/settings/language/locales.dart';
import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

import 'common_test.dart';
import 'utils/adb_utils.dart';
import 'utils/driver_extension.dart';

late FlutterDriver driver;
String _languageCode = '';

final languageCodes = SupportedLocales.languagesByLanguageCode.keys;
const outputDirectory = 'screenshots/raw';

void main() {
  group('[Aves app]', () {
    setUpAll(() async {
      await Future.forEach(languageCodes, (languageCode) => Directory('$outputDirectory/$languageCode').create(recursive: true));

      await copyContent(screenshotsSourceDir, screenshotsTargetDirAdb);
      await Future.forEach<String>(
          [
            'deckers.thibault.aves.debug',
            'deckers.thibault.aves.profile',
          ],
          (package) => grantPermissions(package, [
                'android.permission.READ_EXTERNAL_STORAGE',
                'android.permission.ACCESS_MEDIA_LOCATION',
              ]));
      driver = await FlutterDriver.connect();
    });

    tearDownAll(() async {
      await removeDirectory(screenshotsTargetDirAdb);
      unawaited(driver.close());
    });

    test('scan media dir', () async {
      await driver.scanMediaDir(screenshotsTargetDirAndroid);
      // recent heavy images may delay cataloguing because of thumbnail loading precedence
      // so we wait enough to avoid cataloguing progress subtitle in app bar when taking screenshots
      await Future.delayed(const Duration(seconds: 20));
    });

    languageCodes.forEach((languageCode) {
      setLanguage(languageCode);
      configureCollectionVisibility(AppDebugAction.prepScreenshotThumbnails);
      collection();
      configureCollectionVisibility(AppDebugAction.prepScreenshotStats);
      viewer();
      info();
      stats();
      countries();
    });
  }, timeout: const Timeout(Duration(seconds: 30)));
}

Future<void> _search(String query, String chipKey) async {
  await driver.tapKeyAndWait('menu-searchCollection');
  await driver.tap(find.byType('TextField'));
  await driver.enterText(query);
  final chip = find.byValueKey(chipKey);
  await driver.waitFor(chip);
  await driver.tap(chip);
  await driver.waitUntilNoTransientCallbacks();
}

Future<void> _takeScreenshot(FlutterDriver driver, String name) async {
  final pixels = await driver.screenshot();
  final file = File('$outputDirectory/$_languageCode/$name.png');
  await file.writeAsBytes(pixels);
  print('* saved screenshot to ${file.path}');
}

void setLanguage(String languageCode) {
  test('set language', () async {
    await driver.tapKeyAndWait('appbar-leading-button');
    await driver.tapKeyAndWait('drawer-settings-button');
    await driver.tapKeyAndWait('section-language');
    await driver.tapKeyAndWait('tile-language');
    await driver.tapKeyAndWait(languageCode);
    _languageCode = languageCode;

    await pressDeviceBackButton();
    await driver.waitUntilNoTransientCallbacks();
  });
}

void configureCollectionVisibility(AppDebugAction action) {
  test('configure collection visibility', () async {
    await driver.tapKeyAndWait('appbar-leading-button');
    final verticalPageView = find.byValueKey('drawer-scrollview');
    await driver.scroll(verticalPageView, 0, -600, const Duration(milliseconds: 400));
    await driver.tapKeyAndWait('drawer-debug');

    await driver.tapKeyAndWait('appbar-menu-button');
    await driver.tapKeyAndWait('menu-${action.name}');

    await pressDeviceBackButton();
    await driver.waitUntilNoTransientCallbacks();
  });
}

void collection() {
  test('1. Collection', () async {
    await driver.tapKeyAndWait('appbar-leading-button');
    await driver.tapKeyAndWait('drawer-type-favourite');
    await _search('birds', 'tag-birds');
    await _search('South Korea', 'tag-South Korea');

    await _takeScreenshot(driver, '1');
  });
}

void viewer() {
  test('2. Viewer', () async {
    await driver.tapKeyAndWait('appbar-leading-button');
    await driver.tapKeyAndWait('drawer-type-null');

    await _search('viewer', 'album-$screenshotsTargetDirAndroid/viewer');

    // delay to avoid flaky descendant resolution
    await Future.delayed(const Duration(seconds: 2));
    await driver.tap(find.descendant(
      of: find.byValueKey('collection-grid'),
      matching: find.byType('MetaData'),
      firstMatchOnly: true,
    ));
    await driver.waitUntilNoTransientCallbacks();
    await Future.delayed(const Duration(seconds: 2));

    final imageView = find.byValueKey('image_view');
    await driver.doubleTap(imageView);
    await Future.delayed(const Duration(seconds: 1));

    await _takeScreenshot(driver, '2');
  });
}

void info() {
  test('3. Info (basic), 4. Info (metadata)', () async {
    final verticalPageView = find.byValueKey('vertical-pageview');

    await driver.scroll(verticalPageView, 0, -600, const Duration(milliseconds: 400));
    // tiles may take time to load
    await Future.delayed(const Duration(seconds: 5));

    await _takeScreenshot(driver, '3');

    await driver.scroll(verticalPageView, 0, -680, const Duration(milliseconds: 600));
    await Future.delayed(const Duration(seconds: 1));

    final gpsTile = find.descendant(
      of: find.byValueKey('tilecard-GPS'),
      matching: find.byType('ListTile'),
    );
    await driver.tap(gpsTile);
    await driver.waitUntilNoTransientCallbacks();

    await _takeScreenshot(driver, '4');

    await pressDeviceBackButton();
    await driver.waitUntilNoTransientCallbacks();

    await pressDeviceBackButton();
    await driver.waitUntilNoTransientCallbacks();
  });
}

void stats() {
  test('5. Stats', () async {
    await driver.tapKeyAndWait('appbar-leading-button');
    await driver.tapKeyAndWait('drawer-type-null');

    await driver.tapKeyAndWait('appbar-menu-button');
    await driver.tapKeyAndWait('menu-stats');

    await _takeScreenshot(driver, '5');

    await pressDeviceBackButton();
    await driver.waitUntilNoTransientCallbacks();
  });
}

void countries() {
  test('6. Countries', () async {
    await driver.tapKeyAndWait('appbar-leading-button');
    await driver.tapKeyAndWait('drawer-page-/countries');

    await _takeScreenshot(driver, '6');
  });
}
