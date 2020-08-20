import 'package:aves/model/source/enums.dart';
import 'package:flutter_driver/flutter_driver.dart';
import 'package:path/path.dart' as path;
import 'package:pedantic/pedantic.dart';
import 'package:test/test.dart';

import 'constants.dart';
import 'driver_extension.dart';
import 'utils.dart';

FlutterDriver driver;

void main() {
  group('Aves app', () {
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
    sortCollection();
    groupCollection();
    searchAlbum();
    showFullscreen();
    toggleOverlay();
    zoom();
    showInfoMetadata();

    test('contemplation', () async {
      await Future.delayed(Duration(seconds: 5));
    });
  }, timeout: Timeout(Duration(seconds: 10)));
}

void agreeToTerms() {
  test('[welcome] agree to terms', () async {
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
}

void groupCollection() {
  test('[collection] group', () async {
    await driver.tap(find.byValueKey('appbar-menu-button'));
    await driver.waitUntilNoTransientCallbacks();

    await driver.tap(find.byValueKey('menu-group'));
    await driver.waitUntilNoTransientCallbacks();

    await driver.tap(find.byValueKey(GroupFactor.album.toString()));
    await driver.tap(find.byValueKey('apply-button'));
  });
}

void sortCollection() {
  test('[collection] sort', () async {
    await driver.tap(find.byValueKey('appbar-menu-button'));
    await driver.waitUntilNoTransientCallbacks();

    await driver.tap(find.byValueKey('menu-sort'));
    await driver.waitUntilNoTransientCallbacks();

    await driver.tap(find.byValueKey(SortFactor.date.toString()));
    await driver.tap(find.byValueKey('apply-button'));
  });
}

void searchAlbum() {
  test('[collection] search album', () async {
    await driver.tap(find.byValueKey('search-button'));
    await driver.waitUntilNoTransientCallbacks();

    final album = path.split(targetPicturesDir).last;
    await driver.tap(find.byType('TextField'));
    await driver.enterText(album);

    final albumChipFinder = find.byValueKey('album-$album');
    await driver.waitFor(albumChipFinder);
    await driver.tap(albumChipFinder);
  });
}

void showFullscreen() {
  test('[collection] show fullscreen', () async {
    await driver.tap(find.byType('DecoratedThumbnail'));
    await driver.waitUntilNoTransientCallbacks();
    await Future.delayed(Duration(seconds: 2));
  });
}

void toggleOverlay() {
  test('[fullscreen] toggle overlay', () async {
    final imageViewFinder = find.byValueKey('imageview');

    print('* hide overlay');
    await driver.tap(imageViewFinder);
    await Future.delayed(Duration(seconds: 1));

    print('* show overlay');
    await driver.tap(imageViewFinder);
    await Future.delayed(Duration(seconds: 1));
  });
}

void zoom() {
  test('[fullscreen] zoom cycle', () async {
    final imageViewFinder = find.byValueKey('imageview');

    await driver.doubleTap(imageViewFinder);
    await Future.delayed(Duration(seconds: 1));

    await driver.doubleTap(imageViewFinder);
    await Future.delayed(Duration(seconds: 1));

    await driver.doubleTap(imageViewFinder);
    await Future.delayed(Duration(seconds: 1));
  });
}

void showInfoMetadata() {
  test('[fullscreen] show info', () async {
    final verticalPageViewFinder = find.byValueKey('vertical-pageview');

    print('* scroll down to info');
    await driver.scroll(verticalPageViewFinder, 0, -600, Duration(milliseconds: 400));
    await Future.delayed(Duration(seconds: 2));

    print('* scroll down to metadata details');
    await driver.scroll(verticalPageViewFinder, 0, -800, Duration(milliseconds: 600));
    await Future.delayed(Duration(seconds: 1));

    print('* toggle GPS metadata');
    final gpsTileFinder = find.descendant(
      of: find.byValueKey('tilecard-GPS'),
      matching: find.byType('ListTile'),
    );
    await driver.tap(gpsTileFinder);
    await driver.waitUntilNoTransientCallbacks();
    await driver.tap(gpsTileFinder);
    await driver.waitUntilNoTransientCallbacks();

    print('* scroll up to show app bar');
    await driver.scroll(verticalPageViewFinder, 0, 100, Duration(milliseconds: 400));
    await Future.delayed(Duration(seconds: 1));

    print('* back to image');
    await driver.tap(find.byValueKey('back-button'));
  });
}
