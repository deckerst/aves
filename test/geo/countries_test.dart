import 'package:aves/geo/countries.dart';
import 'package:aves/geo/topojson.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong/latlong.dart';

void main() {
  // [lng, lat, z]
  const buenosAires = [-58.381667, -34.603333];
  const paris = [2.348777, 48.875683];
  const seoul = [126.99, 37.56, 42];
  const argentinaN3String = '032';
  const franceN3String = '250';
  const southKoreaN3String = '410';

  test('Parse countries', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final topo = await countryTopology.getTopology();
    final countries = topo.objects['countries'] as GeometryCollection;

    final argentina = countries.geometries.firstWhere((geometry) => geometry.id == argentinaN3String);
    expect(argentina.properties['name'], 'Argentina');
    expect(argentina.containsPoint(topo, buenosAires), true);
    expect(argentina.containsPoint(topo, seoul), false);
  });

  test('Get country id', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    expect(await countryTopology.numericCode(LatLng(buenosAires[1], buenosAires[0])), int.parse(argentinaN3String));
    expect(await countryTopology.numericCode(LatLng(seoul[1], seoul[0])), int.parse(southKoreaN3String));
    expect(await countryTopology.numericCode(LatLng(paris[1], paris[0])), int.parse(franceN3String));
  });
}
