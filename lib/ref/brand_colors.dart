import 'package:flutter/painting.dart';

class BrandColors {
  static const Color adobeAfterEffects = Color(0xFF9A9AFF);
  static const Color adobeIllustrator = Color(0xFFFF9B00);
  static const Color adobePhotoshop = Color(0xFF2DAAFF);
  static const Color android = Color(0xFF3DDC84);
  static const Color flutter = Color(0xFF47D1FD);

  static Color get(String text) {
    if (text != null) {
      switch (text.toLowerCase()) {
        case 'after effects':
          return adobeAfterEffects;
        case 'illustrator':
          return adobeIllustrator;
        case 'photoshop':
        case 'lightroom':
          return adobePhotoshop;
      }
    }
    return null;
  }
}
