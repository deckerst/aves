import 'dart:convert';

import 'package:aves/model/settings/defaults.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves_map/aves_map.dart';
import 'package:aves_model/aves_model.dart';
import 'package:collection/collection.dart';
import 'package:latlong2/latlong.dart';

mixin MapSettings on SettingsAccess {
  EntryMapStyle? get mapStyle {
    var preferred = getString(SettingKeys.mapStyleKey);

    // backward compatibility with definition as enum
    const oldEnumPrefix = 'EntryMapStyle.';
    if (preferred != null && preferred.startsWith(oldEnumPrefix)) {
      preferred = preferred.substring(oldEnumPrefix.length);
      if (preferred.isEmpty) preferred = null;
    }

    if (preferred == null) return null;

    final styles = [...availability.mapStyles, ...customMapStyles];
    return styles.firstWhereOrNull((v) => v.key == preferred) ?? styles.first;
  }

  set mapStyle(EntryMapStyle? newValue) => set(SettingKeys.mapStyleKey, newValue?.key);

  LatLng? get mapDefaultCenter {
    final jsonString = getString(SettingKeys.mapDefaultCenterKey);
    if (jsonString == null) return null;

    final jsonMap = jsonDecode(jsonString) as Map<String, Object?>;
    return LatLng.fromJson(jsonMap);
  }

  set mapDefaultCenter(LatLng? newValue) => set(SettingKeys.mapDefaultCenterKey, newValue != null ? jsonEncode(newValue.toJson()) : null);

  bool get mapShowItemTracks => getBool(SettingKeys.mapShowItemTracksKey) ?? SettingsDefaults.mapShowItemTracks;

  set mapShowItemTracks(bool newValue) => set(SettingKeys.mapShowItemTracksKey, newValue);

  Set<EntryMapStyle> get customMapStyles => (getStringList(SettingKeys.customMapStylesKey) ?? []).map(EntryMapStyle.fromJson).nonNulls.toSet();

  set customMapStyles(Set<EntryMapStyle> newValue) => set(SettingKeys.customMapStylesKey, newValue.map((filter) => filter.toJson()).toList());
}
