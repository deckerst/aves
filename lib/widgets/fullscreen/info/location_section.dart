import 'package:aves/model/filters/location.dart';
import 'package:aves/model/image_entry.dart';
import 'package:aves/model/settings/coordinate_format.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/identity/aves_filter_chip.dart';
import 'package:aves/widgets/fullscreen/info/common.dart';
import 'package:aves/widgets/fullscreen/info/maps/common.dart';
import 'package:aves/widgets/fullscreen/info/maps/google_map.dart';
import 'package:aves/widgets/fullscreen/info/maps/leaflet_map.dart';
import 'package:aves/widgets/fullscreen/info/maps/marker.dart';
import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';

class LocationSection extends StatefulWidget {
  final CollectionLens collection;
  final ImageEntry entry;
  final bool showTitle;
  final ValueNotifier<bool> visibleNotifier;
  final FilterCallback onFilter;

  const LocationSection({
    Key key,
    @required this.collection,
    @required this.entry,
    @required this.showTitle,
    @required this.visibleNotifier,
    @required this.onFilter,
  }) : super(key: key);

  @override
  _LocationSectionState createState() => _LocationSectionState();
}

class _LocationSectionState extends State<LocationSection> with TickerProviderStateMixin {
  String _loadedUri;

  static const extent = 48.0;
  static const pointerSize = Size(8.0, 6.0);

  CollectionLens get collection => widget.collection;

  ImageEntry get entry => widget.entry;

  @override
  void initState() {
    super.initState();
    _registerWidget(widget);
  }

  @override
  void didUpdateWidget(covariant LocationSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    _unregisterWidget(oldWidget);
    _registerWidget(widget);
  }

  @override
  void dispose() {
    _unregisterWidget(widget);
    super.dispose();
  }

  void _registerWidget(LocationSection widget) {
    widget.entry.metadataChangeNotifier.addListener(_handleChange);
    widget.entry.addressChangeNotifier.addListener(_handleChange);
    widget.visibleNotifier.addListener(_handleChange);
  }

  void _unregisterWidget(LocationSection widget) {
    widget.entry.metadataChangeNotifier.removeListener(_handleChange);
    widget.entry.addressChangeNotifier.removeListener(_handleChange);
    widget.visibleNotifier.removeListener(_handleChange);
  }

  @override
  Widget build(BuildContext context) {
    final showMap = (_loadedUri == entry.uri) || (entry.hasGps && widget.visibleNotifier.value);
    if (showMap) {
      _loadedUri = entry.uri;
      final filters = <LocationFilter>[];
      if (entry.isLocated) {
        final address = entry.addressDetails;
        final country = address.countryName;
        if (country != null && country.isNotEmpty) filters.add(LocationFilter(LocationLevel.country, '$country${LocationFilter.locationSeparator}${address.countryCode}'));
        final place = address.place;
        if (place != null && place.isNotEmpty) filters.add(LocationFilter(LocationLevel.place, place));
      }

      Widget buildMarker(BuildContext context) {
        return ImageMarker(
          entry: entry,
          extent: extent,
          pointerSize: pointerSize,
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.showTitle) SectionRow(AIcons.location),
          NotificationListener(
            onNotification: (notification) {
              if (notification is MapStyleChangedNotification) setState(() {});
              return false;
            },
            child: AnimatedSize(
              alignment: Alignment.topCenter,
              curve: Curves.easeInOutCubic,
              duration: Durations.mapStyleSwitchAnimation,
              vsync: this,
              child: settings.infoMapStyle.isGoogleMaps
                  ? EntryGoogleMap(
                      // `LatLng` used by `google_maps_flutter` is not the one from `latlong` package
                      latLng: Tuple2<double, double>(entry.latLng.latitude, entry.latLng.longitude),
                      geoUri: entry.geoUri,
                      initialZoom: settings.infoMapZoom,
                      markerId: entry.uri ?? entry.path,
                      markerBuilder: buildMarker,
                    )
                  : EntryLeafletMap(
                      latLng: entry.latLng,
                      geoUri: entry.geoUri,
                      initialZoom: settings.infoMapZoom,
                      style: settings.infoMapStyle,
                      markerSize: Size(extent, extent + pointerSize.height),
                      markerBuilder: buildMarker,
                    ),
            ),
          ),
          if (entry.hasGps) _AddressInfoGroup(entry: entry),
          if (filters.isNotEmpty)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AvesFilterChip.outlineWidth / 2) + EdgeInsets.only(top: 8),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: filters
                    .map((filter) => AvesFilterChip(
                          filter: filter,
                          onTap: widget.onFilter,
                        ))
                    .toList(),
              ),
            ),
        ],
      );
    } else {
      _loadedUri = null;
      return SizedBox.shrink();
    }
  }

  void _handleChange() => setState(() {});
}

class _AddressInfoGroup extends StatefulWidget {
  final ImageEntry entry;

  const _AddressInfoGroup({@required this.entry});

  @override
  _AddressInfoGroupState createState() => _AddressInfoGroupState();
}

class _AddressInfoGroupState extends State<_AddressInfoGroup> {
  Future<String> _addressLineLoader;

  ImageEntry get entry => widget.entry;

  @override
  void initState() {
    super.initState();
    _addressLineLoader = entry.findAddressLine();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _addressLineLoader,
      builder: (context, snapshot) {
        final address = !snapshot.hasError && snapshot.connectionState == ConnectionState.done ? snapshot.data : null;
        return InfoRowGroup({
          'Coordinates': settings.coordinateFormat.format(entry.latLng),
          if (address?.isNotEmpty == true) 'Address': address,
        });
      },
    );
  }
}

// browse providers at https://leaflet-extras.github.io/leaflet-providers/preview/
enum EntryMapStyle { googleNormal, googleHybrid, googleTerrain, osmHot, stamenToner, stamenWatercolor }

extension ExtraEntryMapStyle on EntryMapStyle {
  String get name {
    switch (this) {
      case EntryMapStyle.googleNormal:
        return 'Google Maps';
      case EntryMapStyle.googleHybrid:
        return 'Google Maps (Hybrid)';
      case EntryMapStyle.googleTerrain:
        return 'Google Maps (Terrain)';
      case EntryMapStyle.osmHot:
        return 'Humanitarian OSM';
      case EntryMapStyle.stamenToner:
        return 'Stamen Toner';
      case EntryMapStyle.stamenWatercolor:
        return 'Stamen Watercolor';
      default:
        return toString();
    }
  }

  bool get isGoogleMaps {
    switch (this) {
      case EntryMapStyle.googleNormal:
      case EntryMapStyle.googleHybrid:
      case EntryMapStyle.googleTerrain:
        return true;
      default:
        return false;
    }
  }
}
