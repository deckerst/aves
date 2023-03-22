import 'package:aves/utils/emoji_utils.dart';
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
    'Australian Capital Territory': StateCodes.auAustralianCapitalTerritory,
    'New South Wales': StateCodes.auNewSouthWales,
    'Northern Territory': StateCodes.auNorthernTerritory,
    'Queensland': StateCodes.auQueensland,
    'South Australia': StateCodes.auSouthAustralia,
    'Tasmania': StateCodes.auTasmania,
    'Victoria': StateCodes.auVictoria,
    'Western Australia': StateCodes.auWesternAustralia,
  };

  static const _unitedKingdomEnglish = {
    'England': StateCodes.gbEngland,
    'Northern Ireland': StateCodes.gbNorthernIreland,
    'Scotland': StateCodes.gbScotland,
    'Wales': StateCodes.gbWales,
  };

  static const _unitedStatesEnglish = {
    'Alabama': StateCodes.usAlabama,
    'Alaska': StateCodes.usAlaska,
    'Arizona': StateCodes.usArizona,
    'Arkansas': StateCodes.usArkansas,
    'California': StateCodes.usCalifornia,
    'Colorado': StateCodes.usColorado,
    'Connecticut': StateCodes.usConnecticut,
    'Delaware': StateCodes.usDelaware,
    'Florida': StateCodes.usFlorida,
    'Georgia': StateCodes.usGeorgia,
    'Hawaii': StateCodes.usHawaii,
    'Idaho': StateCodes.usIdaho,
    'Illinois': StateCodes.usIllinois,
    'Indiana': StateCodes.usIndiana,
    'Iowa': StateCodes.usIowa,
    'Kansas': StateCodes.usKansas,
    'Kentucky': StateCodes.usKentucky,
    'Louisiana': StateCodes.usLouisiana,
    'Maine': StateCodes.usMaine,
    'Maryland': StateCodes.usMaryland,
    'Massachusetts': StateCodes.usMassachusetts,
    'Michigan': StateCodes.usMichigan,
    'Minnesota': StateCodes.usMinnesota,
    'Mississippi': StateCodes.usMississippi,
    'Missouri': StateCodes.usMissouri,
    'Montana': StateCodes.usMontana,
    'Nebraska': StateCodes.usNebraska,
    'Nevada': StateCodes.usNevada,
    'New Hampshire': StateCodes.usNewHampshire,
    'New Jersey': StateCodes.usNewJersey,
    'New Mexico': StateCodes.usNewMexico,
    'New York': StateCodes.usNewYork,
    'North Carolina': StateCodes.usNorthCarolina,
    'North Dakota': StateCodes.usNorthDakota,
    'Ohio': StateCodes.usOhio,
    'Oklahoma': StateCodes.usOklahoma,
    'Oregon': StateCodes.usOregon,
    'Pennsylvania': StateCodes.usPennsylvania,
    'Rhode Island': StateCodes.usRhodeIsland,
    'South Carolina': StateCodes.usSouthCarolina,
    'South Dakota': StateCodes.usSouthDakota,
    'Tennessee': StateCodes.usTennessee,
    'Utah': StateCodes.usUtah,
    'Vermont': StateCodes.usVermont,
    'Virginia': StateCodes.usVirginia,
    'Washington': StateCodes.usWashington,
    'Washington DC': StateCodes.usWashingtonDC,
    'West Virginia': StateCodes.usWestVirginia,
    'Wisconsin': StateCodes.usWisconsin,
    'Wyoming': StateCodes.usWyoming,
  };
}
