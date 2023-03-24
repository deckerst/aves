import 'package:aves/ref/unicode.dart';
import 'package:country_code/country_code.dart';

class GeoStates {
  static final Set<String> stateCountryCodes = {
    CountryCode.AU,
    CountryCode.GB,
    CountryCode.US,
  }.map((v) => v.alpha2).toSet();

  static const stateCodeByName = {
    ..._australiaEnglish,
    ..._unitedKingdomEnglish,
    ..._unitedStatesEnglish,
  };

  static const _australiaEnglish = {
    'Australian Capital Territory': EmojiStateCodes.auAustralianCapitalTerritory,
    'New South Wales': EmojiStateCodes.auNewSouthWales,
    'Northern Territory': EmojiStateCodes.auNorthernTerritory,
    'Queensland': EmojiStateCodes.auQueensland,
    'South Australia': EmojiStateCodes.auSouthAustralia,
    'Tasmania': EmojiStateCodes.auTasmania,
    'Victoria': EmojiStateCodes.auVictoria,
    'Western Australia': EmojiStateCodes.auWesternAustralia,
  };

  static const _unitedKingdomEnglish = {
    'England': EmojiStateCodes.gbEngland,
    'Northern Ireland': EmojiStateCodes.gbNorthernIreland,
    'Scotland': EmojiStateCodes.gbScotland,
    'Wales': EmojiStateCodes.gbWales,
  };

  static const _unitedStatesEnglish = {
    'Alabama': EmojiStateCodes.usAlabama,
    'Alaska': EmojiStateCodes.usAlaska,
    'Arizona': EmojiStateCodes.usArizona,
    'Arkansas': EmojiStateCodes.usArkansas,
    'California': EmojiStateCodes.usCalifornia,
    'Colorado': EmojiStateCodes.usColorado,
    'Connecticut': EmojiStateCodes.usConnecticut,
    'Delaware': EmojiStateCodes.usDelaware,
    'Florida': EmojiStateCodes.usFlorida,
    'Georgia': EmojiStateCodes.usGeorgia,
    'Hawaii': EmojiStateCodes.usHawaii,
    'Idaho': EmojiStateCodes.usIdaho,
    'Illinois': EmojiStateCodes.usIllinois,
    'Indiana': EmojiStateCodes.usIndiana,
    'Iowa': EmojiStateCodes.usIowa,
    'Kansas': EmojiStateCodes.usKansas,
    'Kentucky': EmojiStateCodes.usKentucky,
    'Louisiana': EmojiStateCodes.usLouisiana,
    'Maine': EmojiStateCodes.usMaine,
    'Maryland': EmojiStateCodes.usMaryland,
    'Massachusetts': EmojiStateCodes.usMassachusetts,
    'Michigan': EmojiStateCodes.usMichigan,
    'Minnesota': EmojiStateCodes.usMinnesota,
    'Mississippi': EmojiStateCodes.usMississippi,
    'Missouri': EmojiStateCodes.usMissouri,
    'Montana': EmojiStateCodes.usMontana,
    'Nebraska': EmojiStateCodes.usNebraska,
    'Nevada': EmojiStateCodes.usNevada,
    'New Hampshire': EmojiStateCodes.usNewHampshire,
    'New Jersey': EmojiStateCodes.usNewJersey,
    'New Mexico': EmojiStateCodes.usNewMexico,
    'New York': EmojiStateCodes.usNewYork,
    'North Carolina': EmojiStateCodes.usNorthCarolina,
    'North Dakota': EmojiStateCodes.usNorthDakota,
    'Ohio': EmojiStateCodes.usOhio,
    'Oklahoma': EmojiStateCodes.usOklahoma,
    'Oregon': EmojiStateCodes.usOregon,
    'Pennsylvania': EmojiStateCodes.usPennsylvania,
    'Rhode Island': EmojiStateCodes.usRhodeIsland,
    'South Carolina': EmojiStateCodes.usSouthCarolina,
    'South Dakota': EmojiStateCodes.usSouthDakota,
    'Tennessee': EmojiStateCodes.usTennessee,
    'Utah': EmojiStateCodes.usUtah,
    'Vermont': EmojiStateCodes.usVermont,
    'Virginia': EmojiStateCodes.usVirginia,
    'Washington': EmojiStateCodes.usWashington,
    'Washington DC': EmojiStateCodes.usWashingtonDC,
    'West Virginia': EmojiStateCodes.usWestVirginia,
    'Wisconsin': EmojiStateCodes.usWisconsin,
    'Wyoming': EmojiStateCodes.usWyoming,
  };
}
