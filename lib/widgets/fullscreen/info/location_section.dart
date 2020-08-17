import 'package:aves/model/filters/location.dart';
import 'package:aves/model/image_entry.dart';
import 'package:aves/model/settings.dart';
import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/utils/geo_utils.dart';
import 'package:aves/widgets/common/aves_filter_chip.dart';
import 'package:aves/widgets/common/icons.dart';
import 'package:aves/widgets/fullscreen/info/info_page.dart';
import 'package:aves/widgets/fullscreen/info/maps/common.dart';
import 'package:aves/widgets/fullscreen/info/maps/google_map.dart';
import 'package:aves/widgets/fullscreen/info/maps/leaflet_map.dart';
import 'package:flutter/material.dart';

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

class _LocationSectionState extends State<LocationSection> {
  String _loadedUri;

  CollectionLens get collection => widget.collection;

  ImageEntry get entry => widget.entry;

  @override
  void initState() {
    super.initState();
    _registerWidget(widget);
  }

  @override
  void didUpdateWidget(LocationSection oldWidget) {
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
      var location = '';
      final filters = <LocationFilter>[];
      if (entry.isLocated) {
        final address = entry.addressDetails;
        location = address.addressLine;
        final country = address.countryName;
        if (country != null && country.isNotEmpty) filters.add(LocationFilter(LocationLevel.country, '$country;${address.countryCode}'));
        final place = address.place;
        if (place != null && place.isNotEmpty) filters.add(LocationFilter(LocationLevel.place, place));
      } else if (entry.hasGps) {
        location = toDMS(entry.latLng).join(', ');
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.showTitle)
            Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: SectionRow(AIcons.location),
            ),
          NotificationListener(
            onNotification: (notification) {
              if (notification is MapStyleChangedNotification) setState(() {});
              return false;
            },
            child: settings.infoMapStyle == EntryMapStyle.google
                ? EntryGoogleMap(
                    markerId: entry.uri ?? entry.path,
                    latLng: entry.latLng,
                    geoUri: entry.geoUri,
                    initialZoom: settings.infoMapZoom,
                  )
                : EntryLeafletMap(
                    latLng: entry.latLng,
                    geoUri: entry.geoUri,
                    initialZoom: settings.infoMapZoom,
                    style: settings.infoMapStyle,
                  ),
          ),
          if (location.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(top: 8),
              child: InfoRowGroup({'Address': location}),
            ),
          if (filters.isNotEmpty)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AvesFilterChip.outlineWidth / 2) + EdgeInsets.only(top: 8),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: filters
                    .map((filter) => AvesFilterChip(
                          filter: filter,
                          onPressed: widget.onFilter,
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

// browse providers at https://leaflet-extras.github.io/leaflet-providers/preview/
enum EntryMapStyle { google, osmHot, stamenToner, stamenWatercolor }

extension ExtraEntryMapStyle on EntryMapStyle {
  String get name {
    switch (this) {
      case EntryMapStyle.google:
        return 'Google Maps';
      case EntryMapStyle.osmHot:
        return 'Humanitarian OpenStreetMap';
      case EntryMapStyle.stamenToner:
        return 'Stamen Toner';
      case EntryMapStyle.stamenWatercolor:
        return 'Stamen Watercolor';
      default:
        return toString();
    }
  }
}
