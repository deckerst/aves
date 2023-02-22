import 'package:aves/model/device.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';

class LocationFilter extends CoveredCollectionFilter {
  static const type = 'location';
  static const locationSeparator = ';';

  final LocationLevel level;
  late final String _location;
  late final String? _countryCode;
  late final EntryFilter _test;

  @override
  List<Object?> get props => [level, _location, _countryCode, reversed];

  LocationFilter(this.level, String location, {super.reversed = false}) {
    final split = location.split(locationSeparator);
    _location = split.isNotEmpty ? split[0] : location;
    _countryCode = split.length > 1 ? split[1] : null;

    if (_location.isEmpty) {
      _test = (entry) => !entry.hasGps;
    } else if (level == LocationLevel.country) {
      _test = (entry) => entry.addressDetails?.countryCode == _countryCode;
    } else if (level == LocationLevel.place) {
      _test = (entry) => entry.addressDetails?.place == _location;
    }
  }

  factory LocationFilter.fromMap(Map<String, dynamic> json) {
    return LocationFilter(
      LocationLevel.values.firstWhereOrNull((v) => v.toString() == json['level']) ?? LocationLevel.place,
      json['location'],
      reversed: json['reversed'] ?? false,
    );
  }

  @override
  Map<String, dynamic> toMap() => {
        'type': type,
        'level': level.toString(),
        'location': _countryCode != null ? countryNameAndCode : _location,
        'reversed': reversed,
      };

  String get countryNameAndCode => '$_location$locationSeparator$_countryCode';

  String? get countryCode => _countryCode;

  String get place => _location;

  @override
  EntryFilter get positiveTest => _test;

  @override
  bool get exclusiveProp => true;

  @override
  String get universalLabel => _location;

  @override
  String getLabel(BuildContext context) => _location.isEmpty ? context.l10n.filterNoLocationLabel : _location;

  @override
  Widget iconBuilder(BuildContext context, double size, {bool showGenericIcon = true}) {
    if (_location.isEmpty) {
      return Icon(AIcons.locationUnlocated, size: size);
    }
    switch (level) {
      case LocationLevel.place:
        return Icon(AIcons.place, size: size);
      case LocationLevel.country:
        if (_countryCode != null && device.canRenderFlagEmojis) {
          final flag = countryCodeToFlag(_countryCode);
          if (flag != null) {
            return Text(
              flag,
              style: TextStyle(fontSize: size),
              textScaleFactor: 1.0,
            );
          }
        }
        return Icon(AIcons.country, size: size);
    }
  }

  @override
  String get category => type;

  @override
  String get key => '$type-$reversed-$level-$_location';

  // U+0041 Latin Capital letter A
  // U+1F1E6 🇦 REGIONAL INDICATOR SYMBOL LETTER A
  static const _countryCodeToFlagDiff = 0x1F1E6 - 0x0041;

  static String? countryCodeToFlag(String? code) {
    if (code == null || code.length != 2) return null;
    return String.fromCharCodes(code.toUpperCase().codeUnits.map((letter) => letter += _countryCodeToFlagDiff));
  }
}

enum LocationLevel { place, country }
