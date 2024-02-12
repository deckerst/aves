import 'package:aves_model/aves_model.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

extension ExtraWidgetOutline on WidgetOutline {
  Future<Color?> color(Brightness brightness) async {
    switch (this) {
      case WidgetOutline.none:
        return SynchronousFuture(null);
      case WidgetOutline.black:
        return SynchronousFuture(Colors.black);
      case WidgetOutline.white:
        return SynchronousFuture(Colors.white);
      case WidgetOutline.systemBlackAndWhite:
        return SynchronousFuture(brightness == Brightness.dark ? Colors.black : Colors.white);
      case WidgetOutline.systemDynamic:
        final corePalette = await DynamicColorPlugin.getCorePalette();
        final scheme = corePalette?.toColorScheme(brightness: brightness);
        return scheme?.primary ?? await WidgetOutline.systemBlackAndWhite.color(brightness);
    }
  }
}
