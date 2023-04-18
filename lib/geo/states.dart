import 'package:aves/ref/unicode.dart';
import 'package:country_code/country_code.dart';

class GeoStates {
  static final aus = CountryCode.AU.alpha2;
  static final gbr = CountryCode.GB.alpha2;
  static final ind = CountryCode.IN.alpha2;
  static final usa = CountryCode.US.alpha2;

  static final Set<String> stateCountryCodes = {
    aus,
    gbr,
    ind,
    usa,
  };

  static final stateCodesByCountryCode = {
    aus: EmojiStateCodes.aus,
    gbr: EmojiStateCodes.gbr,
    ind: EmojiStateCodes.ind,
    usa: EmojiStateCodes.usa,
  };

  static const stateCodeByName = {
    ..._australiaEnglish,
    ..._indiaEnglish,
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

  static const _indiaEnglish = {
    'Andaman and Nicobar Islands': EmojiStateCodes.inAndamanAndNicobarIslands,
    'Andhra Pradesh': EmojiStateCodes.inAndhraPradesh,
    'Arunachal Pradesh': EmojiStateCodes.inArunachalPradesh,
    'Assam': EmojiStateCodes.inAssam,
    'Bihar': EmojiStateCodes.inBihar,
    'Chandigarh': EmojiStateCodes.inChandigarh,
    'Chhattisgarh': EmojiStateCodes.inChhattisgarh,
    'Daman and Diu': EmojiStateCodes.inDamanAndDiu,
    'Delhi': EmojiStateCodes.inDelhi,
    'Dadra and Nagar Haveli': EmojiStateCodes.inDadraAndNagarHaveli,
    'Goa': EmojiStateCodes.inGoa,
    'Gujarat': EmojiStateCodes.inGujarat,
    'Himachal Pradesh': EmojiStateCodes.inHimachalPradesh,
    'Haryana': EmojiStateCodes.inHaryana,
    'Jharkhand': EmojiStateCodes.inJharkhand,
    'Jammu and Kashmir': EmojiStateCodes.inJammuAndKashmir,
    'Karnataka': EmojiStateCodes.inKarnataka,
    'Kerala': EmojiStateCodes.inKerala,
    'Lakshadweep': EmojiStateCodes.inLakshadweep,
    'Maharashtra': EmojiStateCodes.inMaharashtra,
    'Meghalaya': EmojiStateCodes.inMeghalaya,
    'Manipur': EmojiStateCodes.inManipur,
    'Madhya Pradesh': EmojiStateCodes.inMadhyaPradesh,
    'Mizoram': EmojiStateCodes.inMizoram,
    'Nagaland': EmojiStateCodes.inNagaland,
    'Odisha': EmojiStateCodes.inOdisha,
    'Punjab': EmojiStateCodes.inPunjab,
    'Puducherry': EmojiStateCodes.inPuducherry,
    'Rajasthan': EmojiStateCodes.inRajasthan,
    'Sikkim': EmojiStateCodes.inSikkim,
    'Telangana': EmojiStateCodes.inTelangana,
    'Tamil Nadu': EmojiStateCodes.inTamilNadu,
    'Tripura': EmojiStateCodes.inTripura,
    'Uttar Pradesh': EmojiStateCodes.inUttarPradesh,
    'Uttarakhand': EmojiStateCodes.inUttarakhand,
    'West Bengal': EmojiStateCodes.inWestBengal,
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
