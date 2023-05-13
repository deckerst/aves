import 'package:aves/services/common/services.dart';
import 'package:aves_model/aves_model.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';

extension ExtraDisplayRefreshRateMode on DisplayRefreshRateMode {
  Future<void> apply() async {
    if (!await windowService.isActivity()) return;

    final androidInfo = await DeviceInfoPlugin().androidInfo;
    if (androidInfo.version.sdkInt < 23) return;

    debugPrint('Apply display refresh rate: $name');
    switch (this) {
      case DisplayRefreshRateMode.auto:
        await FlutterDisplayMode.setPreferredMode(DisplayMode.auto);
      case DisplayRefreshRateMode.highest:
        await FlutterDisplayMode.setHighRefreshRate();
      case DisplayRefreshRateMode.lowest:
        await FlutterDisplayMode.setLowRefreshRate();
    }
  }
}
