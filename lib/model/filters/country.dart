import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/image_entry.dart';
import 'package:flutter/widgets.dart';
import 'package:outline_material_icons/outline_material_icons.dart';

class CountryFilter extends CollectionFilter {
  static const type = 'country';

  final String country;

  const CountryFilter(this.country);

  @override
  bool filter(ImageEntry entry) => entry.isLocated && entry.addressDetails.countryName == country;

  @override
  String get label => country;

  @override
  Widget iconBuilder(context, size) => Icon(OMIcons.place, size: size);

  @override
  String get typeKey => type;

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is CountryFilter && other.country == country;
  }

  @override
  int get hashCode => hashValues('CountryFilter', country);
}
