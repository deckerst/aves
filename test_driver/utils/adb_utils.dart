import 'dart:io';

import 'package:path/path.dart' as p;

String get adb {
  if (Platform.isWindows) {
    final env = Platform.environment;
    // e.g. C:\Users\<username>\AppData\Local\Android\Sdk
    final sdkDir = env['ANDROID_SDK_ROOT'] ?? env['ANDROID_SDK']!;
    return p.join(sdkDir, 'platform-tools', 'adb.exe');
  }
  return 'adb';
}

/*
  If there's only one emulator running or only one device connected,
  the adb command is sent to that device by default.
  If multiple emulators are running and/or multiple devices are attached,
  you need to use the -d, -e, or -s option to specify the target device
  to which the command should be directed.
 */
const List<String> adbDeviceParam = ['-d']; // `[]`, `['-d']`, `['-e']`, or `['-s', <serial_number>]`

Future<void> runAdb(List<String> args) async {
  await Process.run(adb, [...adbDeviceParam, ...args]);
}

Future<void> createDirectory(String dir) async {
  await runAdb(['shell', 'mkdir', '-p', dir.replaceAll(' ', '\\ ')]);
}

Future<void> removeDirectory(String dir) async {
  await runAdb(['shell', 'rm', '-r', dir.replaceAll(' ', '\\ ')]);
}

Future<void> copyContent(String sourceDir, String targetDir) async {
  // to copy the content of `source` inside `target`
  // `push source/* target/` works only when the target directory exists, and fails when `target` contains spaces
  // `push source/ target/` works only when the target directory does not exist
  await removeDirectory(targetDir);
  await runAdb(['push', sourceDir, targetDir]);
}

// only works in debug mode
Future<void> grantPermissions(String packageName, Iterable<String> permissions) async {
  await Future.forEach<String>(permissions, (permission) => runAdb(['shell', 'pm', 'grant', packageName, permission]));
}

Future<void> pressDeviceBackButton() => runAdb(['shell', 'input', 'keyevent', 'KEYCODE_BACK']);
