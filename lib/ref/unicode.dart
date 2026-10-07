// cf Flutter's `foundation/unicode.dart` for bidi related characters
class UniChars {
  static const noBreakSpace = '\u00A0';
  static const multiplicationSign = '\u00D7'; // ×
  static const emDash = '\u2014'; // —
  static const bullet = '\u2022'; // •
  static const ratio = '\u2236'; // ∶
  static const whiteMediumStar = '\u2B50'; // ⭐
}

class UniCodes {
  // Block: Basic Latin
  static const latinCapitalLetterA = 0x0041;

  // Block: Enclosed Alphanumeric Supplement
  static const regionalIndicatorSymbolLetterA = 0x1F1E6;

  // Block: Miscellaneous Symbols and Pictographs
  static const wavingBlackFlag = 0x1F3F4;

  // Block: Tags
  static const tagLatinSmallLetterA = 0xE0061;
  static const cancelTag = 0xE007F;
}
