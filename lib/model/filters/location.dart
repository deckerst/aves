import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/image_entry.dart';
import 'package:aves/widgets/common/icons.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class LocationFilter extends CollectionFilter {
  static const type = 'location';
  static const emptyLabel = 'unlocated';
  static const locationSeparator = ';';

  final LocationLevel level;
  String _location;
  String _countryCode;

  LocationFilter(this.level, this._location) {
    final split = _location.split(locationSeparator);
    if (split.isNotEmpty) _location = split[0];
    if (split.length > 1) _countryCode = split[1];
  }

  LocationFilter.fromMap(Map<String, dynamic> json)
      : this(
          LocationLevel.values.firstWhere((v) => v.toString() == json['level'], orElse: () => null),
          json['location'],
        );

  @override
  Map<String, dynamic> toMap() => {
        'type': type,
        'level': level.toString(),
        'location': _countryCode != null ? countryNameAndCode : _location,
      };

  String get countryNameAndCode => '$_location$locationSeparator$_countryCode';

  @override
  bool filter(ImageEntry entry) => _location.isEmpty ? !entry.isLocated : entry.isLocated && ((level == LocationLevel.country && entry.addressDetails.countryCode == _countryCode) || (level == LocationLevel.place && entry.addressDetails.place == _location));

  @override
  String get label => _location.isEmpty ? emptyLabel : _location;

  @override
  Widget iconBuilder(BuildContext context, double size, {bool showGenericIcon = true, bool embossed = false}) {
    final flag = countryCodeToFlag(_countryCode);
    // as of Flutter v1.22.3, emoji shadows are rendered as colorful duplicates,
    // not filled with the shadow color as expected, so we remove them
    if (flag != null) return Text(flag, style: TextStyle(fontSize: size, shadows: []));
    return Icon(_location.isEmpty ? AIcons.locationOff : AIcons.location, size: size);
  }

  @override
  String get typeKey => type;

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is LocationFilter && other.level == level && other._location == _location;
  }

  @override
  int get hashCode => hashValues(type, level, _location);

  @override
  String toString() {
    return '$runtimeType#${shortHash(this)}{level=$level, location=$_location}';
  }

  // U+0041 Latin Capital letter A
  // U+1F1E6 🇦 REGIONAL INDICATOR SYMBOL LETTER A
  static const _countryCodeToFlagDiff = 0x1F1E6 - 0x0041;

  static String countryCodeToFlag(String code) {
    return code?.length == 2 ? String.fromCharCodes(code.codeUnits.map((letter) => letter += _countryCodeToFlagDiff)) : null;
  }
}

enum LocationLevel { place, country }
