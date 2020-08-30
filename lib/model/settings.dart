import 'package:aves/utils/geo_utils.dart';
import 'package:aves/widgets/fullscreen/info/location_section.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tuple/tuple.dart';

import 'source/enums.dart';

final Settings settings = Settings._private();

typedef SettingsCallback = void Function(String key, dynamic oldValue, dynamic newValue);

class Settings extends ChangeNotifier {
  static SharedPreferences _prefs;

  Settings._private();

  // preferences
  static const catalogTimeZoneKey = 'catalog_time_zone';
  static const collectionGroupFactorKey = 'collection_group_factor';
  static const collectionSortFactorKey = 'collection_sort_factor';
  static const collectionTileExtentKey = 'collection_tile_extent';
  static const hasAcceptedTermsKey = 'has_accepted_terms';
  static const infoMapStyleKey = 'info_map_style';
  static const infoMapZoomKey = 'info_map_zoom';
  static const launchPageKey = 'launch_page';
  static const coordinateFormatKey = 'coordinates_format';
  static const svgBackgroundKey = 'svg_background';
  static const albumSortFactorKey = 'album_sort_factor';

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> reset() {
    return _prefs.clear();
  }

  String get catalogTimeZone => _prefs.getString(catalogTimeZoneKey) ?? '';

  set catalogTimeZone(String newValue) => setAndNotify(catalogTimeZoneKey, newValue);

  EntryGroupFactor get collectionGroupFactor => getEnumOrDefault(collectionGroupFactorKey, EntryGroupFactor.month, EntryGroupFactor.values);

  set collectionGroupFactor(EntryGroupFactor newValue) => setAndNotify(collectionGroupFactorKey, newValue.toString());

  EntrySortFactor get collectionSortFactor => getEnumOrDefault(collectionSortFactorKey, EntrySortFactor.date, EntrySortFactor.values);

  set collectionSortFactor(EntrySortFactor newValue) => setAndNotify(collectionSortFactorKey, newValue.toString());

  double get collectionTileExtent => _prefs.getDouble(collectionTileExtentKey) ?? 0;

  set collectionTileExtent(double newValue) => setAndNotify(collectionTileExtentKey, newValue);

  EntryMapStyle get infoMapStyle => getEnumOrDefault(infoMapStyleKey, EntryMapStyle.stamenWatercolor, EntryMapStyle.values);

  set infoMapStyle(EntryMapStyle newValue) => setAndNotify(infoMapStyleKey, newValue.toString());

  double get infoMapZoom => _prefs.getDouble(infoMapZoomKey) ?? 12;

  set infoMapZoom(double newValue) => setAndNotify(infoMapZoomKey, newValue);

  bool get hasAcceptedTerms => getBoolOrDefault(hasAcceptedTermsKey, false);

  set hasAcceptedTerms(bool newValue) => setAndNotify(hasAcceptedTermsKey, newValue);

  LaunchPage get launchPage => getEnumOrDefault(launchPageKey, LaunchPage.collection, LaunchPage.values);

  set launchPage(LaunchPage newValue) => setAndNotify(launchPageKey, newValue.toString());

  CoordinateFormat get coordinateFormat => getEnumOrDefault(coordinateFormatKey, CoordinateFormat.dms, CoordinateFormat.values);

  set coordinateFormat(CoordinateFormat newValue) => setAndNotify(coordinateFormatKey, newValue.toString());

  int get svgBackground => _prefs.getInt(svgBackgroundKey) ?? 0xFFFFFFFF;

  set svgBackground(int newValue) => setAndNotify(svgBackgroundKey, newValue);

  ChipSortFactor get albumSortFactor => getEnumOrDefault(albumSortFactorKey, ChipSortFactor.date, ChipSortFactor.values);

  set albumSortFactor(ChipSortFactor newValue) => setAndNotify(albumSortFactorKey, newValue.toString());

  // convenience methods

  // ignore: avoid_positional_boolean_parameters
  bool getBoolOrDefault(String key, bool defaultValue) => _prefs.getKeys().contains(key) ? _prefs.getBool(key) : defaultValue;

  T getEnumOrDefault<T>(String key, T defaultValue, Iterable<T> values) {
    final valueString = _prefs.getString(key);
    for (final element in values) {
      if (element.toString() == valueString) {
        return element;
      }
    }
    return defaultValue;
  }

  List<T> getEnumListOrDefault<T>(String key, List<T> defaultValue, Iterable<T> values) {
    return _prefs.getStringList(key)?.map((s) => values.firstWhere((el) => el.toString() == s, orElse: () => null))?.where((el) => el != null)?.toList() ?? defaultValue;
  }

  void setAndNotify(String key, dynamic newValue) {
    var oldValue = _prefs.get(key);
    if (newValue == null) {
      _prefs.remove(key);
    } else if (newValue is String) {
      oldValue = _prefs.getString(key);
      _prefs.setString(key, newValue);
    } else if (newValue is List<String>) {
      oldValue = _prefs.getStringList(key);
      _prefs.setStringList(key, newValue);
    } else if (newValue is int) {
      oldValue = _prefs.getInt(key);
      _prefs.setInt(key, newValue);
    } else if (newValue is double) {
      oldValue = _prefs.getDouble(key);
      _prefs.setDouble(key, newValue);
    } else if (newValue is bool) {
      oldValue = _prefs.getBool(key);
      _prefs.setBool(key, newValue);
    }
    if (oldValue != newValue) {
      notifyListeners();
    }
  }
}

enum LaunchPage { collection, albums }

extension ExtraLaunchPage on LaunchPage {
  String get name {
    switch (this) {
      case LaunchPage.collection:
        return 'All Media';
      case LaunchPage.albums:
        return 'Albums';
      default:
        return toString();
    }
  }
}

enum CoordinateFormat { dms, decimal }

extension ExtraCoordinateFormat on CoordinateFormat {
  String get name {
    switch (this) {
      case CoordinateFormat.dms:
        return 'DMS';
      case CoordinateFormat.decimal:
        return 'Decimal degrees';
      default:
        return toString();
    }
  }

  String format(Tuple2<double, double> latLng) {
    switch (this) {
      case CoordinateFormat.dms:
        return toDMS(latLng).join(', ');
      case CoordinateFormat.decimal:
        return [latLng.item1, latLng.item2].map((n) => n.toStringAsFixed(6)).join(', ');
      default:
        return toString();
    }
  }
}
