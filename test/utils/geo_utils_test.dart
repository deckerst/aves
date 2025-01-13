import 'package:aves/l10n/l10n.dart';
import 'package:aves/model/settings/enums/coordinate_format.dart';
import 'package:aves/widgets/aves_app.dart';
import 'package:aves_map/aves_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:test/test.dart';

void main() {
  test('Decimal degrees to DMS (sexagesimal)', () {
    final l10n = lookupAppLocalizations(AvesApp.supportedLocales.first);
    expect(ExtraCoordinateFormat.toDMS(l10n, const LatLng(37.496667, 127.0275)), ['37° 29′ 48.00″ N', '127° 1′ 39.00″ E']); // Gangnam
    expect(ExtraCoordinateFormat.toDMS(l10n, const LatLng(78.9243503, 11.9230465)), ['78° 55′ 27.66″ N', '11° 55′ 22.97″ E']); // Ny-Ålesund
    expect(ExtraCoordinateFormat.toDMS(l10n, const LatLng(-38.6965891, 175.9830047)), ['38° 41′ 47.72″ S', '175° 58′ 58.82″ E']); // Taupo
    expect(ExtraCoordinateFormat.toDMS(l10n, const LatLng(-64.249391, -56.6556145)), ['64° 14′ 57.81″ S', '56° 39′ 20.21″ W']); // Marambio
    expect(ExtraCoordinateFormat.toDMS(l10n, const LatLng(0, 0)), ['0° 0′ 0.00″ N', '0° 0′ 0.00″ E']);
    expect(ExtraCoordinateFormat.toDMS(l10n, const LatLng(0, 0), minuteSecondPadding: true), ['0° 00′ 00.00″ N', '0° 00′ 00.00″ E']);
    expect(ExtraCoordinateFormat.toDMS(l10n, const LatLng(0, 0), secondDecimals: 0), ['0° 0′ 0″ N', '0° 0′ 0″ E']);
    expect(ExtraCoordinateFormat.toDMS(l10n, const LatLng(0, 0), secondDecimals: 4), ['0° 0′ 0.0000″ N', '0° 0′ 0.0000″ E']);
  });

  test('Decimal degrees to DDM', () {
    final l10n = lookupAppLocalizations(AvesApp.supportedLocales.first);
    expect(ExtraCoordinateFormat.toDDM(l10n, const LatLng(37.496667, 127.0275)), ['37° 29.8000′ N', '127° 1.6500′ E']); // Gangnam
    expect(ExtraCoordinateFormat.toDDM(l10n, const LatLng(78.9243503, 11.9230465)), ['78° 55.4610′ N', '11° 55.3828′ E']); // Ny-Ålesund
    expect(ExtraCoordinateFormat.toDDM(l10n, const LatLng(-38.6965891, 175.9830047)), ['38° 41.7953′ S', '175° 58.9803′ E']); // Taupo
    expect(ExtraCoordinateFormat.toDDM(l10n, const LatLng(-64.249391, -56.6556145)), ['64° 14.9635′ S', '56° 39.3369′ W']); // Marambio
    expect(ExtraCoordinateFormat.toDDM(l10n, const LatLng(0, 0)), ['0° 0.0000′ N', '0° 0.0000′ E']);
    expect(ExtraCoordinateFormat.toDDM(l10n, const LatLng(0, 0), minutePadding: true), ['0° 00.0000′ N', '0° 00.0000′ E']);
    expect(ExtraCoordinateFormat.toDDM(l10n, const LatLng(0, 0), minuteDecimals: 0), ['0° 0′ N', '0° 0′ E']);
    expect(ExtraCoordinateFormat.toDDM(l10n, const LatLng(0, 0), minuteDecimals: 6), ['0° 0.000000′ N', '0° 0.000000′ E']);
  });

  test('bounds center', () {
    expect(GeoUtils.getLatLngCenter(const [LatLng(10, 30), LatLng(30, 50)]), const LatLng(20.28236664671092, 39.351653000319956));
    expect(GeoUtils.getLatLngCenter(const [LatLng(10, -179), LatLng(30, 179)]), const LatLng(20.00279344048298, -179.9358157370226));
  });
}
