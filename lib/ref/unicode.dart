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

class EmojiStateCodes {
  // AU
  static const auAustralianCapitalTerritory = 'auact';
  static const auNewSouthWales = 'aunsw';
  static const auNorthernTerritory = 'aunt';
  static const auQueensland = 'auqld';
  static const auSouthAustralia = 'ausa';
  static const auTasmania = 'autas';
  static const auVictoria = 'auvic';
  static const auWesternAustralia = 'auwa';

  static const aus = {
    auAustralianCapitalTerritory,
    auNewSouthWales,
    auNorthernTerritory,
    auQueensland,
    auSouthAustralia,
    auTasmania,
    auVictoria,
    auWesternAustralia,
  };

  // GB
  static const gbEngland = 'gbeng';
  static const gbNorthernIreland = 'gbnir';
  static const gbScotland = 'gbsct';
  static const gbWales = 'gbwls';

  static const gbr = {
    gbEngland,
    gbNorthernIreland,
    gbScotland,
    gbWales,
  };

  // IN
  static const inAndamanAndNicobarIslands = 'inan';
  static const inAndhraPradesh = 'inap';
  static const inArunachalPradesh = 'inar';
  static const inAssam = 'inas';
  static const inBihar = 'inbr';
  static const inChandigarh = 'inch';
  static const inChhattisgarh = 'inct';
  static const inDamanAndDiu = 'indd';
  static const inDelhi = 'indl';
  static const inDadraAndNagarHaveli = 'indn';
  static const inGoa = 'inga';
  static const inGujarat = 'ingj';
  static const inHimachalPradesh = 'inhp';
  static const inHaryana = 'inhr';
  static const inJharkhand = 'injh';
  static const inJammuAndKashmir = 'injk';
  static const inKarnataka = 'inka';
  static const inKerala = 'inkl';
  static const inLakshadweep = 'inld';
  static const inMaharashtra = 'inmh';
  static const inMeghalaya = 'inml';
  static const inManipur = 'inmn';
  static const inMadhyaPradesh = 'inmp';
  static const inMizoram = 'inmz';
  static const inNagaland = 'innl';
  static const inOdisha = 'inor';
  static const inPunjab = 'inpb';
  static const inPuducherry = 'inpy';
  static const inRajasthan = 'inrj';
  static const inSikkim = 'insk';
  static const inTelangana = 'intg';
  static const inTamilNadu = 'intn';
  static const inTripura = 'intr';
  static const inUttarPradesh = 'inup';
  static const inUttarakhand = 'inut';
  static const inWestBengal = 'inwb';

  static const ind = {
    inAndamanAndNicobarIslands,
    inAndhraPradesh,
    inArunachalPradesh,
    inAssam,
    inBihar,
    inChandigarh,
    inChhattisgarh,
    inDamanAndDiu,
    inDelhi,
    inDadraAndNagarHaveli,
    inGoa,
    inGujarat,
    inHimachalPradesh,
    inHaryana,
    inJharkhand,
    inJammuAndKashmir,
    inKarnataka,
    inKerala,
    inLakshadweep,
    inMaharashtra,
    inMeghalaya,
    inManipur,
    inMadhyaPradesh,
    inMizoram,
    inNagaland,
    inOdisha,
    inPunjab,
    inPuducherry,
    inRajasthan,
    inSikkim,
    inTelangana,
    inTamilNadu,
    inTripura,
    inUttarPradesh,
    inUttarakhand,
    inWestBengal,
  };

  // MX
  static const mxAguascalientes = 'mxagu';
  static const mxBajaCalifornia = 'mxbcn';
  static const mxBajaCaliforniaSur = 'mxbcs';
  static const mxCampeche = 'mxcam';
  static const mxChiapas = 'mxchp';
  static const mxChihuahua = 'mxchh';
  static const mxCiudadDeMexico = 'mxcmx';
  static const mxCoahuila = 'mxcoa';
  static const mxColima = 'mxcol';
  static const mxDurango = 'mxdur';
  static const mxGuanajuato = 'mxgua';
  static const mxGuerrero = 'mxgro';
  static const mxHidalgo = 'mxhid';
  static const mxJalisco = 'mxjal';
  static const mxMexicoState = 'mxmex';
  static const mxMichoacan = 'mxmic';
  static const mxMorelos = 'mxmor';
  static const mxNayarit = 'mxnay';
  static const mxNuevoLeon = 'mxnle';
  static const mxOaxaca = 'mxoax';
  static const mxPuebla = 'mxpue';
  static const mxQueretaro = 'mxque';
  static const mxQuintanaRoo = 'mxroo';
  static const mxSanLuisPotosi = 'mxslp';
  static const mxSinaloa = 'mxsin';
  static const mxSonora = 'mxson';
  static const mxTabasco = 'mxtab';
  static const mxTamaulipas = 'mxtam';
  static const mxTlaxcala = 'mxtla';
  static const mxVeracruz = 'mxver';
  static const mxYucatan = 'mxyuc';
  static const mxZacatecas = 'mxzac';

  static const mex = {
    mxAguascalientes,
    mxBajaCalifornia,
    mxBajaCaliforniaSur,
    mxCampeche,
    mxChiapas,
    mxChihuahua,
    mxCiudadDeMexico,
    mxCoahuila,
    mxColima,
    mxDurango,
    mxGuanajuato,
    mxGuerrero,
    mxHidalgo,
    mxJalisco,
    mxMexicoState,
    mxMichoacan,
    mxMorelos,
    mxNayarit,
    mxNuevoLeon,
    mxOaxaca,
    mxPuebla,
    mxQueretaro,
    mxQuintanaRoo,
    mxSanLuisPotosi,
    mxSinaloa,
    mxSonora,
    mxTabasco,
    mxTamaulipas,
    mxTlaxcala,
    mxVeracruz,
    mxYucatan,
    mxZacatecas,
  };

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

  static const usa = {
    usAlabama,
    usAlaska,
    usArizona,
    usArkansas,
    usCalifornia,
    usColorado,
    usConnecticut,
    usDelaware,
    usFlorida,
    usGeorgia,
    usHawaii,
    usIdaho,
    usIllinois,
    usIndiana,
    usIowa,
    usKansas,
    usKentucky,
    usLouisiana,
    usMaine,
    usMaryland,
    usMassachusetts,
    usMichigan,
    usMinnesota,
    usMississippi,
    usMissouri,
    usMontana,
    usNebraska,
    usNevada,
    usNewHampshire,
    usNewJersey,
    usNewMexico,
    usNewYork,
    usNorthCarolina,
    usNorthDakota,
    usOhio,
    usOklahoma,
    usOregon,
    usPennsylvania,
    usRhodeIsland,
    usSouthCarolina,
    usSouthDakota,
    usTennessee,
    usUtah,
    usVermont,
    usVirginia,
    usWashington,
    usWashingtonDC,
    usWestVirginia,
    usWisconsin,
    usWyoming,
  };
}
