import 'package:aves/model/filters/filters.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class LocationFilter extends CollectionFilter {
  static const type = 'location';
  static const locationSeparator = ';';

  final LocationLevel level;
  String _location;
  String? _countryCode;
  late EntryFilter _test;

  LocationFilter(this.level, this._location) {
    final split = _location.split(locationSeparator);
    if (split.isNotEmpty) _location = split[0];
    if (split.length > 1) _countryCode = split[1];

    if (_location.isEmpty) {
      _test = (entry) => !entry.hasGps;
    } else if (level == LocationLevel.country) {
      _test = (entry) => entry.addressDetails?.countryCode == _countryCode;
    } else if (level == LocationLevel.place) {
      _test = (entry) => entry.addressDetails?.place == _location;
    }
  }

  LocationFilter.fromMap(Map<String, dynamic> json)
      : this(
          LocationLevel.values.firstWhereOrNull((v) => v.toString() == json['level']) ?? LocationLevel.place,
          json['location'],
        );

  @override
  Map<String, dynamic> toMap() => {
        'type': type,
        'level': level.toString(),
        'location': _countryCode != null ? countryNameAndCode : _location,
      };

  String get countryNameAndCode => '$_location$locationSeparator$_countryCode';

  String? get countryCode => _countryCode;

  @override
  EntryFilter get test => _test;

  @override
  String get universalLabel => _location;

  @override
  String getLabel(BuildContext context) => _location.isEmpty ? context.l10n.filterLocationEmptyLabel : _location;

  @override
  Widget iconBuilder(BuildContext context, double size, {bool showGenericIcon = true, bool embossed = false}) {
    final flag = countryCodeToFlag(_countryCode);
    // as of Flutter v1.22.3, emoji shadows are rendered as colorful duplicates,
    // not filled with the shadow color as expected, so we remove them
    if (flag != null) {
      return Text(
        flag,
        style: TextStyle(fontSize: size, shadows: []),
        textScaleFactor: 1.0,
      );
    }
    return Icon(_location.isEmpty ? AIcons.locationOff : AIcons.location, size: size);
  }

  @override
  String get category => type;

  @override
  String get key => '$type-$level-$_location';

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is LocationFilter && other.level == level && other._location == _location;
  }

  @override
  int get hashCode => hashValues(type, level, _location);

  @override
  String toString() => '$runtimeType#${shortHash(this)}{level=$level, location=$_location}';

  // U+0041 Latin Capital letter A
  // U+1F1E6 🇦 REGIONAL INDICATOR SYMBOL LETTER A
  static const _countryCodeToFlagDiff = 0x1F1E6 - 0x0041;

  static String? countryCodeToFlag(String? code) {
    if (code == null || code.length != 2) return null;
    return String.fromCharCodes(code.codeUnits.map((letter) => letter += _countryCodeToFlagDiff));
  }
}

enum LocationLevel { place, country }
