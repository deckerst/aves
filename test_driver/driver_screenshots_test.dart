// ignore_for_file: avoid_print
import 'dart:async';
import 'dart:io';

import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

import 'utils/adb_utils.dart';
import 'utils/driver_extension.dart';

late FlutterDriver driver;

void main() {
  group('[Aves app]', () {
    setUpAll(() async {
      await Directory(directory).create();

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
      unawaited(driver.close());
    });

    [
      'de',
      'en',
      // TODO TLAD other locales
    ].forEach((v) async {
      setLanguage(v);
      collection();
      viewer();
      info();
      stats();
      countries();
    });
  }, timeout: const Timeout(Duration(seconds: 30)));
}

const directory = 'screenshots';
String screenshotLocale = '';

Future<void> takeScreenshot(FlutterDriver driver, String name) async {
  final pixels = await driver.screenshot();
  final file = File('$directory/$screenshotLocale-$name.png');
  await file.writeAsBytes(pixels);
  print('* saved screenshot to ${file.path}');
}

void setLanguage(String locale) {
  test('set language', () async {
    await driver.tapKeyAndWait('appbar-leading-button');
    await driver.tapKeyAndWait('drawer-settings-button');
    await driver.tapKeyAndWait('section-language');
    await driver.tapKeyAndWait('tile-language');
    await driver.tapKeyAndWait(locale);
    screenshotLocale = locale;

    await pressDeviceBackButton();
    await driver.waitUntilNoTransientCallbacks();
  });
}

void collection() {
  test('1. Collection', () async {
    // TODO TLAD hidden filters: reverse of TagFilter('aves-screenshot-collection')

    await driver.tapKeyAndWait('appbar-leading-button');
    await driver.tapKeyAndWait('drawer-type-null');

    await takeScreenshot(driver, '1-collection');
  });
}

void viewer() {
  test('2. Viewer', () async {
    const query = 'Singapore 087 Zoo - Douc langur';

    await driver.tapKeyAndWait('menu-searchCollection');
    await driver.tap(find.byType('TextField'));
    await driver.enterText(query);
    final queryChip = find.byValueKey('query-$query');
    await driver.waitFor(queryChip);
    await driver.tap(queryChip);
    await driver.waitUntilNoTransientCallbacks();

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

    await takeScreenshot(driver, '2-viewer');
  });
}

void info() {
  test('3. Info (basic), 4. Info (metadata)', () async {
    final verticalPageView = find.byValueKey('vertical-pageview');

    await driver.scroll(verticalPageView, 0, -600, const Duration(milliseconds: 400));
    await Future.delayed(const Duration(seconds: 2));

    await takeScreenshot(driver, '3-info-basic');

    await driver.scroll(verticalPageView, 0, -800, const Duration(milliseconds: 600));
    await Future.delayed(const Duration(seconds: 1));

    final gpsTile = find.descendant(
      of: find.byValueKey('tilecard-GPS'),
      matching: find.byType('ListTile'),
    );
    await driver.tap(gpsTile);
    await driver.waitUntilNoTransientCallbacks();

    await takeScreenshot(driver, '3-info-metadata');

    await pressDeviceBackButton();
    await driver.waitUntilNoTransientCallbacks();

    await pressDeviceBackButton();
    await driver.waitUntilNoTransientCallbacks();
  });
}

void stats() {
  test('5. Stats', () async {
    // TODO TLAD hidden filters: PathFilter('/storage/emulated/0/Pictures/Dev')

    await driver.tapKeyAndWait('appbar-leading-button');
    await driver.tapKeyAndWait('drawer-type-null');

    await driver.tapKeyAndWait('appbar-menu-button');
    await driver.tapKeyAndWait('menu-stats');

    await takeScreenshot(driver, '5-stats');

    await pressDeviceBackButton();
    await driver.waitUntilNoTransientCallbacks();
  });
}

void countries() {
  test('6. Countries', () async {
    // TODO TLAD hidden filters: reverse of TagFilter('aves-screenshot-collection')
    // TODO TLAD OR 1) set country covers, 2) hidden filters: PathFilter('/storage/emulated/0/Pictures/Dev')

    await driver.tapKeyAndWait('appbar-leading-button');
    await driver.tapKeyAndWait('drawer-page-/countries');

    await takeScreenshot(driver, '6-countries');

    await pressDeviceBackButton();
    await driver.waitUntilNoTransientCallbacks();
  });
}
