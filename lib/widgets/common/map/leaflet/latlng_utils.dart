import 'package:latlong2/latlong.dart';

class LatLngUtils {
  static LatLng? lerp(LatLng? a, LatLng? b, double t) {
    if (a == null && b == null) return null;

    final _a = a ?? LatLng(0, 0);
    final _b = b ?? LatLng(0, 0);
    return LatLng(
      _a.latitude + (_b.latitude - _a.latitude) * t,
      _a.longitude + (_b.longitude - _a.longitude) * t,
    );
  }
}
