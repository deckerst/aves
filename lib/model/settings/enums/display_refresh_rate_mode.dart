import 'package:aves/services/common/services.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';

import 'enums.dart';

extension ExtraDisplayRefreshRateMode on DisplayRefreshRateMode {
  String getName(BuildContext context) {
    switch (this) {
      case DisplayRefreshRateMode.auto:
        return context.l10n.settingsSystemDefault;
      case DisplayRefreshRateMode.highest:
        return context.l10n.displayRefreshRatePreferHighest;
      case DisplayRefreshRateMode.lowest:
        return context.l10n.displayRefreshRatePreferLowest;
    }
  }

  Future<void> apply() async {
    if (!await windowService.isActivity()) return;

    final androidInfo = await DeviceInfoPlugin().androidInfo;
    if ((androidInfo.version.sdkInt ?? 0) < 23) return;

    debugPrint('Apply display refresh rate: $name');
    switch (this) {
      case DisplayRefreshRateMode.auto:
        await FlutterDisplayMode.setPreferredMode(DisplayMode.auto);
        break;
      case DisplayRefreshRateMode.highest:
        await FlutterDisplayMode.setHighRefreshRate();
        break;
      case DisplayRefreshRateMode.lowest:
        await FlutterDisplayMode.setLowRefreshRate();
        break;
    }
  }
}
