import 'package:aves/model/source/enums.dart';
import 'package:flutter_driver/flutter_driver.dart';
import 'package:path/path.dart' as path;
import 'package:pedantic/pedantic.dart';
import 'package:test/test.dart';

import 'constants.dart';
import 'utils/adb_utils.dart';
import 'utils/driver_extension.dart';

FlutterDriver driver;

void main() {
  group('[Aves app]', () {
    print('adb=${[adb, ...adbDeviceParam].join(' ')}');

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
      unawaited(driver?.close());
    });

    agreeToTerms();
    visitAbout();
    visitSettings();
    sortCollection();
    groupCollection();
    selectFirstAlbum();
    searchAlbum();
    showViewer();
    toggleOverlay();
    zoom();
    showInfoMetadata();
    scrollOffImage();

    test('contemplation', () async {
      await Future.delayed(Duration(seconds: 5));
    });
  }, timeout: Timeout(Duration(seconds: 30)));
}

void agreeToTerms() {
  test('[welcome] agree to terms', () async {
    await driver.scroll(find.text('Terms of Service'), 0, -300, Duration(milliseconds: 500));

    await driver.tap(find.byValueKey('agree-checkbox'));
    await Future.delayed(Duration(seconds: 1));

    await driver.tap(find.byValueKey('continue-button'));
    await driver.waitUntilNoTransientCallbacks();

    expect(await driver.getText(find.byValueKey('appbar-title')), 'Collection');
  });
}

void visitAbout() {
  test('[collection] visit about page', () async {
    await driver.tap(find.byValueKey('appbar-leading-button'));
    await driver.waitUntilNoTransientCallbacks();

    await driver.tap(find.byValueKey('About-tile'));
    await driver.waitUntilNoTransientCallbacks();

    await pressDeviceBackButton();
  });
}

void visitSettings() {
  test('[collection] visit about page', () async {
    await driver.tap(find.byValueKey('appbar-leading-button'));
    await driver.waitUntilNoTransientCallbacks();

    await driver.tap(find.byValueKey('Settings-tile'));
    await driver.waitUntilNoTransientCallbacks();

    await pressDeviceBackButton();
  });
}

void sortCollection() {
  test('[collection] sort', () async {
    await driver.tap(find.byValueKey('appbar-menu-button'));
    await driver.waitUntilNoTransientCallbacks();

    await driver.tap(find.byValueKey('menu-sort'));
    await driver.waitUntilNoTransientCallbacks();

    await driver.tap(find.byValueKey(EntrySortFactor.date.toString()));
  });
}

void groupCollection() {
  test('[collection] group', () async {
    await driver.tap(find.byValueKey('appbar-menu-button'));
    await driver.waitUntilNoTransientCallbacks();

    await driver.tap(find.byValueKey('menu-group'));
    await driver.waitUntilNoTransientCallbacks();

    await driver.tap(find.byValueKey(EntryGroupFactor.album.toString()));
  });
}

void selectFirstAlbum() {
  test('[collection] select first album', () async {
    await driver.tap(find.byValueKey('appbar-leading-button'));
    await driver.waitUntilNoTransientCallbacks();

    await driver.tap(find.byValueKey('Albums-tile'));
    await driver.waitUntilNoTransientCallbacks();

    // wait for collection loading
    await driver.waitForCondition(NoPendingPlatformMessages());

    await driver.tap(find.descendant(
      of: find.byValueKey('filter-grid-page'),
      matching: find.byType('DecoratedFilterChip'),
      firstMatchOnly: true,
    ));
    await driver.waitUntilNoTransientCallbacks();
  });
}

void searchAlbum() {
  test('[collection] search album', () async {
    await driver.tap(find.byValueKey('search-button'));
    await driver.waitUntilNoTransientCallbacks();

    final album = path.split(targetPicturesDir).last;
    await driver.tap(find.byType('TextField'));
    await driver.enterText(album);

    final albumChip = find.byValueKey('album-$album');
    await driver.waitFor(albumChip);
    await driver.tap(albumChip);
  });
}

void showViewer() {
  test('[collection] show viewer', () async {
    await driver.tap(find.byType('DecoratedThumbnail'));
    await driver.waitUntilNoTransientCallbacks();
    await Future.delayed(Duration(seconds: 2));
  });
}

void toggleOverlay() {
  test('[viewer] toggle overlay', () async {
    final imageView = find.byValueKey('imageview');

    print('* hide overlay');
    await driver.tap(imageView);
    await Future.delayed(Duration(seconds: 1));

    print('* show overlay');
    await driver.tap(imageView);
    await Future.delayed(Duration(seconds: 1));
  });
}

void zoom() {
  test('[viewer] zoom cycle', () async {
    final imageView = find.byValueKey('imageview');

    await driver.doubleTap(imageView);
    await Future.delayed(Duration(seconds: 1));

    await driver.doubleTap(imageView);
    await Future.delayed(Duration(seconds: 1));

    await driver.doubleTap(imageView);
    await Future.delayed(Duration(seconds: 1));
  });
}

void showInfoMetadata() {
  test('[viewer] show info', () async {
    final verticalPageView = find.byValueKey('vertical-pageview');

    print('* scroll down to info');
    await driver.scroll(verticalPageView, 0, -600, Duration(milliseconds: 400));
    await Future.delayed(Duration(seconds: 2));

    print('* scroll down to metadata details');
    await driver.scroll(verticalPageView, 0, -800, Duration(milliseconds: 600));
    await Future.delayed(Duration(seconds: 1));

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
    await driver.scroll(verticalPageView, 0, 100, Duration(milliseconds: 400));
    await Future.delayed(Duration(seconds: 1));

    print('* back to image');
    await driver.tap(find.byValueKey('back-button'));
  });
}

void scrollOffImage() {
  test('[viewer] scroll off', () async {
    await driver.scroll(find.byValueKey('imageview'), 0, 800, Duration(milliseconds: 600));
    await Future.delayed(Duration(seconds: 1));
  });
}
