import 'package:aves/model/entry.dart';
import 'package:aves/model/filters/location.dart';
import 'package:aves/model/settings/enums/coordinate_format.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/identity/aves_filter_chip.dart';
import 'package:aves/widgets/common/map/controller.dart';
import 'package:aves/widgets/common/map/geo_map.dart';
import 'package:aves/widgets/common/map/theme.dart';
import 'package:aves/widgets/map/map_page.dart';
import 'package:aves/widgets/viewer/info/common.dart';
import 'package:flutter/material.dart';

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

class _LocationSectionState extends State<LocationSection> {
  final AvesMapController _mapController = AvesMapController();

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
    widget.entry.metadataChangeNotifier.addListener(_onMetadataChange);
  }

  void _unregisterWidget(LocationSection widget) {
    widget.entry.metadataChangeNotifier.removeListener(_onMetadataChange);
  }

  @override
  Widget build(BuildContext context) {
    if (!entry.hasGps) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.showTitle) const SectionRow(icon: AIcons.location),
        MapTheme(
          interactive: false,
          showCoordinateFilter: false,
          navigationButton: MapNavigationButton.map,
          visualDensity: VisualDensity.compact,
          mapHeight: 200,
          child: GeoMap(
            controller: _mapController,
            entries: [entry],
            isAnimatingNotifier: widget.isScrollingNotifier,
            onUserZoomChange: (zoom) => settings.infoMapZoom = zoom,
            onMarkerTap: collection != null ? (_, __, ___) => _openMapPage(context) : null,
            openMapPage: collection != null ? _openMapPage : null,
          ),
        ),
        AnimatedBuilder(
          animation: entry.addressChangeNotifier,
          builder: (context, child) {
            final filters = <LocationFilter>[];
            if (entry.hasAddress) {
              final address = entry.addressDetails!;
              final country = address.countryName;
              if (country != null && country.isNotEmpty) filters.add(LocationFilter(LocationLevel.country, '$country${LocationFilter.locationSeparator}${address.countryCode}'));
              final place = address.place;
              if (place != null && place.isNotEmpty) filters.add(LocationFilter(LocationLevel.place, place));
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _AddressInfoGroup(entry: entry),
                if (filters.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AvesFilterChip.outlineWidth / 2) + const EdgeInsets.only(top: 8),
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
          },
        ),
      ],
    );
  }

  void _openMapPage(BuildContext context) {
    final baseCollection = collection;
    if (baseCollection == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        settings: const RouteSettings(name: MapPage.routeName),
        builder: (context) => MapPage(
          collection: baseCollection.copyWith(
            listenToSource: true,
            fixedSelection: baseCollection.sortedEntries.where((entry) => entry.hasGps).toList(),
          ),
          initialEntry: entry,
        ),
      ),
    );
  }

  void _onMetadataChange() {
    setState(() {});

    final location = entry.latLng;
    if (location != null) {
      _mapController.notifyMarkerLocationChange();
      _mapController.moveTo(location);
    }
  }
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
        return entry.findAddressLine(geocoderLocale: settings.appliedLocale);
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
        return InfoRowGroup(
          info: {
            l10n.viewerInfoLabelCoordinates: settings.coordinateFormat.format(l10n, entry.latLng!),
            if (address.isNotEmpty) l10n.viewerInfoLabelAddress: address,
          },
        );
      },
    );
  }
}
