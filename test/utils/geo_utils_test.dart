import 'package:aves/utils/geo_utils.dart';
import 'package:test/test.dart';
import 'package:tuple/tuple.dart';

void main() {
  test('Decimal degrees to DMS (sexagesimal)', () {
    expect(toDMS(Tuple2(37.496667, 127.0275)), ['37° 29′ 48.00″ N', '127° 1′ 39.00″ E']); // Gangnam
    expect(toDMS(Tuple2(78.9243503, 11.9230465)), ['78° 55′ 27.66″ N', '11° 55′ 22.97″ E']); // Ny-Ålesund
    expect(toDMS(Tuple2(-38.6965891, 175.9830047)), ['38° 41′ 47.72″ S', '175° 58′ 58.82″ E']); // Taupo
    expect(toDMS(Tuple2(-64.249391, -56.6556145)), ['64° 14′ 57.81″ S', '56° 39′ 20.21″ W']); // Marambio
  });
}
