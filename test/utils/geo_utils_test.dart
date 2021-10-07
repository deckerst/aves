import 'package:aves/utils/geo_utils.dart';
import 'package:latlong2/latlong.dart';
import 'package:test/test.dart';

void main() {
  test('Decimal degrees to DMS (sexagesimal)', () {
    expect(GeoUtils.toDMS(LatLng(37.496667, 127.0275)), ['37° 29′ 48.00″ N', '127° 1′ 39.00″ E']); // Gangnam
    expect(GeoUtils.toDMS(LatLng(78.9243503, 11.9230465)), ['78° 55′ 27.66″ N', '11° 55′ 22.97″ E']); // Ny-Ålesund
    expect(GeoUtils.toDMS(LatLng(-38.6965891, 175.9830047)), ['38° 41′ 47.72″ S', '175° 58′ 58.82″ E']); // Taupo
    expect(GeoUtils.toDMS(LatLng(-64.249391, -56.6556145)), ['64° 14′ 57.81″ S', '56° 39′ 20.21″ W']); // Marambio
    expect(GeoUtils.toDMS(LatLng(0, 0)), ['0° 0′ 0.00″ N', '0° 0′ 0.00″ E']);
  });

  test('bounds center', () {
    expect(GeoUtils.getLatLngCenter([LatLng(10, 30), LatLng(30, 50)]), LatLng(20.28236664671092, 39.351653000319956));
    expect(GeoUtils.getLatLngCenter([LatLng(10, -179), LatLng(30, 179)]), LatLng(20.00279344048298, -179.9358157370226));
  });
}
