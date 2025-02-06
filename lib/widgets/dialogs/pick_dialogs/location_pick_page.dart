import 'dart:async';

import 'package:aves/model/settings/enums/coordinate_format.dart';
import 'package:aves/model/settings/enums/map_style.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/services/geocoding_service.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/theme/text.dart';
import 'package:aves/utils/debouncer.dart';
import 'package:aves/widgets/common/basic/scaffold.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/identity/buttons/outlined_button.dart';
import 'package:aves/widgets/common/map/geo_map.dart';
import 'package:aves/widgets/common/providers/map_theme_provider.dart';
import 'package:aves_map/aves_map.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:latlong2/latlong.dart';

class LocationPickPage extends StatelessWidget {
  static const routeName = '/location_pick';

  final CollectionLens? collection;
  final LatLng? initialLocation;

  const LocationPickPage({
    super.key,
    required this.collection,
    required this.initialLocation,
  });

  @override
  Widget build(BuildContext context) {
    return AvesScaffold(
      body: SafeArea(
        left: false,
        top: false,
        right: false,
        bottom: true,
        child: _Content(
          collection: collection,
          initialLocation: initialLocation,
        ),
      ),
    );
  }
}

class _Content extends StatefulWidget {
  final CollectionLens? collection;
  final LatLng? initialLocation;

  const _Content({
    required this.collection,
    required this.initialLocation,
  });

  @override
  State<_Content> createState() => _ContentState();
}

class _ContentState extends State<_Content> with SingleTickerProviderStateMixin {
  final List<StreamSubscription> _subscriptions = [];
  final AvesMapController _mapController = AvesMapController();
  late final ValueNotifier<bool> _isPageAnimatingNotifier;
  final ValueNotifier<LatLng?> _dotLocationNotifier = ValueNotifier(null), _infoLocationNotifier = ValueNotifier(null);
  final Debouncer _infoDebouncer = Debouncer(delay: ADurations.mapInfoDebounceDelay);

  CollectionLens? get openingCollection => widget.collection;

  @override
  void initState() {
    super.initState();

    if (ExtraEntryMapStyle.isHeavy(settings.mapStyle)) {
      _isPageAnimatingNotifier = ValueNotifier(true);
      Future.delayed(ADurations.pageTransitionLoose * timeDilation).then((_) {
        if (!mounted) return;
        _isPageAnimatingNotifier.value = false;
      });
    } else {
      _isPageAnimatingNotifier = ValueNotifier(false);
    }

    _dotLocationNotifier.addListener(_updateLocationInfo);

    _subscriptions.add(_mapController.idleUpdates.listen((event) => _onIdle(event.bounds)));
  }

  @override
  void dispose() {
    _subscriptions
      ..forEach((sub) => sub.cancel())
      ..clear();
    _mapController.dispose();
    _isPageAnimatingNotifier.dispose();
    _dotLocationNotifier.dispose();
    _infoLocationNotifier.dispose();
    // provided collection should be a new instance specifically created
    // for the `LocationPickPage` widget, so it can be safely disposed here
    widget.collection?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(child: _buildMap()),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            const Divider(height: 0),
            SafeArea(
              top: false,
              bottom: false,
              child: _LocationInfo(locationNotifier: _infoLocationNotifier),
            ),
            const SizedBox(height: 8),
            AvesOutlinedButton(
              label: context.l10n.locationPickerUseThisLocationButton,
              onPressed: () => Navigator.maybeOf(context)?.pop(_dotLocationNotifier.value),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMap() {
    return MapTheme(
      interactive: true,
      showCoordinateFilter: false,
      navigationButton: MapNavigationButton.back,
      attributionPadding: const EdgeInsets.symmetric(horizontal: 8),
      child: GeoMap(
        controller: _mapController,
        collection: openingCollection,
        availableSize: MediaQuery.sizeOf(context),
        initialCenter: widget.initialLocation,
        isAnimatingNotifier: _isPageAnimatingNotifier,
        dotLocationNotifier: _dotLocationNotifier,
        onMapTap: _setLocation,
        onMarkerTap: (location, entry) => _setLocation(location),
      ),
    );
  }

  void _setLocation(LatLng location) {
    _dotLocationNotifier.value = location;
    _mapController.moveTo(location);
  }

  void _onIdle(ZoomedBounds bounds) {
    _dotLocationNotifier.value = bounds.projectedCenter;
  }

  void _updateLocationInfo() {
    final selectedLocation = _dotLocationNotifier.value;
    if (_infoLocationNotifier.value == null || selectedLocation == null) {
      _infoLocationNotifier.value = selectedLocation;
    } else {
      _infoDebouncer(() => _infoLocationNotifier.value = selectedLocation);
    }
  }
}

class _LocationInfo extends StatelessWidget {
  final ValueNotifier<LatLng?> locationNotifier;

  static const double iconPadding = 8.0;
  static const double _interRowPadding = 2.0;

  const _LocationInfo({
    required this.locationNotifier,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<LatLng?>(
      valueListenable: locationNotifier,
      builder: (context, location, child) {
        final isPortrait = MediaQuery.orientationOf(context) == Orientation.portrait;
        final content = isPortrait
            ? [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _AddressRow(location: location),
                      const SizedBox(height: _interRowPadding),
                      _CoordinateRow(location: location),
                    ],
                  ),
                ),
              ]
            : [
                _CoordinateRow(location: location),
                Expanded(
                  child: _AddressRow(location: location),
                ),
              ];

        return Opacity(
          opacity: location != null ? 1 : 0,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(width: iconPadding),
              const DotMarker(),
              ...content,
            ],
          ),
        );
      },
    );
  }

  static double getIconSize(BuildContext context) {
    final textScaler = MediaQuery.textScalerOf(context);
    return textScaler.scale(16);
  }
}

class _AddressRow extends StatefulWidget {
  final LatLng? location;

  const _AddressRow({
    required this.location,
  });

  @override
  State<_AddressRow> createState() => _AddressRowState();
}

class _AddressRowState extends State<_AddressRow> {
  final ValueNotifier<String?> _addressLineNotifier = ValueNotifier(null);

  @override
  void initState() {
    super.initState();
    _updateAddress();
  }

  @override
  void didUpdateWidget(covariant _AddressRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.location != widget.location) {
      _updateAddress();
    }
  }

  @override
  void dispose() {
    _addressLineNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textScaler = MediaQuery.textScalerOf(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(width: _LocationInfo.iconPadding),
        Icon(AIcons.location, size: _LocationInfo.getIconSize(context)),
        const SizedBox(width: _LocationInfo.iconPadding),
        Expanded(
          child: Container(
            alignment: AlignmentDirectional.centerStart,
            // addresses can include non-latin scripts with inconsistent line height,
            // which is especially an issue for relayout/painting of heavy Google map,
            // so we give extra height to give breathing room to the text and stabilize layout
            height: textScaler.scale(Theme.of(context).textTheme.bodyMedium!.fontSize!) * 2,
            child: ValueListenableBuilder<String?>(
              valueListenable: _addressLineNotifier,
              builder: (context, addressLine, child) {
                return Text(
                  addressLine ?? AText.valueNotAvailable,
                  softWrap: false,
                  overflow: TextOverflow.fade,
                  maxLines: 1,
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _updateAddress() async {
    final location = widget.location;
    final addressLine = await _getAddressLine(location);
    if (!mounted) return;
    if (location == widget.location) {
      _addressLineNotifier.value = addressLine;
    }
  }

  Future<String?> _getAddressLine(LatLng? location) async {
    if (location != null && await availability.canLocatePlaces) {
      final addresses = await GeocodingService.getAddress(location, settings.appliedLocale);
      if (addresses.isNotEmpty) {
        final address = addresses.first;
        return address.addressLine;
      }
    }
    return null;
  }
}

class _CoordinateRow extends StatelessWidget {
  final LatLng? location;

  const _CoordinateRow({
    required this.location,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: _LocationInfo.iconPadding),
        Icon(AIcons.geoBounds, size: _LocationInfo.getIconSize(context)),
        const SizedBox(width: _LocationInfo.iconPadding),
        Expanded(
          child: Text(
            location != null ? settings.coordinateFormat.format(context, location!) : AText.valueNotAvailable,
            softWrap: false,
            overflow: TextOverflow.fade,
            maxLines: 1,
          ),
        ),
      ],
    );
  }
}
