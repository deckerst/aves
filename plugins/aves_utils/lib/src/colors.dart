import 'dart:convert';
import 'dart:ui';

import 'package:aves_utils/aves_utils.dart';
import 'package:flutter/foundation.dart';

class ColorUtils {
  // `Color(0x00FFFFFF)` is different from `Color(0x00000000)` (or `Colors.transparent`)
  // when used in gradients or lerping to it
  static const transparentWhite = Color(0x00FFFFFF);
  static const transparentBlack = Color(0x00000000);

  static Color textColorOn(Color background) {
    final l = luma(
      background.intRed,
      background.intGreen,
      background.intBlue,
    );
    return Color(l >= .5 ? 0xFF000000 : 0xFFFFFFFF);
  }

  // quick computation of luma (Y component of YUV or YIQ) from RGB
  // cf https://en.wikipedia.org/wiki/Y%E2%80%B2UV
  // cf https://en.wikipedia.org/wiki/YIQ
  // `Color.computeLuminance()` is more accurate, but slower
  // r, g, b in [0, 255], luma in [0, 1]
  static double luma(int r, int g, int b) {
    return (r * .299 + g * .587 + b * .114) / 255;
  }
}

extension ExtraColor on Color {
  int get intRed => (r * 255).round(); // sRGB red component
  int get intGreen => (g * 255).round(); // sRGB green component
  int get intBlue => (b * 255).round(); // sRGB blue component

  // serialization

  String toJsonString() => jsonEncode(toJsonMap());

  // either a `String` or a `Map<String, Object?>`
  static Color? fromJson(Object? json) {
    if (json == null) return null;

    try {
      Map? jsonMap;
      if (json is String) {
        if (json.isEmpty) return null;
        jsonMap = jsonDecode(json);
      } else if (json is Map) {
        jsonMap = json;
      }
      if (jsonMap != null) {
        return _fromMap(jsonMap.cast<String, Object?>());
      }
      debugPrint('failed to parse color from json=$json');
    } catch (error, stack) {
      debugPrint('failed to parse color from json=$json error=$error\n$stack');
    }
    return null;
  }

  Map<String, Object?> toJsonMap() => {
    'a': a,
    'r': r,
    'g': g,
    'b': b,
    'colorSpace': colorSpace.name,
  };

  static Color _fromMap(Map<String, Object?> map) {
    return Color.from(
      alpha: map['a'] as double,
      red: map['r'] as double,
      green: map['g'] as double,
      blue: map['b'] as double,
      colorSpace: ColorSpace.values.safeByName(map['colorSpace'] as String?) ?? ColorSpace.sRGB,
    );
  }
}
