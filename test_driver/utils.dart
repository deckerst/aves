import 'dart:io';

import 'package:flutter_driver/flutter_driver.dart';
import 'package:path/path.dart';

String get adb {
  final env = Platform.environment;
  final sdkDir = env['ANDROID_SDK_ROOT'] ?? env['ANDROID_SDK'];
  return join(sdkDir, 'platform-tools', Platform.isWindows ? 'adb.exe' : 'adb');
}

Future<void> createDirectory(String dir) async {
  await Process.run(adb, ['shell', 'mkdir -p', dir.replaceAll(' ', '\\ ')]);
}

Future<void> removeDirectory(String dir) async {
  await Process.run(adb, ['shell', 'rm -r', dir.replaceAll(' ', '\\ ')]);
}

Future<void> copyContent(String sourceDir, String targetDir) async {
  // to copy the content of `source` inside `target`
  // `push source/* target/` works only when the target directory exists, and fails when `target` contains spaces
  // `push source/ target/` works only when the target directory does not exist
  await removeDirectory(targetDir);
  await Process.run(adb, ['push', sourceDir, targetDir]);
}

Future<void> grantPermissions(String packageName, Iterable<String> permissions) async {
  await Future.forEach(permissions, (permission) => Process.run(adb, ['shell', 'pm', 'grant', packageName, permission]));
}

Future<bool> isEnabled(FlutterDriver driver, SerializableFinder widgetFinder) async {
  Map widgetDiagnostics = await driver.getWidgetDiagnostics(widgetFinder);
  return widgetDiagnostics['properties'].firstWhere((property) => property['name'] == 'enabled')['value'];
}
