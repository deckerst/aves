import 'package:aves/widgets/debug/app_debug_action.dart';
import 'package:flutter_driver/flutter_driver.dart';

import 'adb_utils.dart';

extension ExtraFlutterDriver on FlutterDriver {
  static const doubleTapDelay = Duration(milliseconds: 100); // in [kDoubleTapMinTime = 40 ms, kDoubleTapTimeout = 300 ms]

  Future doubleTap(SerializableFinder finder, {Duration? timeout}) async {
    await tap(finder, timeout: timeout);
    await Future.delayed(doubleTapDelay);
    await tap(finder, timeout: timeout);
  }

  Future<void> tapKeyAndWait(String key) async {
    await tap(find.byValueKey(key));
    await waitUntilNoTransientCallbacks();
  }

  Future<void> scanMediaDir(String dir) async {
    await tapKeyAndWait('appbar-leading-button');
    await scroll(find.byValueKey('drawer-settings-button'), 0, -500, const Duration(milliseconds: 500));
    await tapKeyAndWait('drawer-debug');

    await tapKeyAndWait('appbar-menu-button');
    await tapKeyAndWait('menu-${AppDebugAction.mediaStoreScanDir.name}');

    await tap(find.byType('TextField'));
    await enterText(dir);

    await tap(find.byType('TextButton'));
    await waitUntilNoTransientCallbacks();

    await pressDeviceBackButton();
    await waitUntilNoTransientCallbacks();
  }
}
