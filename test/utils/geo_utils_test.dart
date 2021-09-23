import 'package:aves/utils/geo_utils.dart';
import 'package:latlong2/latlong.dart';
import 'package:test/test.dart';

void main() {
  test('bounds center', () {
    expect(getLatLngCenter([LatLng(10, 30), LatLng(30, 50)]), LatLng(20.28236664671092, 39.351653000319956));
    expect(getLatLngCenter([LatLng(10, -179), LatLng(30, 179)]), LatLng(20.00279344048298, -179.9358157370226));
  });
}
