class EmojiUtils {
  // U+0041 Latin Capital letter A
  static const _capitalLetterA = 0x0041;

  // U+1F1E6 Regional Indicator Symbol Letter A
  static const _countryCodeToFlagDiff = 0x1F1E6 - _capitalLetterA;

  // U+E0061 Tag Latin Small Letter a
  static const _stateCodeToFlagDiff = 0xE0061 - _capitalLetterA;

  static const _blackFlag = 0x1F3F4;
  static const _cancel = 0xE007F;

  static String? countryCodeToFlag(String? code) {
    if (code == null || code.length != 2) return null;
    return String.fromCharCodes(code.toUpperCase().codeUnits.map((letter) => letter += _countryCodeToFlagDiff));
  }

  static String? stateCodeToFlag(String? code) {
    if (code == null) return null;
    return String.fromCharCodes([_blackFlag, ...code.toUpperCase().codeUnits.map((letter) => letter += _stateCodeToFlagDiff), _cancel]);
  }
}

class StateCodes {
  // AU
  static const auAustralianCapitalTerritory = 'auact';
  static const auNewSouthWales = 'aunsw';
  static const auNorthernTerritory = 'aunt';
  static const auQueensland = 'auqld';
  static const auSouthAustralia = 'ausa';
  static const auTasmania = 'autas';
  static const auVictoria = 'auvic';
  static const auWesternAustralia = 'auwa';

  // GB
  static const gbEngland = 'gbeng';
  static const gbNorthernIreland = 'gbnir';
  static const gbScotland = 'gbsct';
  static const gbWales = 'gbwls';

  // US
  static const usAlabama = 'usal';
  static const usAlaska = 'usak';
  static const usArizona = 'usaz';
  static const usArkansas = 'usar';
  static const usCalifornia = 'usca';
  static const usColorado = 'usco';
  static const usConnecticut = 'usct';
  static const usDelaware = 'usde';
  static const usFlorida = 'usfl';
  static const usGeorgia = 'usga';
  static const usHawaii = 'ushi';
  static const usIdaho = 'usid';
  static const usIllinois = 'usil';
  static const usIndiana = 'usin';
  static const usIowa = 'usia';
  static const usKansas = 'usks';
  static const usKentucky = 'usky';
  static const usLouisiana = 'usla';
  static const usMaine = 'usme';
  static const usMaryland = 'usmd';
  static const usMassachusetts = 'usma';
  static const usMichigan = 'usmi';
  static const usMinnesota = 'usmn';
  static const usMississippi = 'usms';
  static const usMissouri = 'usmo';
  static const usMontana = 'usmt';
  static const usNebraska = 'usne';
  static const usNevada = 'usnv';
  static const usNewHampshire = 'usnh';
  static const usNewJersey = 'usnj';
  static const usNewMexico = 'usnm';
  static const usNewYork = 'usny';
  static const usNorthCarolina = 'usnc';
  static const usNorthDakota = 'usnd';
  static const usOhio = 'usoh';
  static const usOklahoma = 'usok';
  static const usOregon = 'usor';
  static const usPennsylvania = 'uspa';
  static const usRhodeIsland = 'usri';
  static const usSouthCarolina = 'ussc';
  static const usSouthDakota = 'ussd';
  static const usTennessee = 'ustn';
  static const usUtah = 'usut';
  static const usVermont = 'usvt';
  static const usVirginia = 'usva';
  static const usWashington = 'uswa';
  static const usWashingtonDC = 'usdc';
  static const usWestVirginia = 'uswv';
  static const usWisconsin = 'uswi';
  static const usWyoming = 'uswy';
}
