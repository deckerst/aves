import 'package:flutter_driver/flutter_driver.dart';

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
}
