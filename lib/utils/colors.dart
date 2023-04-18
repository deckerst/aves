import 'dart:ui';

class ColorUtils {
  // `Color(0x00FFFFFF)` is different from `Color(0x00000000)` (or `Colors.transparent`)
  // when used in gradients or lerping to it
  static const transparentWhite = Color(0x00FFFFFF);
  static const transparentBlack = Color(0x00000000);
}
