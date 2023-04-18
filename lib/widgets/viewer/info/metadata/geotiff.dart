import 'package:aves/ref/metadata/geotiff.dart';

class GeoTiffDirectory {
  // TODO TLAD [geotiff] avoid string-based match
  static int? tagForName(String name) {
    switch (name) {
      case 'Model Type':
        return GeoTiffKeys.modelType;
      case 'Raster Type':
        return GeoTiffKeys.rasterType;
      case 'Geographic Type':
        return GeoTiffKeys.geographicType;
      case 'Geographic Geodetic Datum':
        return GeoTiffKeys.geogGeodeticDatum;
      case 'Geographic Angular Units':
        return GeoTiffKeys.geogAngularUnits;
      case 'Geographic Ellipsoid':
        return GeoTiffKeys.geogEllipsoid;
      case 'Projected Coordinate System Type':
        return GeoTiffKeys.projCSType;
      case 'Projection':
        return GeoTiffKeys.projection;
      case 'Projected Coordinate Transform':
        return GeoTiffKeys.projCoordinateTransform;
      case 'Projection Linear Units':
        return GeoTiffKeys.projLinearUnits;
      case 'Vertical Units':
        return GeoTiffKeys.verticalUnits;
      default:
        return null;
    }
  }

  static String formatValue(int? tag, String v) {
    switch (tag) {
      case GeoTiffKeys.modelType:
        return getModelTypeDescription(v);
      case GeoTiffKeys.rasterType:
        return getRasterTypeDescription(v);
      case GeoTiffKeys.geographicType:
        return getGeographicTypeDescription(v);
      case GeoTiffKeys.geogGeodeticDatum:
        return getGeogGeodeticDatumDescription(v);
      case GeoTiffKeys.geogEllipsoid:
        return getGeogEllipsoidDescription(v);
      case GeoTiffKeys.projCSType:
        return getProjCSTypeDescription(v);
      case GeoTiffKeys.projection:
        return getProjectionDescription(v);
      case GeoTiffKeys.projCoordinateTransform:
        return getProjCoordinateTransformDescription(v);
      case GeoTiffKeys.projLinearUnits:
      case GeoTiffKeys.geogAngularUnits:
      case GeoTiffKeys.verticalUnits:
        return getGeoTiffUnitsDescription(v);
      default:
        return v;
    }
  }

  static String getModelTypeDescription(String valueString) {
    final value = int.tryParse(valueString);
    if (value == null) return valueString;
    switch (value) {
      case 1:
        return 'Projected';
      case 2:
        return 'Geographic';
      case 3:
        return 'Geocentric';
      case 32767:
        return 'User Defined';
      default:
        return 'Unknown ($value)';
    }
  }

  static String getRasterTypeDescription(String valueString) {
    final value = int.tryParse(valueString);
    if (value == null) return valueString;
    switch (value) {
      case 1:
        return 'Pixel Is Area';
      case 2:
        return 'Pixel Is Point';
      case 32767:
        return 'User Defined';
      default:
        return 'Unknown ($value)';
    }
  }

  static String getGeographicTypeDescription(String valueString) {
    final value = int.tryParse(valueString);
    if (value == null) return valueString;
    switch (value) {
      case 4001:
        return 'Airy 1830';
      case 4002:
        return 'Airy Modified 1849';
      case 4003:
        return 'Australian National Spheroid';
      case 4004:
        return 'Bessel 1841';
      case 4005:
        return 'Bessel Modified';
      case 4006:
        return 'Bessel Namibia';
      case 4007:
        return 'Clarke 1858';
      case 4008:
        return 'Clarke 1866';
      case 4009:
        return 'Clarke 1866 Michigan';
      case 4010:
        return 'Clarke 1880 Benoit';
      case 4011:
        return 'Clarke 1880 IGN';
      case 4012:
        return 'Clarke 1880 RGS';
      case 4013:
        return 'Clarke 1880 Arc';
      case 4014:
        return 'Clarke 1880 SGA 1922';
      case 4015:
        return 'Everest 1830 1937 Adjustment';
      case 4016:
        return 'Everest 1830 1967 Definition';
      case 4017:
        return 'Everest 1830 1975 Definition';
      case 4018:
        return 'Everest 1830 Modified';
      case 4019:
        return 'GRS 1980';
      case 4020:
        return 'Helmert 1906';
      case 4021:
        return 'Indonesian National Spheroid';
      case 4022:
        return 'International 1924';
      case 4023:
        return 'International 1967';
      case 4024:
        return 'Krassowsky 1940';
      case 4025:
        return 'NWL9D';
      case 4026:
        return 'NWL10D';
      case 4027:
        return 'Plessis 1817';
      case 4028:
        return 'Struve 1860';
      case 4029:
        return 'War Office';
      case 4030:
        return 'WGS84';
      case 4031:
        return 'GEM10C';
      case 4032:
        return 'OSU86F';
      case 4033:
        return 'OSU91A';
      case 4034:
        return 'Clarke 1880';
      case 4035:
        return 'Sphere';
      case 4120:
        return 'Greek';
      case 4121:
        return 'GGRS87';
      case 4123:
        return 'KKJ';
      case 4124:
        return 'RT90';
      case 4133:
        return 'EST92';
      case 4201:
        return 'Adindan';
      case 4202:
        return 'AGD66';
      case 4203:
        return 'AGD84';
      case 4204:
        return 'Ain el Abd';
      case 4205:
        return 'Afgooye';
      case 4206:
        return 'Agadez';
      case 4207:
        return 'Lisbon';
      case 4208:
        return 'Aratu';
      case 4209:
        return 'Arc 1950';
      case 4210:
        return 'Arc 1960';
      case 4211:
        return 'Batavia';
      case 4212:
        return 'Barbados';
      case 4213:
        return 'Beduaram';
      case 4214:
        return 'Beijing 1954';
      case 4215:
        return 'Belge 1950';
      case 4216:
        return 'Bermuda 1957';
      case 4217:
        return 'Bern 1898';
      case 4218:
        return 'Bogota';
      case 4219:
        return 'Bukit Rimpah';
      case 4220:
        return 'Camacupa';
      case 4221:
        return 'Campo Inchauspe';
      case 4222:
        return 'Cape';
      case 4223:
        return 'Carthage';
      case 4224:
        return 'Chua';
      case 4225:
        return 'Corrego Alegre';
      case 4226:
        return 'Cote d Ivoire';
      case 4227:
        return 'Deir ez Zor';
      case 4228:
        return 'Douala';
      case 4229:
        return 'Egypt 1907';
      case 4230:
        return 'ED50';
      case 4231:
        return 'ED87';
      case 4232:
        return 'Fahud';
      case 4233:
        return 'Gandajika 1970';
      case 4234:
        return 'Garoua';
      case 4235:
        return 'Guyane Francaise';
      case 4236:
        return 'Hu Tzu Shan';
      case 4237:
        return 'HD72';
      case 4238:
        return 'ID74';
      case 4239:
        return 'Indian 1954';
      case 4240:
        return 'Indian 1975';
      case 4241:
        return 'Jamaica 1875';
      case 4242:
        return 'JAD69';
      case 4243:
        return 'Kalianpur';
      case 4244:
        return 'Kandawala';
      case 4245:
        return 'Kertau';
      case 4246:
        return 'KOC';
      case 4247:
        return 'La Canoa';
      case 4248:
        return 'PSAD56';
      case 4249:
        return 'Lake';
      case 4250:
        return 'Leigon';
      case 4251:
        return 'Liberia 1964';
      case 4252:
        return 'Lome';
      case 4253:
        return 'Luzon 1911';
      case 4254:
        return 'Hito XVIII 1963';
      case 4255:
        return 'Herat North';
      case 4256:
        return 'Mahe 1971';
      case 4257:
        return 'Makassar';
      case 4258:
        return 'EUREF89';
      case 4259:
        return 'Malongo 1987';
      case 4260:
        return 'Manoca';
      case 4261:
        return 'Merchich';
      case 4262:
        return 'Massawa';
      case 4263:
        return 'Minna';
      case 4264:
        return 'Mhast';
      case 4265:
        return 'Monte Mario';
      case 4266:
        return 'M poraloko';
      case 4267:
        return 'NAD27';
      case 4268:
        return 'NAD Michigan';
      case 4269:
        return 'NAD83';
      case 4270:
        return 'Nahrwan 1967';
      case 4271:
        return 'Naparima 1972';
      case 4272:
        return 'GD49';
      case 4273:
        return 'NGO 1948';
      case 4274:
        return '73';
      case 4275:
        return 'NTF';
      case 4276:
        return 'NSWC 9Z 2';
      case 4277:
        return 'OSGB 1936';
      case 4278:
        return 'OSGB70';
      case 4279:
        return 'OS SN80';
      case 4280:
        return 'Padang';
      case 4281:
        return 'Palestine 1923';
      case 4282:
        return 'Pointe Noire';
      case 4283:
        return 'GDA94';
      case 4284:
        return 'Pulkovo 1942';
      case 4285:
        return 'Qatar';
      case 4286:
        return 'Qatar 1948';
      case 4287:
        return 'Qornoq';
      case 4288:
        return 'Loma Quintana';
      case 4289:
        return 'Amersfoort';
      case 4290:
        return 'RT38';
      case 4291:
        return 'SAD69';
      case 4292:
        return 'Sapper Hill 1943';
      case 4293:
        return 'Schwarzeck';
      case 4294:
        return 'Segora';
      case 4295:
        return 'Serindung';
      case 4296:
        return 'Sudan';
      case 4297:
        return 'Tananarive';
      case 4298:
        return 'Timbalai 1948';
      case 4299:
        return 'TM65';
      case 4300:
        return 'TM75';
      case 4301:
        return 'Tokyo';
      case 4302:
        return 'Trinidad 1903';
      case 4303:
        return 'TC 1948';
      case 4304:
        return 'Voirol 1875';
      case 4305:
        return 'Voirol Unifie';
      case 4306:
        return 'Bern 1938';
      case 4307:
        return 'Nord Sahara 1959';
      case 4308:
        return 'Stockholm 1938';
      case 4309:
        return 'Yacare';
      case 4310:
        return 'Yoff';
      case 4311:
        return 'Zanderij';
      case 4312:
        return 'MGI';
      case 4313:
        return 'Belge 1972';
      case 4314:
        return 'DHDN';
      case 4315:
        return 'Conakry 1905';
      case 4317:
        return 'Dealul Piscului 1970';
      case 4322:
        return 'WGS 72';
      case 4324:
        return 'WGS 72BE';
      case 4326:
        return 'WGS 84';
      case 4801:
        return 'Bern 1898 Bern';
      case 4802:
        return 'Bogota Bogota';
      case 4803:
        return 'Lisbon Lisbon';
      case 4804:
        return 'Makassar Jakarta';
      case 4805:
        return 'MGI Ferro';
      case 4806:
        return 'Monte Mario Rome';
      case 4807:
        return 'NTF Paris';
      case 4808:
        return 'Padang Jakarta';
      case 4809:
        return 'Belge 1950 Brussels';
      case 4810:
        return 'Tananarive Paris';
      case 4811:
        return 'Voirol 1875 Paris';
      case 4812:
        return 'Voirol Unifie Paris';
      case 4813:
        return 'Batavia Jakarta';
      case 4815:
        return 'Greek Athens';
      case 4901:
        return 'ATF Paris';
      case 4902:
        return 'NDG Paris';
      case 32767:
        return 'User Defined';
      default:
        return 'Unknown ($value)';
    }
  }

  static String getGeogGeodeticDatumDescription(String valueString) {
    final value = int.tryParse(valueString);
    if (value == null) return valueString;
    switch (value) {
      case 6001:
        return 'Airy 1830';
      case 6002:
        return 'Airy Modified 1849';
      case 6003:
        return 'Australian National Spheroid';
      case 6004:
        return 'Bessel 1841';
      case 6005:
        return 'Bessel Modified';
      case 6006:
        return 'Bessel Namibia';
      case 6007:
        return 'Clarke 1858';
      case 6008:
        return 'Clarke 1866';
      case 6009:
        return 'Clarke 1866 Michigan';
      case 6010:
        return 'Clarke 1880 Benoit';
      case 6011:
        return 'Clarke 1880 IGN';
      case 6012:
        return 'Clarke 1880 RGS';
      case 6013:
        return 'Clarke 1880 Arc';
      case 6014:
        return 'Clarke 1880 SGA 1922';
      case 6015:
        return 'Everest 1830 1937 Adjustment';
      case 6016:
        return 'Everest 1830 1967 Definition';
      case 6017:
        return 'Everest 1830 1975 Definition';
      case 6018:
        return 'Everest 1830 Modified';
      case 6019:
        return 'GRS 1980';
      case 6020:
        return 'Helmert 1906';
      case 6021:
        return 'Indonesian National Spheroid';
      case 6022:
        return 'International 1924';
      case 6023:
        return 'International 1967';
      case 6024:
        return 'Krassowsky 1960';
      case 6025:
        return 'NWL9D';
      case 6026:
        return 'NWL10D';
      case 6027:
        return 'Plessis 1817';
      case 6028:
        return 'Struve 1860';
      case 6029:
        return 'War Office';
      case 6030:
        return 'WGS84';
      case 6031:
        return 'GEM10C';
      case 6032:
        return 'OSU86F';
      case 6033:
        return 'OSU91A';
      case 6034:
        return 'Clarke 1880';
      case 6035:
        return 'Sphere';
      case 6201:
        return 'Adindan';
      case 6202:
        return 'Australian Geodetic Datum 1966';
      case 6203:
        return 'Australian Geodetic Datum 1984';
      case 6204:
        return 'Ain el Abd 1970';
      case 6205:
        return 'Afgooye';
      case 6206:
        return 'Agadez';
      case 6207:
        return 'Lisbon';
      case 6208:
        return 'Aratu';
      case 6209:
        return 'Arc 1950';
      case 6210:
        return 'Arc 1960';
      case 6211:
        return 'Batavia';
      case 6212:
        return 'Barbados';
      case 6213:
        return 'Beduaram';
      case 6214:
        return 'Beijing 1954';
      case 6215:
        return 'Reseau National Belge 1950';
      case 6216:
        return 'Bermuda 1957';
      case 6217:
        return 'Bern 1898';
      case 6218:
        return 'Bogota';
      case 6219:
        return 'Bukit Rimpah';
      case 6220:
        return 'Camacupa';
      case 6221:
        return 'Campo Inchauspe';
      case 6222:
        return 'Cape';
      case 6223:
        return 'Carthage';
      case 6224:
        return 'Chua';
      case 6225:
        return 'Corrego Alegre';
      case 6226:
        return 'Cote d Ivoire';
      case 6227:
        return 'Deir ez Zor';
      case 6228:
        return 'Douala';
      case 6229:
        return 'Egypt 1907';
      case 6230:
        return 'European Datum 1950';
      case 6231:
        return 'European Datum 1987';
      case 6232:
        return 'Fahud';
      case 6233:
        return 'Gandajika 1970';
      case 6234:
        return 'Garoua';
      case 6235:
        return 'Guyane Francaise';
      case 6236:
        return 'Hu Tzu Shan';
      case 6237:
        return 'Hungarian Datum 1972';
      case 6238:
        return 'Indonesian Datum 1974';
      case 6239:
        return 'Indian 1954';
      case 6240:
        return 'Indian 1975';
      case 6241:
        return 'Jamaica 1875';
      case 6242:
        return 'Jamaica 1969';
      case 6243:
        return 'Kalianpur';
      case 6244:
        return 'Kandawala';
      case 6245:
        return 'Kertau';
      case 6246:
        return 'Kuwait Oil Company';
      case 6247:
        return 'La Canoa';
      case 6248:
        return 'Provisional S American Datum 1956';
      case 6249:
        return 'Lake';
      case 6250:
        return 'Leigon';
      case 6251:
        return 'Liberia 1964';
      case 6252:
        return 'Lome';
      case 6253:
        return 'Luzon 1911';
      case 6254:
        return 'Hito XVIII 1963';
      case 6255:
        return 'Herat North';
      case 6256:
        return 'Mahe 1971';
      case 6257:
        return 'Makassar';
      case 6258:
        return 'European Reference System 1989';
      case 6259:
        return 'Malongo 1987';
      case 6260:
        return 'Manoca';
      case 6261:
        return 'Merchich';
      case 6262:
        return 'Massawa';
      case 6263:
        return 'Minna';
      case 6264:
        return 'Mhast';
      case 6265:
        return 'Monte Mario';
      case 6266:
        return 'M poraloko';
      case 6267:
        return 'North American Datum 1927';
      case 6268:
        return 'NAD Michigan';
      case 6269:
        return 'North American Datum 1983';
      case 6270:
        return 'Nahrwan 1967';
      case 6271:
        return 'Naparima 1972';
      case 6272:
        return 'New Zealand Geodetic Datum 1949';
      case 6273:
        return 'NGO 1948';
      case 6274:
        return 'Datum 73';
      case 6275:
        return 'Nouvelle Triangulation Francaise';
      case 6276:
        return 'NSWC 9Z 2';
      case 6277:
        return 'OSGB 1936';
      case 6278:
        return 'OSGB 1970 SN';
      case 6279:
        return 'OS SN 1980';
      case 6280:
        return 'Padang 1884';
      case 6281:
        return 'Palestine 1923';
      case 6282:
        return 'Pointe Noire';
      case 6283:
        return 'Geocentric Datum of Australia 1994';
      case 6284:
        return 'Pulkovo 1942';
      case 6285:
        return 'Qatar';
      case 6286:
        return 'Qatar 1948';
      case 6287:
        return 'Qornoq';
      case 6288:
        return 'Loma Quintana';
      case 6289:
        return 'Amersfoort';
      case 6290:
        return 'RT38';
      case 6291:
        return 'South American Datum 1969';
      case 6292:
        return 'Sapper Hill 1943';
      case 6293:
        return 'Schwarzeck';
      case 6294:
        return 'Segora';
      case 6295:
        return 'Serindung';
      case 6296:
        return 'Sudan';
      case 6297:
        return 'Tananarive 1925';
      case 6298:
        return 'Timbalai 1948';
      case 6299:
        return 'TM65';
      case 6300:
        return 'TM75';
      case 6301:
        return 'Tokyo';
      case 6302:
        return 'Trinidad 1903';
      case 6303:
        return 'Trucial Coast 1948';
      case 6304:
        return 'Voirol 1875';
      case 6305:
        return 'Voirol Unifie 1960';
      case 6306:
        return 'Bern 1938';
      case 6307:
        return 'Nord Sahara 1959';
      case 6308:
        return 'Stockholm 1938';
      case 6309:
        return 'Yacare';
      case 6310:
        return 'Yoff';
      case 6311:
        return 'Zanderij';
      case 6312:
        return 'Militar Geographische Institut';
      case 6313:
        return 'Reseau National Belge 1972';
      case 6314:
        return 'Deutsche Hauptdreiecksnetz';
      case 6315:
        return 'Conakry 1905';
      case 6317:
        return 'Dealul Piscului 1970';
      case 6322:
        return 'WGS72';
      case 6324:
        return 'WGS72 Transit Broadcast Ephemeris';
      case 6326:
        return 'WGS84';
      case 6901:
        return 'Ancienne Triangulation Francaise';
      case 6902:
        return 'Nord de Guerre';
      case 32767:
        return 'User Defined';
      default:
        return 'Unknown ($value)';
    }
  }

  static String getGeogEllipsoidDescription(String valueString) {
    final value = int.tryParse(valueString);
    if (value == null) return valueString;
    switch (value) {
      case 7001:
        return 'Airy 1830';
      case 7002:
        return 'Airy Modified 1849';
      case 7003:
        return 'Australian National Spheroid';
      case 7004:
        return 'Bessel 1841';
      case 7005:
        return 'Bessel Modified';
      case 7006:
        return 'Bessel Namibia';
      case 7007:
        return 'Clarke 1858';
      case 7008:
        return 'Clarke 1866';
      case 7009:
        return 'Clarke 1866 Michigan';
      case 7010:
        return 'Clarke 1880 Benoit';
      case 7011:
        return 'Clarke 1880 IGN';
      case 7012:
        return 'Clarke 1880 RGS';
      case 7013:
        return 'Clarke 1880 Arc';
      case 7014:
        return 'Clarke 1880 SGA 1922';
      case 7015:
        return 'Everest 1830 1937 Adjustment';
      case 7016:
        return 'Everest 1830 1967 Definition';
      case 7017:
        return 'Everest 1830 1975 Definition';
      case 7018:
        return 'Everest 1830 Modified';
      case 7019:
        return 'GRS 1980';
      case 7020:
        return 'Helmert 1906';
      case 7021:
        return 'Indonesian National Spheroid';
      case 7022:
        return 'International 1924';
      case 7023:
        return 'International 1967';
      case 7024:
        return 'Krassowsky 1940';
      case 7025:
        return 'NWL 9D';
      case 7026:
        return 'NWL 10D';
      case 7027:
        return 'Plessis 1817';
      case 7028:
        return 'Struve 1860';
      case 7029:
        return 'War Office';
      case 7030:
        return 'WGS 84';
      case 7031:
        return 'GEM 10C';
      case 7032:
        return 'OSU86F';
      case 7033:
        return 'OSU91A';
      case 7034:
        return 'Clarke 1880';
      case 7035:
        return 'Sphere';
      case 32767:
        return 'User Defined';
      default:
        return 'Unknown ($value)';
    }
  }

  static String getProjCSTypeDescription(String valueString) {
    final value = int.tryParse(valueString);
    if (value == null) return valueString;
    switch (value) {
      case 2100:
        return 'GGRS87 Greek Grid';
      case 2176:
        return 'ETRS89 Poland CS2000 zone 5';
      case 2177:
        return 'ETRS89 Poland CS2000 zone 7';
      case 2178:
        return 'ETRS89 Poland CS2000 zone 8';
      case 2180:
        return 'ETRS89 Poland CS92';
      case 2204:
        return 'NAD27 Tennessee';
      case 2205:
        return 'NAD83 Kentucky North';
      case 2391:
        return 'KKJ Finland zone 1';
      case 2392:
        return 'KKJ Finland zone 2';
      case 2393:
        return 'KKJ Finland zone 3';
      case 2394:
        return 'KKJ Finland zone 4';
      case 2400:
        return 'RT90 2 5 gon W';
      case 2600:
        return 'Lietuvos Koordinoei Sistema 1994';
      case 3045:
        return 'ETRS89 UTM zone 33N';
      case 3053:
        return 'Hjorsey 1955 Lambert';
      case 3057:
        return 'ISN93 Lambert 1993';
      case 3300:
        return 'Estonian Coordinate System of 1992';
      case 3786:
        return 'Popular Visualisation CRS / Mercator';
      case 3857:
        return 'WGS 84 / Pseudo-Mercator';
      case 20137:
        return 'Adindan UTM zone 37N';
      case 20138:
        return 'Adindan UTM zone 38N';
      case 20248:
        return 'AGD66 AMG zone 48';
      case 20249:
        return 'AGD66 AMG zone 49';
      case 20250:
        return 'AGD66 AMG zone 50';
      case 20251:
        return 'AGD66 AMG zone 51';
      case 20252:
        return 'AGD66 AMG zone 52';
      case 20253:
        return 'AGD66 AMG zone 53';
      case 20254:
        return 'AGD66 AMG zone 54';
      case 20255:
        return 'AGD66 AMG zone 55';
      case 20256:
        return 'AGD66 AMG zone 56';
      case 20257:
        return 'AGD66 AMG zone 57';
      case 20258:
        return 'AGD66 AMG zone 58';
      case 20348:
        return 'AGD84 AMG zone 48';
      case 20349:
        return 'AGD84 AMG zone 49';
      case 20350:
        return 'AGD84 AMG zone 50';
      case 20351:
        return 'AGD84 AMG zone 51';
      case 20352:
        return 'AGD84 AMG zone 52';
      case 20353:
        return 'AGD84 AMG zone 53';
      case 20354:
        return 'AGD84 AMG zone 54';
      case 20355:
        return 'AGD84 AMG zone 55';
      case 20356:
        return 'AGD84 AMG zone 56';
      case 20357:
        return 'AGD84 AMG zone 57';
      case 20358:
        return 'AGD84 AMG zone 58';
      case 20437:
        return 'Ain el Abd UTM zone 37N';
      case 20438:
        return 'Ain el Abd UTM zone 38N';
      case 20439:
        return 'Ain el Abd UTM zone 39N';
      case 20499:
        return 'Ain el Abd Bahrain Grid';
      case 20538:
        return 'Afgooye UTM zone 38N';
      case 20539:
        return 'Afgooye UTM zone 39N';
      case 20700:
        return 'Lisbon Portuguese Grid';
      case 20822:
        return 'Aratu UTM zone 22S';
      case 20823:
        return 'Aratu UTM zone 23S';
      case 20824:
        return 'Aratu UTM zone 24S';
      case 20973:
        return 'Arc 1950 Lo13';
      case 20975:
        return 'Arc 1950 Lo15';
      case 20977:
        return 'Arc 1950 Lo17';
      case 20979:
        return 'Arc 1950 Lo19';
      case 20981:
        return 'Arc 1950 Lo21';
      case 20983:
        return 'Arc 1950 Lo23';
      case 20985:
        return 'Arc 1950 Lo25';
      case 20987:
        return 'Arc 1950 Lo27';
      case 20989:
        return 'Arc 1950 Lo29';
      case 20991:
        return 'Arc 1950 Lo31';
      case 20993:
        return 'Arc 1950 Lo33';
      case 20995:
        return 'Arc 1950 Lo35';
      case 21100:
        return 'Batavia NEIEZ';
      case 21148:
        return 'Batavia UTM zone 48S';
      case 21149:
        return 'Batavia UTM zone 49S';
      case 21150:
        return 'Batavia UTM zone 50S';
      case 21413:
        return 'Beijing Gauss zone 13';
      case 21414:
        return 'Beijing Gauss zone 14';
      case 21415:
        return 'Beijing Gauss zone 15';
      case 21416:
        return 'Beijing Gauss zone 16';
      case 21417:
        return 'Beijing Gauss zone 17';
      case 21418:
        return 'Beijing Gauss zone 18';
      case 21419:
        return 'Beijing Gauss zone 19';
      case 21420:
        return 'Beijing Gauss zone 20';
      case 21421:
        return 'Beijing Gauss zone 21';
      case 21422:
        return 'Beijing Gauss zone 22';
      case 21423:
        return 'Beijing Gauss zone 23';
      case 21473:
        return 'Beijing Gauss 13N';
      case 21474:
        return 'Beijing Gauss 14N';
      case 21475:
        return 'Beijing Gauss 15N';
      case 21476:
        return 'Beijing Gauss 16N';
      case 21477:
        return 'Beijing Gauss 17N';
      case 21478:
        return 'Beijing Gauss 18N';
      case 21479:
        return 'Beijing Gauss 19N';
      case 21480:
        return 'Beijing Gauss 20N';
      case 21481:
        return 'Beijing Gauss 21N';
      case 21482:
        return 'Beijing Gauss 22N';
      case 21483:
        return 'Beijing Gauss 23N';
      case 21500:
        return 'Belge Lambert 50';
      case 21790:
        return 'Bern 1898 Swiss Old';
      case 21817:
        return 'Bogota UTM zone 17N';
      case 21818:
        return 'Bogota UTM zone 18N';
      case 21891:
        return 'Bogota Colombia 3W';
      case 21892:
        return 'Bogota Colombia Bogota';
      case 21893:
        return 'Bogota Colombia 3E';
      case 21894:
        return 'Bogota Colombia 6E';
      case 22032:
        return 'Camacupa UTM 32S';
      case 22033:
        return 'Camacupa UTM 33S';
      case 22191:
        return 'C Inchauspe Argentina 1';
      case 22192:
        return 'C Inchauspe Argentina 2';
      case 22193:
        return 'C Inchauspe Argentina 3';
      case 22194:
        return 'C Inchauspe Argentina 4';
      case 22195:
        return 'C Inchauspe Argentina 5';
      case 22196:
        return 'C Inchauspe Argentina 6';
      case 22197:
        return 'C Inchauspe Argentina 7';
      case 22332:
        return 'Carthage UTM zone 32N';
      case 22391:
        return 'Carthage Nord Tunisie';
      case 22392:
        return 'Carthage Sud Tunisie';
      case 22523:
        return 'Corrego Alegre UTM 23S';
      case 22524:
        return 'Corrego Alegre UTM 24S';
      case 22832:
        return 'Douala UTM zone 32N';
      case 22992:
        return 'Egypt 1907 Red Belt';
      case 22993:
        return 'Egypt 1907 Purple Belt';
      case 22994:
        return 'Egypt 1907 Ext Purple';
      case 23028:
        return 'ED50 UTM zone 28N';
      case 23029:
        return 'ED50 UTM zone 29N';
      case 23030:
        return 'ED50 UTM zone 30N';
      case 23031:
        return 'ED50 UTM zone 31N';
      case 23032:
        return 'ED50 UTM zone 32N';
      case 23033:
        return 'ED50 UTM zone 33N';
      case 23034:
        return 'ED50 UTM zone 34N';
      case 23035:
        return 'ED50 UTM zone 35N';
      case 23036:
        return 'ED50 UTM zone 36N';
      case 23037:
        return 'ED50 UTM zone 37N';
      case 23038:
        return 'ED50 UTM zone 38N';
      case 23239:
        return 'Fahud UTM zone 39N';
      case 23240:
        return 'Fahud UTM zone 40N';
      case 23433:
        return 'Garoua UTM zone 33N';
      case 23700:
        return 'HD72 EOV';
      case 23846:
        return 'ID74 UTM zone 46N';
      case 23847:
        return 'ID74 UTM zone 47N';
      case 23848:
        return 'ID74 UTM zone 48N';
      case 23849:
        return 'ID74 UTM zone 49N';
      case 23850:
        return 'ID74 UTM zone 50N';
      case 23851:
        return 'ID74 UTM zone 51N';
      case 23852:
        return 'ID74 UTM zone 52N';
      case 23853:
        return 'ID74 UTM zone 53N';
      case 23886:
        return 'ID74 UTM zone 46S';
      case 23887:
        return 'ID74 UTM zone 47S';
      case 23888:
        return 'ID74 UTM zone 48S';
      case 23889:
        return 'ID74 UTM zone 49S';
      case 23890:
        return 'ID74 UTM zone 50S';
      case 23891:
        return 'ID74 UTM zone 51S';
      case 23892:
        return 'ID74 UTM zone 52S';
      case 23893:
        return 'ID74 UTM zone 53S';
      case 23894:
        return 'ID74 UTM zone 54S';
      case 23947:
        return 'Indian 1954 UTM 47N';
      case 23948:
        return 'Indian 1954 UTM 48N';
      case 24047:
        return 'Indian 1975 UTM 47N';
      case 24048:
        return 'Indian 1975 UTM 48N';
      case 24100:
        return 'Jamaica 1875 Old Grid';
      case 24200:
        return 'JAD69 Jamaica Grid';
      case 24370:
        return 'Kalianpur India 0';
      case 24371:
        return 'Kalianpur India I';
      case 24372:
        return 'Kalianpur India IIa';
      case 24373:
        return 'Kalianpur India IIIa';
      case 24374:
        return 'Kalianpur India IVa';
      case 24382:
        return 'Kalianpur India IIb';
      case 24383:
        return 'Kalianpur India IIIb';
      case 24384:
        return 'Kalianpur India IVb';
      case 24500:
        return 'Kertau Singapore Grid';
      case 24547:
        return 'Kertau UTM zone 47N';
      case 24548:
        return 'Kertau UTM zone 48N';
      case 24720:
        return 'La Canoa UTM zone 20N';
      case 24721:
        return 'La Canoa UTM zone 21N';
      case 24818:
        return 'PSAD56 UTM zone 18N';
      case 24819:
        return 'PSAD56 UTM zone 19N';
      case 24820:
        return 'PSAD56 UTM zone 20N';
      case 24821:
        return 'PSAD56 UTM zone 21N';
      case 24877:
        return 'PSAD56 UTM zone 17S';
      case 24878:
        return 'PSAD56 UTM zone 18S';
      case 24879:
        return 'PSAD56 UTM zone 19S';
      case 24880:
        return 'PSAD56 UTM zone 20S';
      case 24891:
        return 'PSAD56 Peru west zone';
      case 24892:
        return 'PSAD56 Peru central';
      case 24893:
        return 'PSAD56 Peru east zone';
      case 25000:
        return 'Leigon Ghana Grid';
      case 25231:
        return 'Lome UTM zone 31N';
      case 25391:
        return 'Luzon Philippines I';
      case 25392:
        return 'Luzon Philippines II';
      case 25393:
        return 'Luzon Philippines III';
      case 25394:
        return 'Luzon Philippines IV';
      case 25395:
        return 'Luzon Philippines V';
      case 25700:
        return 'Makassar NEIEZ';
      case 25932:
        return 'Malongo 1987 UTM 32S';
      case 26191:
        return 'Merchich Nord Maroc';
      case 26192:
        return 'Merchich Sud Maroc';
      case 26193:
        return 'Merchich Sahara';
      case 26237:
        return 'Massawa UTM zone 37N';
      case 26331:
        return 'Minna UTM zone 31N';
      case 26332:
        return 'Minna UTM zone 32N';
      case 26391:
        return 'Minna Nigeria West';
      case 26392:
        return 'Minna Nigeria Mid Belt';
      case 26393:
        return 'Minna Nigeria East';
      case 26432:
        return 'Mhast UTM zone 32S';
      case 26591:
        return 'Monte Mario Italy 1';
      case 26592:
        return 'Monte Mario Italy 2';
      case 26632:
        return 'M poraloko UTM 32N';
      case 26692:
        return 'M poraloko UTM 32S';
      case 26703:
        return 'NAD27 UTM zone 3N';
      case 26704:
        return 'NAD27 UTM zone 4N';
      case 26705:
        return 'NAD27 UTM zone 5N';
      case 26706:
        return 'NAD27 UTM zone 6N';
      case 26707:
        return 'NAD27 UTM zone 7N';
      case 26708:
        return 'NAD27 UTM zone 8N';
      case 26709:
        return 'NAD27 UTM zone 9N';
      case 26710:
        return 'NAD27 UTM zone 10N';
      case 26711:
        return 'NAD27 UTM zone 11N';
      case 26712:
        return 'NAD27 UTM zone 12N';
      case 26713:
        return 'NAD27 UTM zone 13N';
      case 26714:
        return 'NAD27 UTM zone 14N';
      case 26715:
        return 'NAD27 UTM zone 15N';
      case 26716:
        return 'NAD27 UTM zone 16N';
      case 26717:
        return 'NAD27 UTM zone 17N';
      case 26718:
        return 'NAD27 UTM zone 18N';
      case 26719:
        return 'NAD27 UTM zone 19N';
      case 26720:
        return 'NAD27 UTM zone 20N';
      case 26721:
        return 'NAD27 UTM zone 21N';
      case 26722:
        return 'NAD27 UTM zone 22N';
      case 26729:
        return 'NAD27 Alabama East';
      case 26730:
        return 'NAD27 Alabama West';
      case 26731:
        return 'NAD27 Alaska zone 1';
      case 26732:
        return 'NAD27 Alaska zone 2';
      case 26733:
        return 'NAD27 Alaska zone 3';
      case 26734:
        return 'NAD27 Alaska zone 4';
      case 26735:
        return 'NAD27 Alaska zone 5';
      case 26736:
        return 'NAD27 Alaska zone 6';
      case 26737:
        return 'NAD27 Alaska zone 7';
      case 26738:
        return 'NAD27 Alaska zone 8';
      case 26739:
        return 'NAD27 Alaska zone 9';
      case 26740:
        return 'NAD27 Alaska zone 10';
      case 26741:
        return 'NAD27 California I';
      case 26742:
        return 'NAD27 California II';
      case 26743:
        return 'NAD27 California III';
      case 26744:
        return 'NAD27 California IV';
      case 26745:
        return 'NAD27 California V';
      case 26746:
        return 'NAD27 California VI';
      case 26747:
        return 'NAD27 California VII';
      case 26748:
        return 'NAD27 Arizona East';
      case 26749:
        return 'NAD27 Arizona Central';
      case 26750:
        return 'NAD27 Arizona West';
      case 26751:
        return 'NAD27 Arkansas North';
      case 26752:
        return 'NAD27 Arkansas South';
      case 26753:
        return 'NAD27 Colorado North';
      case 26754:
        return 'NAD27 Colorado Central';
      case 26755:
        return 'NAD27 Colorado South';
      case 26756:
        return 'NAD27 Connecticut';
      case 26757:
        return 'NAD27 Delaware';
      case 26758:
        return 'NAD27 Florida East';
      case 26759:
        return 'NAD27 Florida West';
      case 26760:
        return 'NAD27 Florida North';
      case 26761:
        return 'NAD27 Hawaii zone 1';
      case 26762:
        return 'NAD27 Hawaii zone 2';
      case 26763:
        return 'NAD27 Hawaii zone 3';
      case 26764:
        return 'NAD27 Hawaii zone 4';
      case 26765:
        return 'NAD27 Hawaii zone 5';
      case 26766:
        return 'NAD27 Georgia East';
      case 26767:
        return 'NAD27 Georgia West';
      case 26768:
        return 'NAD27 Idaho East';
      case 26769:
        return 'NAD27 Idaho Central';
      case 26770:
        return 'NAD27 Idaho West';
      case 26771:
        return 'NAD27 Illinois East';
      case 26772:
        return 'NAD27 Illinois West';
      case 26773:
        return 'NAD27 Indiana East';
      case 26774:
        return 'NAD27 Indiana West';
      case 26775:
        return 'NAD27 Iowa North';
      case 26776:
        return 'NAD27 Iowa South';
      case 26777:
        return 'NAD27 Kansas North';
      case 26778:
        return 'NAD27 Kansas South';
      case 26779:
        return 'NAD27 Kentucky North';
      case 26780:
        return 'NAD27 Kentucky South';
      case 26781:
        return 'NAD27 Louisiana North';
      case 26782:
        return 'NAD27 Louisiana South';
      case 26783:
        return 'NAD27 Maine East';
      case 26784:
        return 'NAD27 Maine West';
      case 26785:
        return 'NAD27 Maryland';
      case 26786:
        return 'NAD27 Massachusetts';
      case 26787:
        return 'NAD27 Massachusetts Is';
      case 26788:
        return 'NAD27 Michigan North';
      case 26789:
        return 'NAD27 Michigan Central';
      case 26790:
        return 'NAD27 Michigan South';
      case 26791:
        return 'NAD27 Minnesota North';
      case 26792:
        return 'NAD27 Minnesota Cent';
      case 26793:
        return 'NAD27 Minnesota South';
      case 26794:
        return 'NAD27 Mississippi East';
      case 26795:
        return 'NAD27 Mississippi West';
      case 26796:
        return 'NAD27 Missouri East';
      case 26797:
        return 'NAD27 Missouri Central';
      case 26798:
        return 'NAD27 Missouri West';
      case 26801:
        return 'NAD Michigan Michigan East';
      case 26802:
        return 'NAD Michigan Michigan Old Central';
      case 26803:
        return 'NAD Michigan Michigan West';
      case 26903:
        return 'NAD83 UTM zone 3N';
      case 26904:
        return 'NAD83 UTM zone 4N';
      case 26905:
        return 'NAD83 UTM zone 5N';
      case 26906:
        return 'NAD83 UTM zone 6N';
      case 26907:
        return 'NAD83 UTM zone 7N';
      case 26908:
        return 'NAD83 UTM zone 8N';
      case 26909:
        return 'NAD83 UTM zone 9N';
      case 26910:
        return 'NAD83 UTM zone 10N';
      case 26911:
        return 'NAD83 UTM zone 11N';
      case 26912:
        return 'NAD83 UTM zone 12N';
      case 26913:
        return 'NAD83 UTM zone 13N';
      case 26914:
        return 'NAD83 UTM zone 14N';
      case 26915:
        return 'NAD83 UTM zone 15N';
      case 26916:
        return 'NAD83 UTM zone 16N';
      case 26917:
        return 'NAD83 UTM zone 17N';
      case 26918:
        return 'NAD83 UTM zone 18N';
      case 26919:
        return 'NAD83 UTM zone 19N';
      case 26920:
        return 'NAD83 UTM zone 20N';
      case 26921:
        return 'NAD83 UTM zone 21N';
      case 26922:
        return 'NAD83 UTM zone 22N';
      case 26923:
        return 'NAD83 UTM zone 23N';
      case 26929:
        return 'NAD83 Alabama East';
      case 26930:
        return 'NAD83 Alabama West';
      case 26931:
        return 'NAD83 Alaska zone 1';
      case 26932:
        return 'NAD83 Alaska zone 2';
      case 26933:
        return 'NAD83 Alaska zone 3';
      case 26934:
        return 'NAD83 Alaska zone 4';
      case 26935:
        return 'NAD83 Alaska zone 5';
      case 26936:
        return 'NAD83 Alaska zone 6';
      case 26937:
        return 'NAD83 Alaska zone 7';
      case 26938:
        return 'NAD83 Alaska zone 8';
      case 26939:
        return 'NAD83 Alaska zone 9';
      case 26940:
        return 'NAD83 Alaska zone 10';
      case 26941:
        return 'NAD83 California 1';
      case 26942:
        return 'NAD83 California 2';
      case 26943:
        return 'NAD83 California 3';
      case 26944:
        return 'NAD83 California 4';
      case 26945:
        return 'NAD83 California 5';
      case 26946:
        return 'NAD83 California 6';
      case 26948:
        return 'NAD83 Arizona East';
      case 26949:
        return 'NAD83 Arizona Central';
      case 26950:
        return 'NAD83 Arizona West';
      case 26951:
        return 'NAD83 Arkansas North';
      case 26952:
        return 'NAD83 Arkansas South';
      case 26953:
        return 'NAD83 Colorado North';
      case 26954:
        return 'NAD83 Colorado Central';
      case 26955:
        return 'NAD83 Colorado South';
      case 26956:
        return 'NAD83 Connecticut';
      case 26957:
        return 'NAD83 Delaware';
      case 26958:
        return 'NAD83 Florida East';
      case 26959:
        return 'NAD83 Florida West';
      case 26960:
        return 'NAD83 Florida North';
      case 26961:
        return 'NAD83 Hawaii zone 1';
      case 26962:
        return 'NAD83 Hawaii zone 2';
      case 26963:
        return 'NAD83 Hawaii zone 3';
      case 26964:
        return 'NAD83 Hawaii zone 4';
      case 26965:
        return 'NAD83 Hawaii zone 5';
      case 26966:
        return 'NAD83 Georgia East';
      case 26967:
        return 'NAD83 Georgia West';
      case 26968:
        return 'NAD83 Idaho East';
      case 26969:
        return 'NAD83 Idaho Central';
      case 26970:
        return 'NAD83 Idaho West';
      case 26971:
        return 'NAD83 Illinois East';
      case 26972:
        return 'NAD83 Illinois West';
      case 26973:
        return 'NAD83 Indiana East';
      case 26974:
        return 'NAD83 Indiana West';
      case 26975:
        return 'NAD83 Iowa North';
      case 26976:
        return 'NAD83 Iowa South';
      case 26977:
        return 'NAD83 Kansas North';
      case 26978:
        return 'NAD83 Kansas South';
      case 26979:
        return 'NAD83 Kentucky North';
      case 26980:
        return 'NAD83 Kentucky South';
      case 26981:
        return 'NAD83 Louisiana North';
      case 26982:
        return 'NAD83 Louisiana South';
      case 26983:
        return 'NAD83 Maine East';
      case 26984:
        return 'NAD83 Maine West';
      case 26985:
        return 'NAD83 Maryland';
      case 26986:
        return 'NAD83 Massachusetts';
      case 26987:
        return 'NAD83 Massachusetts Is';
      case 26988:
        return 'NAD83 Michigan North';
      case 26989:
        return 'NAD83 Michigan Central';
      case 26990:
        return 'NAD83 Michigan South';
      case 26991:
        return 'NAD83 Minnesota North';
      case 26992:
        return 'NAD83 Minnesota Cent';
      case 26993:
        return 'NAD83 Minnesota South';
      case 26994:
        return 'NAD83 Mississippi East';
      case 26995:
        return 'NAD83 Mississippi West';
      case 26996:
        return 'NAD83 Missouri East';
      case 26997:
        return 'NAD83 Missouri Central';
      case 26998:
        return 'NAD83 Missouri West';
      case 27038:
        return 'Nahrwan 1967 UTM 38N';
      case 27039:
        return 'Nahrwan 1967 UTM 39N';
      case 27040:
        return 'Nahrwan 1967 UTM 40N';
      case 27120:
        return 'Naparima UTM 20N';
      case 27200:
        return 'GD49 NZ Map Grid';
      case 27291:
        return 'GD49 North Island Grid';
      case 27292:
        return 'GD49 South Island Grid';
      case 27429:
        return 'Datum 73 UTM zone 29N';
      case 27500:
        return 'ATF Nord de Guerre';
      case 27581:
        return 'NTF France I';
      case 27582:
        return 'NTF France II';
      case 27583:
        return 'NTF France III';
      case 27591:
        return 'NTF Nord France';
      case 27592:
        return 'NTF Centre France';
      case 27593:
        return 'NTF Sud France';
      case 27700:
        return 'British National Grid';
      case 28232:
        return 'Point Noire UTM 32S';
      case 28348:
        return 'GDA94 MGA zone 48';
      case 28349:
        return 'GDA94 MGA zone 49';
      case 28350:
        return 'GDA94 MGA zone 50';
      case 28351:
        return 'GDA94 MGA zone 51';
      case 28352:
        return 'GDA94 MGA zone 52';
      case 28353:
        return 'GDA94 MGA zone 53';
      case 28354:
        return 'GDA94 MGA zone 54';
      case 28355:
        return 'GDA94 MGA zone 55';
      case 28356:
        return 'GDA94 MGA zone 56';
      case 28357:
        return 'GDA94 MGA zone 57';
      case 28358:
        return 'GDA94 MGA zone 58';
      case 28404:
        return 'Pulkovo Gauss zone 4';
      case 28405:
        return 'Pulkovo Gauss zone 5';
      case 28406:
        return 'Pulkovo Gauss zone 6';
      case 28407:
        return 'Pulkovo Gauss zone 7';
      case 28408:
        return 'Pulkovo Gauss zone 8';
      case 28409:
        return 'Pulkovo Gauss zone 9';
      case 28410:
        return 'Pulkovo Gauss zone 10';
      case 28411:
        return 'Pulkovo Gauss zone 11';
      case 28412:
        return 'Pulkovo Gauss zone 12';
      case 28413:
        return 'Pulkovo Gauss zone 13';
      case 28414:
        return 'Pulkovo Gauss zone 14';
      case 28415:
        return 'Pulkovo Gauss zone 15';
      case 28416:
        return 'Pulkovo Gauss zone 16';
      case 28417:
        return 'Pulkovo Gauss zone 17';
      case 28418:
        return 'Pulkovo Gauss zone 18';
      case 28419:
        return 'Pulkovo Gauss zone 19';
      case 28420:
        return 'Pulkovo Gauss zone 20';
      case 28421:
        return 'Pulkovo Gauss zone 21';
      case 28422:
        return 'Pulkovo Gauss zone 22';
      case 28423:
        return 'Pulkovo Gauss zone 23';
      case 28424:
        return 'Pulkovo Gauss zone 24';
      case 28425:
        return 'Pulkovo Gauss zone 25';
      case 28426:
        return 'Pulkovo Gauss zone 26';
      case 28427:
        return 'Pulkovo Gauss zone 27';
      case 28428:
        return 'Pulkovo Gauss zone 28';
      case 28429:
        return 'Pulkovo Gauss zone 29';
      case 28430:
        return 'Pulkovo Gauss zone 30';
      case 28431:
        return 'Pulkovo Gauss zone 31';
      case 28432:
        return 'Pulkovo Gauss zone 32';
      case 28464:
        return 'Pulkovo Gauss 4N';
      case 28465:
        return 'Pulkovo Gauss 5N';
      case 28466:
        return 'Pulkovo Gauss 6N';
      case 28467:
        return 'Pulkovo Gauss 7N';
      case 28468:
        return 'Pulkovo Gauss 8N';
      case 28469:
        return 'Pulkovo Gauss 9N';
      case 28470:
        return 'Pulkovo Gauss 10N';
      case 28471:
        return 'Pulkovo Gauss 11N';
      case 28472:
        return 'Pulkovo Gauss 12N';
      case 28473:
        return 'Pulkovo Gauss 13N';
      case 28474:
        return 'Pulkovo Gauss 14N';
      case 28475:
        return 'Pulkovo Gauss 15N';
      case 28476:
        return 'Pulkovo Gauss 16N';
      case 28477:
        return 'Pulkovo Gauss 17N';
      case 28478:
        return 'Pulkovo Gauss 18N';
      case 28479:
        return 'Pulkovo Gauss 19N';
      case 28480:
        return 'Pulkovo Gauss 20N';
      case 28481:
        return 'Pulkovo Gauss 21N';
      case 28482:
        return 'Pulkovo Gauss 22N';
      case 28483:
        return 'Pulkovo Gauss 23N';
      case 28484:
        return 'Pulkovo Gauss 24N';
      case 28485:
        return 'Pulkovo Gauss 25N';
      case 28486:
        return 'Pulkovo Gauss 26N';
      case 28487:
        return 'Pulkovo Gauss 27N';
      case 28488:
        return 'Pulkovo Gauss 28N';
      case 28489:
        return 'Pulkovo Gauss 29N';
      case 28490:
        return 'Pulkovo Gauss 30N';
      case 28491:
        return 'Pulkovo Gauss 31N';
      case 28492:
        return 'Pulkovo Gauss 32N';
      case 28600:
        return 'Qatar National Grid';
      case 28991:
        return 'RD Netherlands Old';
      case 28992:
        return 'RD Netherlands New';
      case 29118:
        return 'SAD69 UTM zone 18N';
      case 29119:
        return 'SAD69 UTM zone 19N';
      case 29120:
        return 'SAD69 UTM zone 20N';
      case 29121:
        return 'SAD69 UTM zone 21N';
      case 29122:
        return 'SAD69 UTM zone 22N';
      case 29177:
        return 'SAD69 UTM zone 17S';
      case 29178:
        return 'SAD69 UTM zone 18S';
      case 29179:
        return 'SAD69 UTM zone 19S';
      case 29180:
        return 'SAD69 UTM zone 20S';
      case 29181:
        return 'SAD69 UTM zone 21S';
      case 29182:
        return 'SAD69 UTM zone 22S';
      case 29183:
        return 'SAD69 UTM zone 23S';
      case 29184:
        return 'SAD69 UTM zone 24S';
      case 29185:
        return 'SAD69 UTM zone 25S';
      case 29220:
        return 'Sapper Hill UTM 20S';
      case 29221:
        return 'Sapper Hill UTM 21S';
      case 29333:
        return 'Schwarzeck UTM 33S';
      case 29635:
        return 'Sudan UTM zone 35N';
      case 29636:
        return 'Sudan UTM zone 36N';
      case 29700:
        return 'Tananarive Laborde';
      case 29738:
        return 'Tananarive UTM 38S';
      case 29739:
        return 'Tananarive UTM 39S';
      case 29800:
        return 'Timbalai 1948 Borneo';
      case 29849:
        return 'Timbalai 1948 UTM 49N';
      case 29850:
        return 'Timbalai 1948 UTM 50N';
      case 29900:
        return 'TM65 Irish Nat Grid';
      case 30200:
        return 'Trinidad 1903 Trinidad';
      case 30339:
        return 'TC 1948 UTM zone 39N';
      case 30340:
        return 'TC 1948 UTM zone 40N';
      case 30491:
        return 'Voirol N Algerie ancien';
      case 30492:
        return 'Voirol S Algerie ancien';
      case 30591:
        return 'Voirol Unifie N Algerie';
      case 30592:
        return 'Voirol Unifie S Algerie';
      case 30600:
        return 'Bern 1938 Swiss New';
      case 30729:
        return 'Nord Sahara UTM 29N';
      case 30730:
        return 'Nord Sahara UTM 30N';
      case 30731:
        return 'Nord Sahara UTM 31N';
      case 30732:
        return 'Nord Sahara UTM 32N';
      case 31028:
        return 'Yoff UTM zone 28N';
      case 31121:
        return 'Zanderij UTM zone 21N';
      case 31291:
        return 'MGI Austria West';
      case 31292:
        return 'MGI Austria Central';
      case 31293:
        return 'MGI Austria East';
      case 31300:
        return 'Belge Lambert 72';
      case 31491:
        return 'DHDN Germany zone 1';
      case 31492:
        return 'DHDN Germany zone 2';
      case 31493:
        return 'DHDN Germany zone 3';
      case 31494:
        return 'DHDN Germany zone 4';
      case 31495:
        return 'DHDN Germany zone 5';
      case 31700:
        return 'Dealul Piscului 1970 Stereo 70';
      case 32001:
        return 'NAD27 Montana North';
      case 32002:
        return 'NAD27 Montana Central';
      case 32003:
        return 'NAD27 Montana South';
      case 32005:
        return 'NAD27 Nebraska North';
      case 32006:
        return 'NAD27 Nebraska South';
      case 32007:
        return 'NAD27 Nevada East';
      case 32008:
        return 'NAD27 Nevada Central';
      case 32009:
        return 'NAD27 Nevada West';
      case 32010:
        return 'NAD27 New Hampshire';
      case 32011:
        return 'NAD27 New Jersey';
      case 32012:
        return 'NAD27 New Mexico East';
      case 32013:
        return 'NAD27 New Mexico Cent';
      case 32014:
        return 'NAD27 New Mexico West';
      case 32015:
        return 'NAD27 New York East';
      case 32016:
        return 'NAD27 New York Central';
      case 32017:
        return 'NAD27 New York West';
      case 32018:
        return 'NAD27 New York Long Is';
      case 32019:
        return 'NAD27 North Carolina';
      case 32020:
        return 'NAD27 North Dakota N';
      case 32021:
        return 'NAD27 North Dakota S';
      case 32022:
        return 'NAD27 Ohio North';
      case 32023:
        return 'NAD27 Ohio South';
      case 32024:
        return 'NAD27 Oklahoma North';
      case 32025:
        return 'NAD27 Oklahoma South';
      case 32026:
        return 'NAD27 Oregon North';
      case 32027:
        return 'NAD27 Oregon South';
      case 32028:
        return 'NAD27 Pennsylvania N';
      case 32029:
        return 'NAD27 Pennsylvania S';
      case 32030:
        return 'NAD27 Rhode Island';
      case 32031:
        return 'NAD27 South Carolina N';
      case 32033:
        return 'NAD27 South Carolina S';
      case 32034:
        return 'NAD27 South Dakota N';
      case 32035:
        return 'NAD27 South Dakota S';
      case 32036:
        return 'NAD27 Tennessee';
      case 32037:
        return 'NAD27 Texas North';
      case 32038:
        return 'NAD27 Texas North Cen';
      case 32039:
        return 'NAD27 Texas Central';
      case 32040:
        return 'NAD27 Texas South Cen';
      case 32041:
        return 'NAD27 Texas South';
      case 32042:
        return 'NAD27 Utah North';
      case 32043:
        return 'NAD27 Utah Central';
      case 32044:
        return 'NAD27 Utah South';
      case 32045:
        return 'NAD27 Vermont';
      case 32046:
        return 'NAD27 Virginia North';
      case 32047:
        return 'NAD27 Virginia South';
      case 32048:
        return 'NAD27 Washington North';
      case 32049:
        return 'NAD27 Washington South';
      case 32050:
        return 'NAD27 West Virginia N';
      case 32051:
        return 'NAD27 West Virginia S';
      case 32052:
        return 'NAD27 Wisconsin North';
      case 32053:
        return 'NAD27 Wisconsin Cen';
      case 32054:
        return 'NAD27 Wisconsin South';
      case 32055:
        return 'NAD27 Wyoming East';
      case 32056:
        return 'NAD27 Wyoming E Cen';
      case 32057:
        return 'NAD27 Wyoming W Cen';
      case 32058:
        return 'NAD27 Wyoming West';
      case 32059:
        return 'NAD27 Puerto Rico';
      case 32060:
        return 'NAD27 St Croix';
      case 32100:
        return 'NAD83 Montana';
      case 32104:
        return 'NAD83 Nebraska';
      case 32107:
        return 'NAD83 Nevada East';
      case 32108:
        return 'NAD83 Nevada Central';
      case 32109:
        return 'NAD83 Nevada West';
      case 32110:
        return 'NAD83 New Hampshire';
      case 32111:
        return 'NAD83 New Jersey';
      case 32112:
        return 'NAD83 New Mexico East';
      case 32113:
        return 'NAD83 New Mexico Cent';
      case 32114:
        return 'NAD83 New Mexico West';
      case 32115:
        return 'NAD83 New York East';
      case 32116:
        return 'NAD83 New York Central';
      case 32117:
        return 'NAD83 New York West';
      case 32118:
        return 'NAD83 New York Long Is';
      case 32119:
        return 'NAD83 North Carolina';
      case 32120:
        return 'NAD83 North Dakota N';
      case 32121:
        return 'NAD83 North Dakota S';
      case 32122:
        return 'NAD83 Ohio North';
      case 32123:
        return 'NAD83 Ohio South';
      case 32124:
        return 'NAD83 Oklahoma North';
      case 32125:
        return 'NAD83 Oklahoma South';
      case 32126:
        return 'NAD83 Oregon North';
      case 32127:
        return 'NAD83 Oregon South';
      case 32128:
        return 'NAD83 Pennsylvania N';
      case 32129:
        return 'NAD83 Pennsylvania S';
      case 32130:
        return 'NAD83 Rhode Island';
      case 32133:
        return 'NAD83 South Carolina';
      case 32134:
        return 'NAD83 South Dakota N';
      case 32135:
        return 'NAD83 South Dakota S';
      case 32136:
        return 'NAD83 Tennessee';
      case 32137:
        return 'NAD83 Texas North';
      case 32138:
        return 'NAD83 Texas North Cen';
      case 32139:
        return 'NAD83 Texas Central';
      case 32140:
        return 'NAD83 Texas South Cen';
      case 32141:
        return 'NAD83 Texas South';
      case 32142:
        return 'NAD83 Utah North';
      case 32143:
        return 'NAD83 Utah Central';
      case 32144:
        return 'NAD83 Utah South';
      case 32145:
        return 'NAD83 Vermont';
      case 32146:
        return 'NAD83 Virginia North';
      case 32147:
        return 'NAD83 Virginia South';
      case 32148:
        return 'NAD83 Washington North';
      case 32149:
        return 'NAD83 Washington South';
      case 32150:
        return 'NAD83 West Virginia N';
      case 32151:
        return 'NAD83 West Virginia S';
      case 32152:
        return 'NAD83 Wisconsin North';
      case 32153:
        return 'NAD83 Wisconsin Cen';
      case 32154:
        return 'NAD83 Wisconsin South';
      case 32155:
        return 'NAD83 Wyoming East';
      case 32156:
        return 'NAD83 Wyoming E Cen';
      case 32157:
        return 'NAD83 Wyoming W Cen';
      case 32158:
        return 'NAD83 Wyoming West';
      case 32161:
        return 'NAD83 Puerto Rico Virgin Is';
      case 32201:
        return 'WGS72 UTM zone 1N';
      case 32202:
        return 'WGS72 UTM zone 2N';
      case 32203:
        return 'WGS72 UTM zone 3N';
      case 32204:
        return 'WGS72 UTM zone 4N';
      case 32205:
        return 'WGS72 UTM zone 5N';
      case 32206:
        return 'WGS72 UTM zone 6N';
      case 32207:
        return 'WGS72 UTM zone 7N';
      case 32208:
        return 'WGS72 UTM zone 8N';
      case 32209:
        return 'WGS72 UTM zone 9N';
      case 32210:
        return 'WGS72 UTM zone 10N';
      case 32211:
        return 'WGS72 UTM zone 11N';
      case 32212:
        return 'WGS72 UTM zone 12N';
      case 32213:
        return 'WGS72 UTM zone 13N';
      case 32214:
        return 'WGS72 UTM zone 14N';
      case 32215:
        return 'WGS72 UTM zone 15N';
      case 32216:
        return 'WGS72 UTM zone 16N';
      case 32217:
        return 'WGS72 UTM zone 17N';
      case 32218:
        return 'WGS72 UTM zone 18N';
      case 32219:
        return 'WGS72 UTM zone 19N';
      case 32220:
        return 'WGS72 UTM zone 20N';
      case 32221:
        return 'WGS72 UTM zone 21N';
      case 32222:
        return 'WGS72 UTM zone 22N';
      case 32223:
        return 'WGS72 UTM zone 23N';
      case 32224:
        return 'WGS72 UTM zone 24N';
      case 32225:
        return 'WGS72 UTM zone 25N';
      case 32226:
        return 'WGS72 UTM zone 26N';
      case 32227:
        return 'WGS72 UTM zone 27N';
      case 32228:
        return 'WGS72 UTM zone 28N';
      case 32229:
        return 'WGS72 UTM zone 29N';
      case 32230:
        return 'WGS72 UTM zone 30N';
      case 32231:
        return 'WGS72 UTM zone 31N';
      case 32232:
        return 'WGS72 UTM zone 32N';
      case 32233:
        return 'WGS72 UTM zone 33N';
      case 32234:
        return 'WGS72 UTM zone 34N';
      case 32235:
        return 'WGS72 UTM zone 35N';
      case 32236:
        return 'WGS72 UTM zone 36N';
      case 32237:
        return 'WGS72 UTM zone 37N';
      case 32238:
        return 'WGS72 UTM zone 38N';
      case 32239:
        return 'WGS72 UTM zone 39N';
      case 32240:
        return 'WGS72 UTM zone 40N';
      case 32241:
        return 'WGS72 UTM zone 41N';
      case 32242:
        return 'WGS72 UTM zone 42N';
      case 32243:
        return 'WGS72 UTM zone 43N';
      case 32244:
        return 'WGS72 UTM zone 44N';
      case 32245:
        return 'WGS72 UTM zone 45N';
      case 32246:
        return 'WGS72 UTM zone 46N';
      case 32247:
        return 'WGS72 UTM zone 47N';
      case 32248:
        return 'WGS72 UTM zone 48N';
      case 32249:
        return 'WGS72 UTM zone 49N';
      case 32250:
        return 'WGS72 UTM zone 50N';
      case 32251:
        return 'WGS72 UTM zone 51N';
      case 32252:
        return 'WGS72 UTM zone 52N';
      case 32253:
        return 'WGS72 UTM zone 53N';
      case 32254:
        return 'WGS72 UTM zone 54N';
      case 32255:
        return 'WGS72 UTM zone 55N';
      case 32256:
        return 'WGS72 UTM zone 56N';
      case 32257:
        return 'WGS72 UTM zone 57N';
      case 32258:
        return 'WGS72 UTM zone 58N';
      case 32259:
        return 'WGS72 UTM zone 59N';
      case 32260:
        return 'WGS72 UTM zone 60N';
      case 32301:
        return 'WGS72 UTM zone 1S';
      case 32302:
        return 'WGS72 UTM zone 2S';
      case 32303:
        return 'WGS72 UTM zone 3S';
      case 32304:
        return 'WGS72 UTM zone 4S';
      case 32305:
        return 'WGS72 UTM zone 5S';
      case 32306:
        return 'WGS72 UTM zone 6S';
      case 32307:
        return 'WGS72 UTM zone 7S';
      case 32308:
        return 'WGS72 UTM zone 8S';
      case 32309:
        return 'WGS72 UTM zone 9S';
      case 32310:
        return 'WGS72 UTM zone 10S';
      case 32311:
        return 'WGS72 UTM zone 11S';
      case 32312:
        return 'WGS72 UTM zone 12S';
      case 32313:
        return 'WGS72 UTM zone 13S';
      case 32314:
        return 'WGS72 UTM zone 14S';
      case 32315:
        return 'WGS72 UTM zone 15S';
      case 32316:
        return 'WGS72 UTM zone 16S';
      case 32317:
        return 'WGS72 UTM zone 17S';
      case 32318:
        return 'WGS72 UTM zone 18S';
      case 32319:
        return 'WGS72 UTM zone 19S';
      case 32320:
        return 'WGS72 UTM zone 20S';
      case 32321:
        return 'WGS72 UTM zone 21S';
      case 32322:
        return 'WGS72 UTM zone 22S';
      case 32323:
        return 'WGS72 UTM zone 23S';
      case 32324:
        return 'WGS72 UTM zone 24S';
      case 32325:
        return 'WGS72 UTM zone 25S';
      case 32326:
        return 'WGS72 UTM zone 26S';
      case 32327:
        return 'WGS72 UTM zone 27S';
      case 32328:
        return 'WGS72 UTM zone 28S';
      case 32329:
        return 'WGS72 UTM zone 29S';
      case 32330:
        return 'WGS72 UTM zone 30S';
      case 32331:
        return 'WGS72 UTM zone 31S';
      case 32332:
        return 'WGS72 UTM zone 32S';
      case 32333:
        return 'WGS72 UTM zone 33S';
      case 32334:
        return 'WGS72 UTM zone 34S';
      case 32335:
        return 'WGS72 UTM zone 35S';
      case 32336:
        return 'WGS72 UTM zone 36S';
      case 32337:
        return 'WGS72 UTM zone 37S';
      case 32338:
        return 'WGS72 UTM zone 38S';
      case 32339:
        return 'WGS72 UTM zone 39S';
      case 32340:
        return 'WGS72 UTM zone 40S';
      case 32341:
        return 'WGS72 UTM zone 41S';
      case 32342:
        return 'WGS72 UTM zone 42S';
      case 32343:
        return 'WGS72 UTM zone 43S';
      case 32344:
        return 'WGS72 UTM zone 44S';
      case 32345:
        return 'WGS72 UTM zone 45S';
      case 32346:
        return 'WGS72 UTM zone 46S';
      case 32347:
        return 'WGS72 UTM zone 47S';
      case 32348:
        return 'WGS72 UTM zone 48S';
      case 32349:
        return 'WGS72 UTM zone 49S';
      case 32350:
        return 'WGS72 UTM zone 50S';
      case 32351:
        return 'WGS72 UTM zone 51S';
      case 32352:
        return 'WGS72 UTM zone 52S';
      case 32353:
        return 'WGS72 UTM zone 53S';
      case 32354:
        return 'WGS72 UTM zone 54S';
      case 32355:
        return 'WGS72 UTM zone 55S';
      case 32356:
        return 'WGS72 UTM zone 56S';
      case 32357:
        return 'WGS72 UTM zone 57S';
      case 32358:
        return 'WGS72 UTM zone 58S';
      case 32359:
        return 'WGS72 UTM zone 59S';
      case 32360:
        return 'WGS72 UTM zone 60S';
      case 32401:
        return 'WGS72BE UTM zone 1N';
      case 32402:
        return 'WGS72BE UTM zone 2N';
      case 32403:
        return 'WGS72BE UTM zone 3N';
      case 32404:
        return 'WGS72BE UTM zone 4N';
      case 32405:
        return 'WGS72BE UTM zone 5N';
      case 32406:
        return 'WGS72BE UTM zone 6N';
      case 32407:
        return 'WGS72BE UTM zone 7N';
      case 32408:
        return 'WGS72BE UTM zone 8N';
      case 32409:
        return 'WGS72BE UTM zone 9N';
      case 32410:
        return 'WGS72BE UTM zone 10N';
      case 32411:
        return 'WGS72BE UTM zone 11N';
      case 32412:
        return 'WGS72BE UTM zone 12N';
      case 32413:
        return 'WGS72BE UTM zone 13N';
      case 32414:
        return 'WGS72BE UTM zone 14N';
      case 32415:
        return 'WGS72BE UTM zone 15N';
      case 32416:
        return 'WGS72BE UTM zone 16N';
      case 32417:
        return 'WGS72BE UTM zone 17N';
      case 32418:
        return 'WGS72BE UTM zone 18N';
      case 32419:
        return 'WGS72BE UTM zone 19N';
      case 32420:
        return 'WGS72BE UTM zone 20N';
      case 32421:
        return 'WGS72BE UTM zone 21N';
      case 32422:
        return 'WGS72BE UTM zone 22N';
      case 32423:
        return 'WGS72BE UTM zone 23N';
      case 32424:
        return 'WGS72BE UTM zone 24N';
      case 32425:
        return 'WGS72BE UTM zone 25N';
      case 32426:
        return 'WGS72BE UTM zone 26N';
      case 32427:
        return 'WGS72BE UTM zone 27N';
      case 32428:
        return 'WGS72BE UTM zone 28N';
      case 32429:
        return 'WGS72BE UTM zone 29N';
      case 32430:
        return 'WGS72BE UTM zone 30N';
      case 32431:
        return 'WGS72BE UTM zone 31N';
      case 32432:
        return 'WGS72BE UTM zone 32N';
      case 32433:
        return 'WGS72BE UTM zone 33N';
      case 32434:
        return 'WGS72BE UTM zone 34N';
      case 32435:
        return 'WGS72BE UTM zone 35N';
      case 32436:
        return 'WGS72BE UTM zone 36N';
      case 32437:
        return 'WGS72BE UTM zone 37N';
      case 32438:
        return 'WGS72BE UTM zone 38N';
      case 32439:
        return 'WGS72BE UTM zone 39N';
      case 32440:
        return 'WGS72BE UTM zone 40N';
      case 32441:
        return 'WGS72BE UTM zone 41N';
      case 32442:
        return 'WGS72BE UTM zone 42N';
      case 32443:
        return 'WGS72BE UTM zone 43N';
      case 32444:
        return 'WGS72BE UTM zone 44N';
      case 32445:
        return 'WGS72BE UTM zone 45N';
      case 32446:
        return 'WGS72BE UTM zone 46N';
      case 32447:
        return 'WGS72BE UTM zone 47N';
      case 32448:
        return 'WGS72BE UTM zone 48N';
      case 32449:
        return 'WGS72BE UTM zone 49N';
      case 32450:
        return 'WGS72BE UTM zone 50N';
      case 32451:
        return 'WGS72BE UTM zone 51N';
      case 32452:
        return 'WGS72BE UTM zone 52N';
      case 32453:
        return 'WGS72BE UTM zone 53N';
      case 32454:
        return 'WGS72BE UTM zone 54N';
      case 32455:
        return 'WGS72BE UTM zone 55N';
      case 32456:
        return 'WGS72BE UTM zone 56N';
      case 32457:
        return 'WGS72BE UTM zone 57N';
      case 32458:
        return 'WGS72BE UTM zone 58N';
      case 32459:
        return 'WGS72BE UTM zone 59N';
      case 32460:
        return 'WGS72BE UTM zone 60N';
      case 32501:
        return 'WGS72BE UTM zone 1S';
      case 32502:
        return 'WGS72BE UTM zone 2S';
      case 32503:
        return 'WGS72BE UTM zone 3S';
      case 32504:
        return 'WGS72BE UTM zone 4S';
      case 32505:
        return 'WGS72BE UTM zone 5S';
      case 32506:
        return 'WGS72BE UTM zone 6S';
      case 32507:
        return 'WGS72BE UTM zone 7S';
      case 32508:
        return 'WGS72BE UTM zone 8S';
      case 32509:
        return 'WGS72BE UTM zone 9S';
      case 32510:
        return 'WGS72BE UTM zone 10S';
      case 32511:
        return 'WGS72BE UTM zone 11S';
      case 32512:
        return 'WGS72BE UTM zone 12S';
      case 32513:
        return 'WGS72BE UTM zone 13S';
      case 32514:
        return 'WGS72BE UTM zone 14S';
      case 32515:
        return 'WGS72BE UTM zone 15S';
      case 32516:
        return 'WGS72BE UTM zone 16S';
      case 32517:
        return 'WGS72BE UTM zone 17S';
      case 32518:
        return 'WGS72BE UTM zone 18S';
      case 32519:
        return 'WGS72BE UTM zone 19S';
      case 32520:
        return 'WGS72BE UTM zone 20S';
      case 32521:
        return 'WGS72BE UTM zone 21S';
      case 32522:
        return 'WGS72BE UTM zone 22S';
      case 32523:
        return 'WGS72BE UTM zone 23S';
      case 32524:
        return 'WGS72BE UTM zone 24S';
      case 32525:
        return 'WGS72BE UTM zone 25S';
      case 32526:
        return 'WGS72BE UTM zone 26S';
      case 32527:
        return 'WGS72BE UTM zone 27S';
      case 32528:
        return 'WGS72BE UTM zone 28S';
      case 32529:
        return 'WGS72BE UTM zone 29S';
      case 32530:
        return 'WGS72BE UTM zone 30S';
      case 32531:
        return 'WGS72BE UTM zone 31S';
      case 32532:
        return 'WGS72BE UTM zone 32S';
      case 32533:
        return 'WGS72BE UTM zone 33S';
      case 32534:
        return 'WGS72BE UTM zone 34S';
      case 32535:
        return 'WGS72BE UTM zone 35S';
      case 32536:
        return 'WGS72BE UTM zone 36S';
      case 32537:
        return 'WGS72BE UTM zone 37S';
      case 32538:
        return 'WGS72BE UTM zone 38S';
      case 32539:
        return 'WGS72BE UTM zone 39S';
      case 32540:
        return 'WGS72BE UTM zone 40S';
      case 32541:
        return 'WGS72BE UTM zone 41S';
      case 32542:
        return 'WGS72BE UTM zone 42S';
      case 32543:
        return 'WGS72BE UTM zone 43S';
      case 32544:
        return 'WGS72BE UTM zone 44S';
      case 32545:
        return 'WGS72BE UTM zone 45S';
      case 32546:
        return 'WGS72BE UTM zone 46S';
      case 32547:
        return 'WGS72BE UTM zone 47S';
      case 32548:
        return 'WGS72BE UTM zone 48S';
      case 32549:
        return 'WGS72BE UTM zone 49S';
      case 32550:
        return 'WGS72BE UTM zone 50S';
      case 32551:
        return 'WGS72BE UTM zone 51S';
      case 32552:
        return 'WGS72BE UTM zone 52S';
      case 32553:
        return 'WGS72BE UTM zone 53S';
      case 32554:
        return 'WGS72BE UTM zone 54S';
      case 32555:
        return 'WGS72BE UTM zone 55S';
      case 32556:
        return 'WGS72BE UTM zone 56S';
      case 32557:
        return 'WGS72BE UTM zone 57S';
      case 32558:
        return 'WGS72BE UTM zone 58S';
      case 32559:
        return 'WGS72BE UTM zone 59S';
      case 32560:
        return 'WGS72BE UTM zone 60S';
      case 32601:
        return 'WGS84 UTM zone 1N';
      case 32602:
        return 'WGS84 UTM zone 2N';
      case 32603:
        return 'WGS84 UTM zone 3N';
      case 32604:
        return 'WGS84 UTM zone 4N';
      case 32605:
        return 'WGS84 UTM zone 5N';
      case 32606:
        return 'WGS84 UTM zone 6N';
      case 32607:
        return 'WGS84 UTM zone 7N';
      case 32608:
        return 'WGS84 UTM zone 8N';
      case 32609:
        return 'WGS84 UTM zone 9N';
      case 32610:
        return 'WGS84 UTM zone 10N';
      case 32611:
        return 'WGS84 UTM zone 11N';
      case 32612:
        return 'WGS84 UTM zone 12N';
      case 32613:
        return 'WGS84 UTM zone 13N';
      case 32614:
        return 'WGS84 UTM zone 14N';
      case 32615:
        return 'WGS84 UTM zone 15N';
      case 32616:
        return 'WGS84 UTM zone 16N';
      case 32617:
        return 'WGS84 UTM zone 17N';
      case 32618:
        return 'WGS84 UTM zone 18N';
      case 32619:
        return 'WGS84 UTM zone 19N';
      case 32620:
        return 'WGS84 UTM zone 20N';
      case 32621:
        return 'WGS84 UTM zone 21N';
      case 32622:
        return 'WGS84 UTM zone 22N';
      case 32623:
        return 'WGS84 UTM zone 23N';
      case 32624:
        return 'WGS84 UTM zone 24N';
      case 32625:
        return 'WGS84 UTM zone 25N';
      case 32626:
        return 'WGS84 UTM zone 26N';
      case 32627:
        return 'WGS84 UTM zone 27N';
      case 32628:
        return 'WGS84 UTM zone 28N';
      case 32629:
        return 'WGS84 UTM zone 29N';
      case 32630:
        return 'WGS84 UTM zone 30N';
      case 32631:
        return 'WGS84 UTM zone 31N';
      case 32632:
        return 'WGS84 UTM zone 32N';
      case 32633:
        return 'WGS84 UTM zone 33N';
      case 32634:
        return 'WGS84 UTM zone 34N';
      case 32635:
        return 'WGS84 UTM zone 35N';
      case 32636:
        return 'WGS84 UTM zone 36N';
      case 32637:
        return 'WGS84 UTM zone 37N';
      case 32638:
        return 'WGS84 UTM zone 38N';
      case 32639:
        return 'WGS84 UTM zone 39N';
      case 32640:
        return 'WGS84 UTM zone 40N';
      case 32641:
        return 'WGS84 UTM zone 41N';
      case 32642:
        return 'WGS84 UTM zone 42N';
      case 32643:
        return 'WGS84 UTM zone 43N';
      case 32644:
        return 'WGS84 UTM zone 44N';
      case 32645:
        return 'WGS84 UTM zone 45N';
      case 32646:
        return 'WGS84 UTM zone 46N';
      case 32647:
        return 'WGS84 UTM zone 47N';
      case 32648:
        return 'WGS84 UTM zone 48N';
      case 32649:
        return 'WGS84 UTM zone 49N';
      case 32650:
        return 'WGS84 UTM zone 50N';
      case 32651:
        return 'WGS84 UTM zone 51N';
      case 32652:
        return 'WGS84 UTM zone 52N';
      case 32653:
        return 'WGS84 UTM zone 53N';
      case 32654:
        return 'WGS84 UTM zone 54N';
      case 32655:
        return 'WGS84 UTM zone 55N';
      case 32656:
        return 'WGS84 UTM zone 56N';
      case 32657:
        return 'WGS84 UTM zone 57N';
      case 32658:
        return 'WGS84 UTM zone 58N';
      case 32659:
        return 'WGS84 UTM zone 59N';
      case 32660:
        return 'WGS84 UTM zone 60N';
      case 32701:
        return 'WGS84 UTM zone 1S';
      case 32702:
        return 'WGS84 UTM zone 2S';
      case 32703:
        return 'WGS84 UTM zone 3S';
      case 32704:
        return 'WGS84 UTM zone 4S';
      case 32705:
        return 'WGS84 UTM zone 5S';
      case 32706:
        return 'WGS84 UTM zone 6S';
      case 32707:
        return 'WGS84 UTM zone 7S';
      case 32708:
        return 'WGS84 UTM zone 8S';
      case 32709:
        return 'WGS84 UTM zone 9S';
      case 32710:
        return 'WGS84 UTM zone 10S';
      case 32711:
        return 'WGS84 UTM zone 11S';
      case 32712:
        return 'WGS84 UTM zone 12S';
      case 32713:
        return 'WGS84 UTM zone 13S';
      case 32714:
        return 'WGS84 UTM zone 14S';
      case 32715:
        return 'WGS84 UTM zone 15S';
      case 32716:
        return 'WGS84 UTM zone 16S';
      case 32717:
        return 'WGS84 UTM zone 17S';
      case 32718:
        return 'WGS84 UTM zone 18S';
      case 32719:
        return 'WGS84 UTM zone 19S';
      case 32720:
        return 'WGS84 UTM zone 20S';
      case 32721:
        return 'WGS84 UTM zone 21S';
      case 32722:
        return 'WGS84 UTM zone 22S';
      case 32723:
        return 'WGS84 UTM zone 23S';
      case 32724:
        return 'WGS84 UTM zone 24S';
      case 32725:
        return 'WGS84 UTM zone 25S';
      case 32726:
        return 'WGS84 UTM zone 26S';
      case 32727:
        return 'WGS84 UTM zone 27S';
      case 32728:
        return 'WGS84 UTM zone 28S';
      case 32729:
        return 'WGS84 UTM zone 29S';
      case 32730:
        return 'WGS84 UTM zone 30S';
      case 32731:
        return 'WGS84 UTM zone 31S';
      case 32732:
        return 'WGS84 UTM zone 32S';
      case 32733:
        return 'WGS84 UTM zone 33S';
      case 32734:
        return 'WGS84 UTM zone 34S';
      case 32735:
        return 'WGS84 UTM zone 35S';
      case 32736:
        return 'WGS84 UTM zone 36S';
      case 32737:
        return 'WGS84 UTM zone 37S';
      case 32738:
        return 'WGS84 UTM zone 38S';
      case 32739:
        return 'WGS84 UTM zone 39S';
      case 32740:
        return 'WGS84 UTM zone 40S';
      case 32741:
        return 'WGS84 UTM zone 41S';
      case 32742:
        return 'WGS84 UTM zone 42S';
      case 32743:
        return 'WGS84 UTM zone 43S';
      case 32744:
        return 'WGS84 UTM zone 44S';
      case 32745:
        return 'WGS84 UTM zone 45S';
      case 32746:
        return 'WGS84 UTM zone 46S';
      case 32747:
        return 'WGS84 UTM zone 47S';
      case 32748:
        return 'WGS84 UTM zone 48S';
      case 32749:
        return 'WGS84 UTM zone 49S';
      case 32750:
        return 'WGS84 UTM zone 50S';
      case 32751:
        return 'WGS84 UTM zone 51S';
      case 32752:
        return 'WGS84 UTM zone 52S';
      case 32753:
        return 'WGS84 UTM zone 53S';
      case 32754:
        return 'WGS84 UTM zone 54S';
      case 32755:
        return 'WGS84 UTM zone 55S';
      case 32756:
        return 'WGS84 UTM zone 56S';
      case 32757:
        return 'WGS84 UTM zone 57S';
      case 32758:
        return 'WGS84 UTM zone 58S';
      case 32759:
        return 'WGS84 UTM zone 59S';
      case 32760:
        return 'WGS84 UTM zone 60S';
      case 32767:
        return 'User Defined';
      default:
        return 'Unknown ($value)';
    }
  }

  static String getProjectionDescription(String valueString) {
    final value = int.tryParse(valueString);
    if (value == null) return valueString;
    switch (value) {
      case 10101:
        return 'Alabama CS27 East';
      case 10102:
        return 'Alabama CS27 West';
      case 10131:
        return 'Alabama CS83 East';
      case 10132:
        return 'Alabama CS83 West';
      case 10201:
        return 'Arizona Coordinate System east';
      case 10202:
        return 'Arizona Coordinate System Central';
      case 10203:
        return 'Arizona Coordinate System west';
      case 10231:
        return 'Arizona CS83 east';
      case 10232:
        return 'Arizona CS83 Central';
      case 10233:
        return 'Arizona CS83 west';
      case 10301:
        return 'Arkansas CS27 North';
      case 10302:
        return 'Arkansas CS27 South';
      case 10331:
        return 'Arkansas CS83 North';
      case 10332:
        return 'Arkansas CS83 South';
      case 10401:
        return 'California CS27 I';
      case 10402:
        return 'California CS27 II';
      case 10403:
        return 'California CS27 III';
      case 10404:
        return 'California CS27 IV';
      case 10405:
        return 'California CS27 V';
      case 10406:
        return 'California CS27 VI';
      case 10407:
        return 'California CS27 VII';
      case 10431:
        return 'California CS83 1';
      case 10432:
        return 'California CS83 2';
      case 10433:
        return 'California CS83 3';
      case 10434:
        return 'California CS83 4';
      case 10435:
        return 'California CS83 5';
      case 10436:
        return 'California CS83 6';
      case 10501:
        return 'Colorado CS27 North';
      case 10502:
        return 'Colorado CS27 Central';
      case 10503:
        return 'Colorado CS27 South';
      case 10531:
        return 'Colorado CS83 North';
      case 10532:
        return 'Colorado CS83 Central';
      case 10533:
        return 'Colorado CS83 South';
      case 10600:
        return 'Connecticut CS27';
      case 10630:
        return 'Connecticut CS83';
      case 10700:
        return 'Delaware CS27';
      case 10730:
        return 'Delaware CS83';
      case 10901:
        return 'Florida CS27 East';
      case 10902:
        return 'Florida CS27 West';
      case 10903:
        return 'Florida CS27 North';
      case 10931:
        return 'Florida CS83 East';
      case 10932:
        return 'Florida CS83 West';
      case 10933:
        return 'Florida CS83 North';
      case 11001:
        return 'Georgia CS27 East';
      case 11002:
        return 'Georgia CS27 West';
      case 11031:
        return 'Georgia CS83 East';
      case 11032:
        return 'Georgia CS83 West';
      case 11101:
        return 'Idaho CS27 East';
      case 11102:
        return 'Idaho CS27 Central';
      case 11103:
        return 'Idaho CS27 West';
      case 11131:
        return 'Idaho CS83 East';
      case 11132:
        return 'Idaho CS83 Central';
      case 11133:
        return 'Idaho CS83 West';
      case 11201:
        return 'Illinois CS27 East';
      case 11202:
        return 'Illinois CS27 West';
      case 11231:
        return 'Illinois CS83 East';
      case 11232:
        return 'Illinois CS83 West';
      case 11301:
        return 'Indiana CS27 East';
      case 11302:
        return 'Indiana CS27 West';
      case 11331:
        return 'Indiana CS83 East';
      case 11332:
        return 'Indiana CS83 West';
      case 11401:
        return 'Iowa CS27 North';
      case 11402:
        return 'Iowa CS27 South';
      case 11431:
        return 'Iowa CS83 North';
      case 11432:
        return 'Iowa CS83 South';
      case 11501:
        return 'Kansas CS27 North';
      case 11502:
        return 'Kansas CS27 South';
      case 11531:
        return 'Kansas CS83 North';
      case 11532:
        return 'Kansas CS83 South';
      case 11601:
        return 'Kentucky CS27 North';
      case 11602:
        return 'Kentucky CS27 South';
      case 11631:
        return 'Kentucky CS83 North';
      case 11632:
        return 'Kentucky CS83 South';
      case 11701:
        return 'Louisiana CS27 North';
      case 11702:
        return 'Louisiana CS27 South';
      case 11731:
        return 'Louisiana CS83 North';
      case 11732:
        return 'Louisiana CS83 South';
      case 11801:
        return 'Maine CS27 East';
      case 11802:
        return 'Maine CS27 West';
      case 11831:
        return 'Maine CS83 East';
      case 11832:
        return 'Maine CS83 West';
      case 11900:
        return 'Maryland CS27';
      case 11930:
        return 'Maryland CS83';
      case 12001:
        return 'Massachusetts CS27 Mainland';
      case 12002:
        return 'Massachusetts CS27 Island';
      case 12031:
        return 'Massachusetts CS83 Mainland';
      case 12032:
        return 'Massachusetts CS83 Island';
      case 12101:
        return 'Michigan State Plane East';
      case 12102:
        return 'Michigan State Plane Old Central';
      case 12103:
        return 'Michigan State Plane West';
      case 12111:
        return 'Michigan CS27 North';
      case 12112:
        return 'Michigan CS27 Central';
      case 12113:
        return 'Michigan CS27 South';
      case 12141:
        return 'Michigan CS83 North';
      case 12142:
        return 'Michigan CS83 Central';
      case 12143:
        return 'Michigan CS83 South';
      case 12201:
        return 'Minnesota CS27 North';
      case 12202:
        return 'Minnesota CS27 Central';
      case 12203:
        return 'Minnesota CS27 South';
      case 12231:
        return 'Minnesota CS83 North';
      case 12232:
        return 'Minnesota CS83 Central';
      case 12233:
        return 'Minnesota CS83 South';
      case 12301:
        return 'Mississippi CS27 East';
      case 12302:
        return 'Mississippi CS27 West';
      case 12331:
        return 'Mississippi CS83 East';
      case 12332:
        return 'Mississippi CS83 West';
      case 12401:
        return 'Missouri CS27 East';
      case 12402:
        return 'Missouri CS27 Central';
      case 12403:
        return 'Missouri CS27 West';
      case 12431:
        return 'Missouri CS83 East';
      case 12432:
        return 'Missouri CS83 Central';
      case 12433:
        return 'Missouri CS83 West';
      case 12501:
        return 'Montana CS27 North';
      case 12502:
        return 'Montana CS27 Central';
      case 12503:
        return 'Montana CS27 South';
      case 12530:
        return 'Montana CS83';
      case 12601:
        return 'Nebraska CS27 North';
      case 12602:
        return 'Nebraska CS27 South';
      case 12630:
        return 'Nebraska CS83';
      case 12701:
        return 'Nevada CS27 East';
      case 12702:
        return 'Nevada CS27 Central';
      case 12703:
        return 'Nevada CS27 West';
      case 12731:
        return 'Nevada CS83 East';
      case 12732:
        return 'Nevada CS83 Central';
      case 12733:
        return 'Nevada CS83 West';
      case 12800:
        return 'New Hampshire CS27';
      case 12830:
        return 'New Hampshire CS83';
      case 12900:
        return 'New Jersey CS27';
      case 12930:
        return 'New Jersey CS83';
      case 13001:
        return 'New Mexico CS27 East';
      case 13002:
        return 'New Mexico CS27 Central';
      case 13003:
        return 'New Mexico CS27 West';
      case 13031:
        return 'New Mexico CS83 East';
      case 13032:
        return 'New Mexico CS83 Central';
      case 13033:
        return 'New Mexico CS83 West';
      case 13101:
        return 'New York CS27 East';
      case 13102:
        return 'New York CS27 Central';
      case 13103:
        return 'New York CS27 West';
      case 13104:
        return 'New York CS27 Long Island';
      case 13131:
        return 'New York CS83 East';
      case 13132:
        return 'New York CS83 Central';
      case 13133:
        return 'New York CS83 West';
      case 13134:
        return 'New York CS83 Long Island';
      case 13200:
        return 'North Carolina CS27';
      case 13230:
        return 'North Carolina CS83';
      case 13301:
        return 'North Dakota CS27 North';
      case 13302:
        return 'North Dakota CS27 South';
      case 13331:
        return 'North Dakota CS83 North';
      case 13332:
        return 'North Dakota CS83 South';
      case 13401:
        return 'Ohio CS27 North';
      case 13402:
        return 'Ohio CS27 South';
      case 13431:
        return 'Ohio CS83 North';
      case 13432:
        return 'Ohio CS83 South';
      case 13501:
        return 'Oklahoma CS27 North';
      case 13502:
        return 'Oklahoma CS27 South';
      case 13531:
        return 'Oklahoma CS83 North';
      case 13532:
        return 'Oklahoma CS83 South';
      case 13601:
        return 'Oregon CS27 North';
      case 13602:
        return 'Oregon CS27 South';
      case 13631:
        return 'Oregon CS83 North';
      case 13632:
        return 'Oregon CS83 South';
      case 13701:
        return 'Pennsylvania CS27 North';
      case 13702:
        return 'Pennsylvania CS27 South';
      case 13731:
        return 'Pennsylvania CS83 North';
      case 13732:
        return 'Pennsylvania CS83 South';
      case 13800:
        return 'Rhode Island CS27';
      case 13830:
        return 'Rhode Island CS83';
      case 13901:
        return 'South Carolina CS27 North';
      case 13902:
        return 'South Carolina CS27 South';
      case 13930:
        return 'South Carolina CS83';
      case 14001:
        return 'South Dakota CS27 North';
      case 14002:
        return 'South Dakota CS27 South';
      case 14031:
        return 'South Dakota CS83 North';
      case 14032:
        return 'South Dakota CS83 South';
      case 14100:
        return 'Tennessee CS27';
      case 14130:
        return 'Tennessee CS83';
      case 14201:
        return 'Texas CS27 North';
      case 14202:
        return 'Texas CS27 North Central';
      case 14203:
        return 'Texas CS27 Central';
      case 14204:
        return 'Texas CS27 South Central';
      case 14205:
        return 'Texas CS27 South';
      case 14231:
        return 'Texas CS83 North';
      case 14232:
        return 'Texas CS83 North Central';
      case 14233:
        return 'Texas CS83 Central';
      case 14234:
        return 'Texas CS83 South Central';
      case 14235:
        return 'Texas CS83 South';
      case 14301:
        return 'Utah CS27 North';
      case 14302:
        return 'Utah CS27 Central';
      case 14303:
        return 'Utah CS27 South';
      case 14331:
        return 'Utah CS83 North';
      case 14332:
        return 'Utah CS83 Central';
      case 14333:
        return 'Utah CS83 South';
      case 14400:
        return 'Vermont CS27';
      case 14430:
        return 'Vermont CS83';
      case 14501:
        return 'Virginia CS27 North';
      case 14502:
        return 'Virginia CS27 South';
      case 14531:
        return 'Virginia CS83 North';
      case 14532:
        return 'Virginia CS83 South';
      case 14601:
        return 'Washington CS27 North';
      case 14602:
        return 'Washington CS27 South';
      case 14631:
        return 'Washington CS83 North';
      case 14632:
        return 'Washington CS83 South';
      case 14701:
        return 'West Virginia CS27 North';
      case 14702:
        return 'West Virginia CS27 South';
      case 14731:
        return 'West Virginia CS83 North';
      case 14732:
        return 'West Virginia CS83 South';
      case 14801:
        return 'Wisconsin CS27 North';
      case 14802:
        return 'Wisconsin CS27 Central';
      case 14803:
        return 'Wisconsin CS27 South';
      case 14831:
        return 'Wisconsin CS83 North';
      case 14832:
        return 'Wisconsin CS83 Central';
      case 14833:
        return 'Wisconsin CS83 South';
      case 14901:
        return 'Wyoming CS27 East';
      case 14902:
        return 'Wyoming CS27 East Central';
      case 14903:
        return 'Wyoming CS27 West Central';
      case 14904:
        return 'Wyoming CS27 West';
      case 14931:
        return 'Wyoming CS83 East';
      case 14932:
        return 'Wyoming CS83 East Central';
      case 14933:
        return 'Wyoming CS83 West Central';
      case 14934:
        return 'Wyoming CS83 West';
      case 15001:
        return 'Alaska CS27 1';
      case 15002:
        return 'Alaska CS27 2';
      case 15003:
        return 'Alaska CS27 3';
      case 15004:
        return 'Alaska CS27 4';
      case 15005:
        return 'Alaska CS27 5';
      case 15006:
        return 'Alaska CS27 6';
      case 15007:
        return 'Alaska CS27 7';
      case 15008:
        return 'Alaska CS27 8';
      case 15009:
        return 'Alaska CS27 9';
      case 15010:
        return 'Alaska CS27 10';
      case 15031:
        return 'Alaska CS83 1';
      case 15032:
        return 'Alaska CS83 2';
      case 15033:
        return 'Alaska CS83 3';
      case 15034:
        return 'Alaska CS83 4';
      case 15035:
        return 'Alaska CS83 5';
      case 15036:
        return 'Alaska CS83 6';
      case 15037:
        return 'Alaska CS83 7';
      case 15038:
        return 'Alaska CS83 8';
      case 15039:
        return 'Alaska CS83 9';
      case 15040:
        return 'Alaska CS83 10';
      case 15101:
        return 'Hawaii CS27 1';
      case 15102:
        return 'Hawaii CS27 2';
      case 15103:
        return 'Hawaii CS27 3';
      case 15104:
        return 'Hawaii CS27 4';
      case 15105:
        return 'Hawaii CS27 5';
      case 15131:
        return 'Hawaii CS83 1';
      case 15132:
        return 'Hawaii CS83 2';
      case 15133:
        return 'Hawaii CS83 3';
      case 15134:
        return 'Hawaii CS83 4';
      case 15135:
        return 'Hawaii CS83 5';
      case 15201:
        return 'Puerto Rico CS27';
      case 15202:
        return 'St Croix';
      case 15230:
        return 'Puerto Rico Virgin Is';
      case 15302:
        return 'Kentucky CS27';
      case 15303:
        return 'Kentucky CS83 North';
      case 15914:
        return 'BLM 14N feet';
      case 15915:
        return 'BLM 15N feet';
      case 15916:
        return 'BLM 16N feet';
      case 15917:
        return 'BLM 17N feet';
      case 16001:
        return 'UTM zone 1N';
      case 16002:
        return 'UTM zone 2N';
      case 16003:
        return 'UTM zone 3N';
      case 16004:
        return 'UTM zone 4N';
      case 16005:
        return 'UTM zone 5N';
      case 16006:
        return 'UTM zone 6N';
      case 16007:
        return 'UTM zone 7N';
      case 16008:
        return 'UTM zone 8N';
      case 16009:
        return 'UTM zone 9N';
      case 16010:
        return 'UTM zone 10N';
      case 16011:
        return 'UTM zone 11N';
      case 16012:
        return 'UTM zone 12N';
      case 16013:
        return 'UTM zone 13N';
      case 16014:
        return 'UTM zone 14N';
      case 16015:
        return 'UTM zone 15N';
      case 16016:
        return 'UTM zone 16N';
      case 16017:
        return 'UTM zone 17N';
      case 16018:
        return 'UTM zone 18N';
      case 16019:
        return 'UTM zone 19N';
      case 16020:
        return 'UTM zone 20N';
      case 16021:
        return 'UTM zone 21N';
      case 16022:
        return 'UTM zone 22N';
      case 16023:
        return 'UTM zone 23N';
      case 16024:
        return 'UTM zone 24N';
      case 16025:
        return 'UTM zone 25N';
      case 16026:
        return 'UTM zone 26N';
      case 16027:
        return 'UTM zone 27N';
      case 16028:
        return 'UTM zone 28N';
      case 16029:
        return 'UTM zone 29N';
      case 16030:
        return 'UTM zone 30N';
      case 16031:
        return 'UTM zone 31N';
      case 16032:
        return 'UTM zone 32N';
      case 16033:
        return 'UTM zone 33N';
      case 16034:
        return 'UTM zone 34N';
      case 16035:
        return 'UTM zone 35N';
      case 16036:
        return 'UTM zone 36N';
      case 16037:
        return 'UTM zone 37N';
      case 16038:
        return 'UTM zone 38N';
      case 16039:
        return 'UTM zone 39N';
      case 16040:
        return 'UTM zone 40N';
      case 16041:
        return 'UTM zone 41N';
      case 16042:
        return 'UTM zone 42N';
      case 16043:
        return 'UTM zone 43N';
      case 16044:
        return 'UTM zone 44N';
      case 16045:
        return 'UTM zone 45N';
      case 16046:
        return 'UTM zone 46N';
      case 16047:
        return 'UTM zone 47N';
      case 16048:
        return 'UTM zone 48N';
      case 16049:
        return 'UTM zone 49N';
      case 16050:
        return 'UTM zone 50N';
      case 16051:
        return 'UTM zone 51N';
      case 16052:
        return 'UTM zone 52N';
      case 16053:
        return 'UTM zone 53N';
      case 16054:
        return 'UTM zone 54N';
      case 16055:
        return 'UTM zone 55N';
      case 16056:
        return 'UTM zone 56N';
      case 16057:
        return 'UTM zone 57N';
      case 16058:
        return 'UTM zone 58N';
      case 16059:
        return 'UTM zone 59N';
      case 16060:
        return 'UTM zone 60N';
      case 16101:
        return 'UTM zone 1S';
      case 16102:
        return 'UTM zone 2S';
      case 16103:
        return 'UTM zone 3S';
      case 16104:
        return 'UTM zone 4S';
      case 16105:
        return 'UTM zone 5S';
      case 16106:
        return 'UTM zone 6S';
      case 16107:
        return 'UTM zone 7S';
      case 16108:
        return 'UTM zone 8S';
      case 16109:
        return 'UTM zone 9S';
      case 16110:
        return 'UTM zone 10S';
      case 16111:
        return 'UTM zone 11S';
      case 16112:
        return 'UTM zone 12S';
      case 16113:
        return 'UTM zone 13S';
      case 16114:
        return 'UTM zone 14S';
      case 16115:
        return 'UTM zone 15S';
      case 16116:
        return 'UTM zone 16S';
      case 16117:
        return 'UTM zone 17S';
      case 16118:
        return 'UTM zone 18S';
      case 16119:
        return 'UTM zone 19S';
      case 16120:
        return 'UTM zone 20S';
      case 16121:
        return 'UTM zone 21S';
      case 16122:
        return 'UTM zone 22S';
      case 16123:
        return 'UTM zone 23S';
      case 16124:
        return 'UTM zone 24S';
      case 16125:
        return 'UTM zone 25S';
      case 16126:
        return 'UTM zone 26S';
      case 16127:
        return 'UTM zone 27S';
      case 16128:
        return 'UTM zone 28S';
      case 16129:
        return 'UTM zone 29S';
      case 16130:
        return 'UTM zone 30S';
      case 16131:
        return 'UTM zone 31S';
      case 16132:
        return 'UTM zone 32S';
      case 16133:
        return 'UTM zone 33S';
      case 16134:
        return 'UTM zone 34S';
      case 16135:
        return 'UTM zone 35S';
      case 16136:
        return 'UTM zone 36S';
      case 16137:
        return 'UTM zone 37S';
      case 16138:
        return 'UTM zone 38S';
      case 16139:
        return 'UTM zone 39S';
      case 16140:
        return 'UTM zone 40S';
      case 16141:
        return 'UTM zone 41S';
      case 16142:
        return 'UTM zone 42S';
      case 16143:
        return 'UTM zone 43S';
      case 16144:
        return 'UTM zone 44S';
      case 16145:
        return 'UTM zone 45S';
      case 16146:
        return 'UTM zone 46S';
      case 16147:
        return 'UTM zone 47S';
      case 16148:
        return 'UTM zone 48S';
      case 16149:
        return 'UTM zone 49S';
      case 16150:
        return 'UTM zone 50S';
      case 16151:
        return 'UTM zone 51S';
      case 16152:
        return 'UTM zone 52S';
      case 16153:
        return 'UTM zone 53S';
      case 16154:
        return 'UTM zone 54S';
      case 16155:
        return 'UTM zone 55S';
      case 16156:
        return 'UTM zone 56S';
      case 16157:
        return 'UTM zone 57S';
      case 16158:
        return 'UTM zone 58S';
      case 16159:
        return 'UTM zone 59S';
      case 16160:
        return 'UTM zone 60S';
      case 16200:
        return 'Gauss Kruger zone 0';
      case 16201:
        return 'Gauss Kruger zone 1';
      case 16202:
        return 'Gauss Kruger zone 2';
      case 16203:
        return 'Gauss Kruger zone 3';
      case 16204:
        return 'Gauss Kruger zone 4';
      case 16205:
        return 'Gauss Kruger zone 5';
      case 17348:
        return 'Map Grid of Australia 48';
      case 17349:
        return 'Map Grid of Australia 49';
      case 17350:
        return 'Map Grid of Australia 50';
      case 17351:
        return 'Map Grid of Australia 51';
      case 17352:
        return 'Map Grid of Australia 52';
      case 17353:
        return 'Map Grid of Australia 53';
      case 17354:
        return 'Map Grid of Australia 54';
      case 17355:
        return 'Map Grid of Australia 55';
      case 17356:
        return 'Map Grid of Australia 56';
      case 17357:
        return 'Map Grid of Australia 57';
      case 17358:
        return 'Map Grid of Australia 58';
      case 17448:
        return 'Australian Map Grid 48';
      case 17449:
        return 'Australian Map Grid 49';
      case 17450:
        return 'Australian Map Grid 50';
      case 17451:
        return 'Australian Map Grid 51';
      case 17452:
        return 'Australian Map Grid 52';
      case 17453:
        return 'Australian Map Grid 53';
      case 17454:
        return 'Australian Map Grid 54';
      case 17455:
        return 'Australian Map Grid 55';
      case 17456:
        return 'Australian Map Grid 56';
      case 17457:
        return 'Australian Map Grid 57';
      case 17458:
        return 'Australian Map Grid 58';
      case 18031:
        return 'Argentina 1';
      case 18032:
        return 'Argentina 2';
      case 18033:
        return 'Argentina 3';
      case 18034:
        return 'Argentina 4';
      case 18035:
        return 'Argentina 5';
      case 18036:
        return 'Argentina 6';
      case 18037:
        return 'Argentina 7';
      case 18051:
        return 'Colombia 3W';
      case 18052:
        return 'Colombia Bogota';
      case 18053:
        return 'Colombia 3E';
      case 18054:
        return 'Colombia 6E';
      case 18072:
        return 'Egypt Red Belt';
      case 18073:
        return 'Egypt Purple Belt';
      case 18074:
        return 'Extended Purple Belt';
      case 18141:
        return 'New Zealand North Island Nat Grid';
      case 18142:
        return 'New Zealand South Island Nat Grid';
      case 19900:
        return 'Bahrain Grid';
      case 19905:
        return 'Netherlands E Indies Equatorial';
      case 19912:
        return 'RSO Borneo';
      case 19926:
        return 'Stereo 70';
      case 32767:
        return 'User Defined';
      default:
        return 'Unknown ($value)';
    }
  }

  static String getProjCoordinateTransformDescription(String valueString) {
    final value = int.tryParse(valueString);
    if (value == null) return valueString;
    switch (value) {
      case 1:
        return 'Transverse Mercator';
      case 2:
        return 'Transverse Mercator Modified Alaska';
      case 3:
        return 'Oblique Mercator';
      case 4:
        return 'Oblique Mercator Laborde';
      case 5:
        return 'Oblique Mercator Rosenmund';
      case 6:
        return 'Oblique Mercator Spherical';
      case 7:
        return 'Mercator';
      case 8:
        return 'Lambert Conf Conic 2SP';
      case 9:
        return 'Lambert Conf Conic 1SP';
      case 10:
        return 'Lambert Azim Equal Area';
      case 11:
        return 'Albers Equal Area';
      case 12:
        return 'Azimuthal Equidistant';
      case 13:
        return 'Equidistant Conic';
      case 14:
        return 'Stereographic';
      case 15:
        return 'Polar Stereographic';
      case 16:
        return 'Oblique Stereographic';
      case 17:
        return 'Equirectangular';
      case 18:
        return 'Cassini Soldner';
      case 19:
        return 'Gnomonic';
      case 20:
        return 'Miller Cylindrical';
      case 21:
        return 'Orthographic';
      case 22:
        return 'Polyconic';
      case 23:
        return 'Robinson';
      case 24:
        return 'Sinusoidal';
      case 25:
        return 'VanDerGrinten';
      case 26:
        return 'New Zealand Map Grid';
      case 27:
        return 'Transverse Mercator South Orientated';
      case 28:
        return 'Cylindrical Equal Area';
      case 32767:
        return 'User Defined';
      default:
        return 'Unknown ($value)';
    }
  }

  static String getGeoTiffUnitsDescription(String valueString) {
    final value = int.tryParse(valueString);
    if (value == null) return valueString;
    switch (value) {
      case 9001:
        return 'Linear Meter';
      case 9002:
        return 'Linear Foot';
      case 9003:
        return 'Linear Foot US Survey';
      case 9004:
        return 'Linear Foot Modified American';
      case 9005:
        return 'Linear Foot Clarke';
      case 9006:
        return 'Linear Foot Indian';
      case 9007:
        return 'Linear Link';
      case 9008:
        return 'Linear Link Benoit';
      case 9009:
        return 'Linear Link Sears';
      case 9010:
        return 'Linear Chain Benoit';
      case 9011:
        return 'Linear Chain Sears';
      case 9012:
        return 'Linear Yard Sears';
      case 9013:
        return 'Linear Yard Indian';
      case 9014:
        return 'Linear Fathom';
      case 9015:
        return 'Linear Mile International Nautical';
      case 9101:
        return 'Angular Radian';
      case 9102:
        return 'Angular Degree';
      case 9103:
        return 'Angular Arc Minute';
      case 9104:
        return 'Angular Arc Second';
      case 9105:
        return 'Angular Grad';
      case 9106:
        return 'Angular Gon';
      case 9107:
        return 'Angular DMS';
      case 9108:
        return 'Angular DMS Hemisphere';
      case 32767:
        return 'User Defined';
      default:
        return 'Unknown ($value)';
    }
  }
}
