import 'package:aves_model/aves_model.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

extension ExtraWidgetOutline on WidgetOutline {
  Future<Color?> color(Brightness brightness) async {
    switch (this) {
      case .none:
        return SynchronousFuture(null);
      case .black:
        return SynchronousFuture(Colors.black);
      case .white:
        return SynchronousFuture(Colors.white);
      case .systemBlackAndWhite:
        return SynchronousFuture(brightness == Brightness.dark ? Colors.black : Colors.white);
      case .systemBlackAndWhiteHighContrast:
        return SynchronousFuture(brightness == Brightness.dark ? Colors.white : Colors.black);
      case .systemDynamicLowContrast:
        final color = await _getDynamicColor(brightness == Brightness.dark ? Brightness.light : Brightness.dark);
        return color ?? await WidgetOutline.systemBlackAndWhite.color(brightness);
      case .systemDynamic:
        final color = await _getDynamicColor(brightness);
        return color ?? await WidgetOutline.systemBlackAndWhiteHighContrast.color(brightness);
    }
  }

  Future<Color?> _getDynamicColor(Brightness brightness) async {
    final corePalette = await DynamicColorPlugin.getCorePalette();
    final scheme = corePalette?.toColorScheme(brightness: brightness);
    return scheme?.primary;
  }
}
