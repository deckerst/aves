import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/image_entry.dart';
import 'package:aves/widgets/common/icons.dart';
import 'package:flutter/widgets.dart';

class LocationFilter extends CollectionFilter {
  static const type = 'country';
  static const locationSeparator = ';';

  final LocationLevel level;
  String _location;
  String _countryCode;

  LocationFilter(this.level, this._location) {
    final split = _location.split(locationSeparator);
    if (split.isNotEmpty) _location = split[0];
    if (split.length > 1) _countryCode = split[1];
  }

  LocationFilter.fromJson(Map<String, dynamic> json)
      : this(
          LocationLevel.values.firstWhere((v) => v.toString() == json['level'], orElse: () => null),
          json['location'],
        );

  Map<String, dynamic> toJson() => {
        'type': type,
        'level': level.toString(),
        'location': _countryCode != null ? '$_location$locationSeparator$_countryCode' : _location,
      };

  @override
  bool filter(ImageEntry entry) => entry.isLocated && ((level == LocationLevel.country && entry.addressDetails.countryName == _location) || (level == LocationLevel.place && entry.addressDetails.place == _location));

  @override
  String get label => _location;

  @override
  Widget iconBuilder(BuildContext context, double size, {bool showGenericIcon = true}) {
    final flag = countryCodeToFlag(_countryCode);
    if (flag != null) return Text(flag, style: TextStyle(fontSize: size));
    return Icon(AIcons.location, size: size);
  }

  @override
  String get typeKey => type;

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is LocationFilter && other.level == level && other._location == _location;
  }

  @override
  int get hashCode => hashValues('LocationFilter', level, _location);

  @override
  String toString() {
    return 'LocationFilter{level=$level, location=$_location}';
  }

  // U+0041 Latin Capital letter A
  // U+1F1E6 🇦 REGIONAL INDICATOR SYMBOL LETTER A
  static const _countryCodeToFlagDiff = 0x1F1E6 - 0x0041;

  static String countryCodeToFlag(String code) {
    return code?.length == 2 ? String.fromCharCodes(code.codeUnits.map((letter) => letter += _countryCodeToFlagDiff)) : null;
  }
}

enum LocationLevel { place, country }
