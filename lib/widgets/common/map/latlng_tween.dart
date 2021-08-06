import 'package:aves/widgets/common/map/latlng_utils.dart';
import 'package:flutter/widgets.dart';
import 'package:latlong2/latlong.dart';

class LatLngTween extends Tween<LatLng?> {
  LatLngTween({
    required LatLng? begin,
    required LatLng? end,
  }) : super(
          begin: begin,
          end: end,
        );

  @override
  LatLng? lerp(double t) => LatLngUtils.lerp(begin, end, t);
}
