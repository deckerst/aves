import 'package:aves/model/device.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/utils/emoji_utils.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';

class LocationFilter extends CoveredCollectionFilter {
  static const type = 'location';
  static const locationSeparator = ';';

  final LocationLevel level;
  late final String _location;
  late final String? _code;
  late final EntryFilter _test;

  static final unlocated = LocationFilter(LocationLevel.place, '');
  static final located = unlocated.reverse();

  bool get _isUnlocated => _location.isEmpty;

  @override
  List<Object?> get props => [level, _location, _code, reversed];

  LocationFilter(this.level, String location, {super.reversed = false}) {
    final split = location.split(locationSeparator);
    _location = split.isNotEmpty ? split[0] : location;
    _code = split.length > 1 ? split[1] : null;

    if (_isUnlocated) {
      _test = (entry) => !entry.hasGps;
    } else {
      switch (level) {
        case LocationLevel.country:
          _test = (entry) => entry.addressDetails?.countryCode == _code;
        case LocationLevel.state:
          _test = (entry) => entry.addressDetails?.stateCode == _code;
        case LocationLevel.place:
          _test = (entry) => entry.addressDetails?.place == _location;
      }
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
  Map<String, dynamic> toMap() {
    String location = _location;
    switch (level) {
      case LocationLevel.country:
      case LocationLevel.state:
        if (_code != null) {
          location = _nameAndCode;
        }
      case LocationLevel.place:
        break;
    }
    return {
      'type': type,
      'level': level.toString(),
      'location': location,
      'reversed': reversed,
    };
  }

  String get _nameAndCode => '$_location$locationSeparator$_code';

  String? get code => _code;

  String get place => _location;

  @override
  EntryFilter get positiveTest => _test;

  @override
  bool get exclusiveProp => true;

  @override
  String get universalLabel => _location;

  @override
  String getLabel(BuildContext context) => _isUnlocated ? context.l10n.filterNoLocationLabel : _location;

  @override
  Widget iconBuilder(BuildContext context, double size, {bool showGenericIcon = true}) {
    if (_isUnlocated) {
      return Icon(AIcons.locationUnlocated, size: size);
    }
    switch (level) {
      case LocationLevel.country:
        if (_code != null && device.canRenderFlagEmojis) {
          final flag = EmojiUtils.countryCodeToFlag(_code);
          if (flag != null) {
            return Text(
              flag,
              style: TextStyle(fontSize: size),
              textScaler: TextScaler.noScaling,
            );
          }
        }
        return Icon(AIcons.country, size: size);
      case LocationLevel.state:
        if (_code != null && device.canRenderSubdivisionFlagEmojis) {
          final flag = EmojiUtils.stateCodeToFlag(_code);
          if (flag != null) {
            return Text(
              flag,
              style: TextStyle(fontSize: size),
              textScaler: TextScaler.noScaling,
            );
          }
        }
        return Icon(AIcons.state, size: size);
      case LocationLevel.place:
        return Icon(AIcons.place, size: size);
    }
  }

  @override
  String get category => type;

  @override
  String get key => '$type-$reversed-$level-$code-$place';
}

enum LocationLevel { place, state, country }
