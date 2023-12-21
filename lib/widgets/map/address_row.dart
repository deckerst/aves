import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/entry/extensions/location.dart';
import 'package:aves/model/settings/enums/coordinate_format.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/services/geocoding_service.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/theme/text.dart';
import 'package:flutter/material.dart';

import 'info_row.dart';

class MapAddressRow extends StatefulWidget {
  final AvesEntry? entry;

  const MapAddressRow({
    super.key,
    required this.entry,
  });

  @override
  State<MapAddressRow> createState() => _MapAddressRowState();
}

class _MapAddressRowState extends State<MapAddressRow> {
  final ValueNotifier<String?> _addressLineNotifier = ValueNotifier(null);

  @override
  void initState() {
    super.initState();
    _updateAddress();
  }

  @override
  void didUpdateWidget(covariant MapAddressRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.entry != widget.entry) {
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
    return Container(
      alignment: AlignmentDirectional.centerStart,
      // addresses can include non-latin scripts with inconsistent line height,
      // which is especially an issue for relayout/painting of heavy Google map,
      // so we give extra height to give breathing room to the text and stabilize layout
      height: textScaler.scale(Theme.of(context).textTheme.bodyMedium!.fontSize!) * 2,
      child: ValueListenableBuilder<String?>(
        valueListenable: _addressLineNotifier,
        builder: (context, addressLine, child) {
          final entry = widget.entry;
          final location = addressLine ??
              (entry == null
                  ? AText.valueNotAvailable
                  : entry.hasAddress
                      ? entry.shortAddress
                      : settings.coordinateFormat.format(context, entry.latLng!));
          return Text.rich(
            TextSpan(
              children: [
                WidgetSpan(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: MapInfoRow.iconPadding),
                    child: Icon(AIcons.location, size: MapInfoRow.getIconSize(context)),
                  ),
                  alignment: PlaceholderAlignment.middle,
                ),
                TextSpan(text: location),
              ],
            ),
            softWrap: false,
            overflow: TextOverflow.fade,
            maxLines: 1,
          );
        },
      ),
    );
  }

  Future<void> _updateAddress() async {
    final entry = widget.entry;
    final addressLine = await _getAddressLine(entry);
    if (!mounted) return;
    if (entry == widget.entry) {
      _addressLineNotifier.value = addressLine;
    }
  }

  Future<String?> _getAddressLine(AvesEntry? entry) async {
    if (entry != null && await availability.canLocatePlaces) {
      final addresses = await GeocodingService.getAddress(entry.latLng!, settings.appliedLocale);
      if (addresses.isNotEmpty) {
        final address = addresses.first;
        return address.addressLine;
      }
    }
    return null;
  }
}
