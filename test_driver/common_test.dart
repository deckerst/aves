/*
  This file is imported by driver test files.
  It should not import, directly or indirectly,
  `dart:ui`, `flutter/widgets.dart', etc.
 */

const adbRoot = '/sdcard';
const androidRoot = '/storage/emulated/0';

const shadersSourceDir = 'test_driver/assets/shaders/';
const shadersTargetDirAdb = '$adbRoot/Pictures/Aves Test Driver/';
const shadersTargetDirAndroid = '$androidRoot/Pictures/Aves Test Driver';

// Cover items should be:
// - dated in the future,
// - geotagged for each country to cover.
// Viewer items should be:
// - larger than screen,
// - located,
// - tagged (one tag only, so filter chips fit on one line).
const screenshotsSourceDir = 'test_driver/assets/screenshots/';
const screenshotsTargetDirAdb = '$adbRoot/Pictures/TD/Aves/';
const screenshotsTargetDirAndroid = '$androidRoot/Pictures/TD/Aves';
