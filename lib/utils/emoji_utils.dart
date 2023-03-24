import 'package:aves/ref/unicode.dart';

class EmojiUtils {
  static const _countryCodeToFlagDiff = UniCodes.regionalIndicatorSymbolLetterA - UniCodes.latinCapitalLetterA;
  static const _stateCodeToFlagDiff = UniCodes.tagLatinSmallLetterA - UniCodes.latinCapitalLetterA;
  static const _subFlagStart = UniCodes.wavingBlackFlag;
  static const _subFlagEnd = UniCodes.cancelTag;

  static String? countryCodeToFlag(String? code) {
    if (code == null || code.length != 2) return null;
    return String.fromCharCodes(code.toUpperCase().codeUnits.map((letter) => letter += _countryCodeToFlagDiff));
  }

  static String? stateCodeToFlag(String? code) {
    if (code == null) return null;
    return String.fromCharCodes([
      _subFlagStart,
      ...code.toUpperCase().codeUnits.map((letter) => letter += _stateCodeToFlagDiff),
      _subFlagEnd,
    ]);
  }
}
