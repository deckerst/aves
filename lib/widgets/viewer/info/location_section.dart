import 'package:aves/model/entry.dart';
import 'package:aves/model/filters/location.dart';
import 'package:aves/model/settings/coordinate_format.dart';
import 'package:aves/model/settings/enums.dart';
import 'package:aves/model/settings/map_style.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/services/services.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/identity/aves_filter_chip.dart';
import 'package:aves/widgets/viewer/info/common.dart';
import 'package:aves/widgets/viewer/info/maps/common.dart';
import 'package:aves/widgets/viewer/info/maps/google_map.dart';
import 'package:aves/widgets/viewer/info/maps/leaflet_map.dart';
import 'package:aves/widgets/viewer/info/maps/marker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

class LocationSection extends StatefulWidget {
  final CollectionLens? collection;
  final AvesEntry entry;
  final bool showTitle;
  final ValueNotifier<bool> isScrollingNotifier;
  final FilterCallback onFilter;

  const LocationSection({
    Key? key,
    required this.collection,
    required this.entry,
    required this.showTitle,
    required this.isScrollingNotifier,
    required this.onFilter,
  }) : super(key: key);

  @override
  _LocationSectionState createState() => _LocationSectionState();
}

class _LocationSectionState extends State<LocationSection> with TickerProviderStateMixin {
  // as of google_maps_flutter v2.0.6, Google Maps initialization is blocking
  // cf https://github.com/flutter/flutter/issues/28493
  // it is especially severe the first time, but still significant afterwards
  // so we prevent loading it while scrolling or animating
  bool _googleMapsLoaded = false;

  static const extent = 48.0;
  static const pointerSize = Size(8.0, 6.0);

  CollectionLens? get collection => widget.collection;

  AvesEntry get entry => widget.entry;

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
  }

  void _unregisterWidget(LocationSection widget) {
    widget.entry.metadataChangeNotifier.removeListener(_handleChange);
    widget.entry.addressChangeNotifier.removeListener(_handleChange);
  }

  @override
  Widget build(BuildContext context) {
    if (!entry.hasGps) return SizedBox();
    final latLng = entry.latLng!;
    final geoUri = entry.geoUri!;

    final filters = <LocationFilter>[];
    if (entry.hasAddress) {
      final address = entry.addressDetails!;
      final country = address.countryName;
      if (country != null && country.isNotEmpty) filters.add(LocationFilter(LocationLevel.country, '$country${LocationFilter.locationSeparator}${address.countryCode}'));
      final place = address.place;
      if (place != null && place.isNotEmpty) filters.add(LocationFilter(LocationLevel.place, place));
    }

    Widget buildMarker(BuildContext context) => ImageMarker(
          entry: entry,
          extent: extent,
          pointerSize: pointerSize,
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.showTitle) SectionRow(AIcons.location),
        FutureBuilder<bool>(
          future: availability.isConnected,
          builder: (context, snapshot) {
            if (snapshot.data != true) return SizedBox();
            return Selector<Settings, EntryMapStyle>(
              selector: (context, s) => s.infoMapStyle,
              builder: (context, mapStyle, child) {
                final isGoogleMaps = mapStyle.isGoogleMaps;
                return AnimatedSize(
                  alignment: Alignment.topCenter,
                  curve: Curves.easeInOutCubic,
                  duration: Durations.mapStyleSwitchAnimation,
                  vsync: this,
                  child: ValueListenableBuilder<bool>(
                    valueListenable: widget.isScrollingNotifier,
                    builder: (context, scrolling, child) {
                      if (!scrolling && isGoogleMaps) {
                        _googleMapsLoaded = true;
                      }
                      return Visibility(
                        visible: !isGoogleMaps || _googleMapsLoaded,
                        replacement: Stack(
                          children: [
                            MapDecorator(),
                            MapButtonPanel(
                              geoUri: geoUri,
                              zoomBy: (_) {},
                            ),
                          ],
                        ),
                        child: child!,
                      );
                    },
                    child: isGoogleMaps
                        ? EntryGoogleMap(
                            // `LatLng` used by `google_maps_flutter` is not the one from `latlong` package
                            latLng: Tuple2<double, double>(latLng.latitude, latLng.longitude),
                            geoUri: geoUri,
                            initialZoom: settings.infoMapZoom,
                            markerId: entry.uri,
                            markerBuilder: buildMarker,
                          )
                        : EntryLeafletMap(
                            latLng: latLng,
                            geoUri: geoUri,
                            initialZoom: settings.infoMapZoom,
                            style: settings.infoMapStyle,
                            markerSize: Size(
                              extent + ImageMarker.outerBorderWidth * 2,
                              extent + ImageMarker.outerBorderWidth * 2 + pointerSize.height,
                            ),
                            markerBuilder: buildMarker,
                          ),
                  ),
                );
              },
            );
          },
        ),
        _AddressInfoGroup(entry: entry),
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
  }

  void _handleChange() => setState(() {});
}

class _AddressInfoGroup extends StatefulWidget {
  final AvesEntry entry;

  const _AddressInfoGroup({required this.entry});

  @override
  _AddressInfoGroupState createState() => _AddressInfoGroupState();
}

class _AddressInfoGroupState extends State<_AddressInfoGroup> {
  late Future<String?> _addressLineLoader;

  AvesEntry get entry => widget.entry;

  @override
  void initState() {
    super.initState();
    _addressLineLoader = availability.canLocatePlaces.then((connected) {
      if (connected) {
        return entry.findAddressLine();
      }
      return null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _addressLineLoader,
      builder: (context, snapshot) {
        final fullAddress = !snapshot.hasError && snapshot.connectionState == ConnectionState.done ? snapshot.data : null;
        final address = fullAddress ?? entry.shortAddress;
        final l10n = context.l10n;
        return InfoRowGroup({
          l10n.viewerInfoLabelCoordinates: settings.coordinateFormat.format(entry.latLng!),
          if (address.isNotEmpty) l10n.viewerInfoLabelAddress: address,
        });
      },
    );
  }
}
