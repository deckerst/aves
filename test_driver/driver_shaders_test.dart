// ignore_for_file: avoid_print
import 'dart:async';

import 'package:aves/model/source/enums.dart';
import 'package:flutter_driver/flutter_driver.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import 'common_test.dart';
import 'utils/adb_utils.dart';
import 'utils/driver_extension.dart';

late FlutterDriver driver;

void main() {
  group('[Aves app]', () {
    setUpAll(() async {
      await copyContent(shadersSourcePicturesDir, shadersTargetPicturesDir);
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
      await removeDirectory(shadersTargetPicturesDir);
      unawaited(driver.close());
    });

    test('scan media dir', () => driver.scanMediaDir(shadersTargetPicturesDirEmulated));
    agreeToTerms();
    visitAbout();
    visitSettings();
    sortCollection();
    groupCollection();
    visitMap();
    selectFirstAlbum();
    searchAlbum();
    showViewer();
    goToNextImage();
    toggleOverlay();
    zoom();
    showInfoMetadata();
    scrollOffImage();

    test('contemplation', () async {
      await Future.delayed(const Duration(seconds: 5));
    });
  }, timeout: const Timeout(Duration(seconds: 30)));
}

void agreeToTerms() {
  test('[welcome] agree to terms', () async {
    // delay to avoid flaky failures when widget binding is not ready from the start
    await Future.delayed(const Duration(seconds: 3));

    await driver.scroll(find.text('Terms of Service'), 0, -300, const Duration(milliseconds: 500));

    await driver.tap(find.byValueKey('apps-checkbox'));
    await driver.tap(find.byValueKey('terms-checkbox'));
    await Future.delayed(const Duration(seconds: 1));

    await driver.tapKeyAndWait('continue-button');

    // wait for collection loading
    await driver.waitForCondition(const NoPendingPlatformMessages());
  });
}

void visitAbout() {
  test('[collection] visit about page', () async {
    await driver.tapKeyAndWait('appbar-leading-button');
    await driver.tapKeyAndWait('drawer-about-button');

    await pressDeviceBackButton();
    await driver.waitUntilNoTransientCallbacks();
  });
}

void visitSettings() {
  test('[collection] visit settings page', () async {
    await driver.tapKeyAndWait('appbar-leading-button');
    await driver.tapKeyAndWait('drawer-settings-button');

    await pressDeviceBackButton();
    await driver.waitUntilNoTransientCallbacks();
  });
}

void sortCollection() {
  test('[collection] sort', () async {
    await driver.tapKeyAndWait('appbar-menu-button');
    await driver.tapKeyAndWait('menu-configureView');
    await driver.tapKeyAndWait('tab-sort');
    await driver.tapKeyAndWait(EntrySortFactor.date.toString());
    await driver.tapKeyAndWait('button-apply');
  });
}

void groupCollection() {
  test('[collection] group', () async {
    await driver.tapKeyAndWait('appbar-menu-button');
    await driver.tapKeyAndWait('menu-configureView');
    await driver.tapKeyAndWait('tab-group');
    await driver.tapKeyAndWait(EntryGroupFactor.album.toString());
    await driver.tapKeyAndWait('button-apply');
  });
}

void visitMap() {
  test('[collection] visit map', () async {
    await driver.tapKeyAndWait('appbar-menu-button');

    await driver.tap(find.byValueKey('menu-map'));
    // wait for heavy Google map initialization
    await Future.delayed(const Duration(seconds: 3));

    final mapView = find.byValueKey('map_view');

    print('* hide overlay');
    await driver.tap(mapView);
    await Future.delayed(const Duration(seconds: 2));

    print('* show overlay');
    await driver.tap(mapView);
    await Future.delayed(const Duration(seconds: 2));

    await pressDeviceBackButton();
    await driver.waitUntilNoTransientCallbacks();
  });
}

void selectFirstAlbum() {
  test('[collection] select first album', () async {
    await driver.tapKeyAndWait('appbar-leading-button');
    // prefix must match `AlbumListPage.routeName`
    await driver.tapKeyAndWait('/albums-tile');

    // wait for collection loading
    await driver.waitForCondition(const NoPendingPlatformMessages());

    // delay to avoid flaky descendant resolution
    await Future.delayed(const Duration(seconds: 2));
    await driver.tap(find.descendant(
      of: find.byValueKey('filter-grid'),
      matching: find.byType('MetaData'),
      firstMatchOnly: true,
    ));
    await driver.waitUntilNoTransientCallbacks();
  });
}

void searchAlbum() {
  test('[collection] search album', () async {
    await driver.tapKeyAndWait('menu-searchCollection');

    const albumPath = shadersTargetPicturesDirEmulated;
    final albumDisplayName = p.split(albumPath).last;
    await driver.tap(find.byType('TextField'));
    await driver.enterText(albumDisplayName);

    final albumChip = find.byValueKey('album-$albumPath');
    await driver.waitFor(albumChip);
    await driver.tap(albumChip);
    await driver.waitUntilNoTransientCallbacks();
  });
}

void showViewer() {
  test('[collection] show viewer', () async {
    // delay to avoid flaky descendant resolution
    await Future.delayed(const Duration(seconds: 2));
    await driver.tap(find.descendant(
      of: find.byValueKey('collection-grid'),
      matching: find.byType('MetaData'),
      firstMatchOnly: true,
    ));
    await driver.waitUntilNoTransientCallbacks();
    await Future.delayed(const Duration(seconds: 2));
  });
}

void goToNextImage() {
  test('[viewer] show next image', () async {
    final horizontalPageView = find.byValueKey('horizontal-pageview');
    await driver.scroll(horizontalPageView, -600, 0, const Duration(milliseconds: 400));
    await Future.delayed(const Duration(seconds: 2));
  });
}

void toggleOverlay() {
  test('[viewer] toggle overlay', () async {
    final imageView = find.byValueKey('image_view');

    print('* hide overlay');
    await driver.tap(imageView);
    await Future.delayed(const Duration(seconds: 1));

    print('* show overlay');
    await driver.tap(imageView);
    await Future.delayed(const Duration(seconds: 1));
  });
}

void zoom() {
  test('[viewer] zoom cycle', () async {
    final imageView = find.byValueKey('image_view');

    await driver.doubleTap(imageView);
    await Future.delayed(const Duration(seconds: 1));

    await driver.doubleTap(imageView);
    await Future.delayed(const Duration(seconds: 1));

    await driver.doubleTap(imageView);
    await Future.delayed(const Duration(seconds: 1));
  });
}

void showInfoMetadata() {
  test('[viewer] show info', () async {
    final verticalPageView = find.byValueKey('vertical-pageview');

    print('* scroll down to info');
    await driver.scroll(verticalPageView, 0, -600, const Duration(milliseconds: 400));
    await Future.delayed(const Duration(seconds: 2));

    print('* scroll down to metadata details');
    await driver.scroll(verticalPageView, 0, -800, const Duration(milliseconds: 600));
    await Future.delayed(const Duration(seconds: 1));

    print('* toggle GPS metadata');
    final gpsTile = find.descendant(
      of: find.byValueKey('tilecard-GPS'),
      matching: find.byType('ListTile'),
    );
    await driver.tap(gpsTile);
    await driver.waitUntilNoTransientCallbacks();
    await driver.tap(gpsTile);
    await driver.waitUntilNoTransientCallbacks();

    print('* scroll up to show app bar');
    await driver.scroll(verticalPageView, 0, 100, const Duration(milliseconds: 400));
    await Future.delayed(const Duration(seconds: 1));

    print('* back to image');
    await driver.tapKeyAndWait('back-button');
  });
}

void scrollOffImage() {
  test('[viewer] scroll off', () async {
    await driver.scroll(find.byValueKey('image_view'), 0, 800, const Duration(milliseconds: 600));
    await Future.delayed(const Duration(seconds: 1));
  });
}
