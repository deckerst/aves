import 'dart:ui';

class ColorUtils {
  // `Color(0x00FFFFFF)` is different from `Color(0x00000000)` (or `Colors.transparent`)
  // when used in gradients or lerping to it
  static const transparentWhite = Color(0x00FFFFFF);
  static const transparentBlack = Color(0x00000000);

  static Color textColorOn(Color background) {
    final yiq = (background.red * 299 + background.green * 587 + background.blue * 114) / 1000;
    return Color(yiq >= 128 ? 0xFF000000 : 0xFFFFFFFF);
  }
}
