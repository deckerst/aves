import 'package:aves/widgets/common/map/leaflet/latlng_utils.dart';
import 'package:flutter/widgets.dart';
import 'package:latlong2/latlong.dart';

class LatLngTween extends Tween<LatLng?> {
  LatLngTween({
    required super.begin,
    required super.end,
  });

  @override
  LatLng? lerp(double t) => LatLngUtils.lerp(begin, end, t);
}
