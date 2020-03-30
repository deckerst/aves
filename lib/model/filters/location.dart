import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/image_entry.dart';
import 'package:flutter/widgets.dart';
import 'package:outline_material_icons/outline_material_icons.dart';

class LocationFilter extends CollectionFilter {
  static const type = 'country';

  final LocationLevel level;
  final String location;

  const LocationFilter(this.level, this.location);

  @override
  bool filter(ImageEntry entry) => entry.isLocated && ((level == LocationLevel.country && entry.addressDetails.countryName == location) || (level == LocationLevel.city && entry.addressDetails.city == location));

  @override
  String get label => location;

  @override
  Widget iconBuilder(context, size) => Icon(OMIcons.place, size: size);

  @override
  String get typeKey => type;

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is LocationFilter && other.location == location;
  }

  @override
  int get hashCode => hashValues('LocationFilter', location);
}

enum LocationLevel { city, country }
