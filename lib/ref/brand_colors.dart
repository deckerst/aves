import 'dart:ui';

class BrandColors {
  static const adobeAfterEffects = Color(0xFF9A9AFF);
  static const adobeIllustrator = Color(0xFFFF9B00);
  static const adobePhotoshop = Color(0xFF2DAAFF);
  static const android = Color(0xFF3DDC84);
  static const flutter = Color(0xFF47D1FD);

  static Color? get(String text) {
    switch (text.toLowerCase()) {
      case 'after effects':
        return adobeAfterEffects;
      case 'illustrator':
        return adobeIllustrator;
      case 'photoshop':
      case 'lightroom':
        return adobePhotoshop;
    }
    return null;
  }
}
