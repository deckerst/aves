import 'dart:convert';

import 'package:aves/image_providers/thumbnail_provider.dart';
import 'package:aves/model/device.dart';
import 'package:aves/model/filters/covered/covered.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/ref/mime_types.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/utils/emoji_utils.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves_utils/aves_utils.dart';
import 'package:country_code/country_code.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class LocationFilter extends CollectionFilter with CoveredFilter {
  static const type = 'location';
  static const locationSeparator = ';';

  final LocationLevel level;
  late final String _location;
  late final String? _code;
  late final EntryPredicate _test;

  static final unlocated = LocationFilter(LocationLevel.place, '');
  static final located = unlocated.reverse();

  bool get _isUnlocated => _location.isEmpty;

  @override
  List<Object?> get props => [level, _location, _code, reversed];

  new(this.level, String location, {super.reversed = false}) {
    final split = location.split(locationSeparator);
    _location = split.isNotEmpty ? split[0] : location;
    _code = split.length > 1 ? split[1] : null;

    if (_isUnlocated) {
      _test = (entry) => !entry.hasGps;
    } else {
      switch (level) {
        case .country:
          _test = (entry) => entry.addressDetails?.countryCode == _code;
        case .state:
          _test = (entry) => entry.addressDetails?.stateCode == _code;
        case .place:
          _test = (entry) => entry.addressDetails?.place == _location;
      }
    }
  }

  factory fromMap(Map<String, Object?> json) {
    return LocationFilter(
      LocationLevel.values.safeByName(json['level'] as String?) ?? .place,
      json['location'] as String,
      reversed: json['reversed'] as bool? ?? false,
    );
  }

  @override
  Map<String, Object?> toJsonMap() {
    String location = _location;
    switch (level) {
      case .country:
      case .state:
        if (_code != null) {
          location = _nameAndCode;
        }
      case .place:
        break;
    }
    return {
      'type': type,
      'level': level.name,
      'location': location,
      if (reversed) 'reversed': reversed,
    };
  }

  String get _nameAndCode => '$_location$locationSeparator$_code';

  String? get code => _code;

  String get place => _location;

  @override
  EntryPredicate get positiveTest => _test;

  @override
  bool get exclusiveProp => true;

  @override
  String get universalLabel => _location;

  @override
  String getLabel(BuildContext context) => _isUnlocated ? context.l10n.filterNoLocationLabel : _location;

  @override
  Widget? iconBuilder(BuildContext context, double size, {bool allowGenericIcon = true}) {
    if (_isUnlocated) {
      return Icon(AIcons.locationUnlocated, size: size);
    }
    switch (level) {
      case .country:
        if (_code != null) {
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
      case .state:
        if (_code != null) {
          final countryCode = _code.substring(0, 2).toUpperCase();
          if (<String>{
            // Australia (public domain): https://commons.wikimedia.org/wiki/Flags_of_subdivisions_of_Australia
            CountryCode.AU.alpha2,
          }.contains(countryCode)) {
            return FutureBuilder<ByteData>(
              future: DefaultAssetBundle.of(context).load('assets/flags/$code.svg'),
              builder: (context, snapshot) {
                final svgBytes = snapshot.data;
                if (svgBytes == null) return const SizedBox();

                const mimeType = MimeTypes.svg;
                return Image(
                  image: ThumbnailProvider(
                    ThumbnailProviderKey(
                      uri: 'data:$mimeType;base64,${base64.encode(Uint8List.sublistView(svgBytes))}',
                      mimeType: mimeType,
                      pageId: null,
                      rotationDegrees: 0,
                      isFlipped: false,
                      dateModifiedMillis: -1,
                      extent: size,
                      videoThumbnailMethods: null,
                    ),
                  ),
                  width: size,
                  height: size,
                );
              },
            );
          } else if (device.canRenderSubdivisionFlagEmojis) {
            final flag = EmojiUtils.stateCodeToFlag(_code);
            if (flag != null) {
              return Text(
                flag,
                style: TextStyle(fontSize: size),
                textScaler: TextScaler.noScaling,
              );
            }
          }
        }
        return Icon(AIcons.state, size: size);
      case .place:
        return Icon(AIcons.place, size: size);
    }
  }

  @override
  String get category => type;

  @override
  String get key => '$type-$reversed-${level.name}-$code-$place';
}

enum LocationLevel { place, state, country }
