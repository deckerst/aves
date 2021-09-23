import 'package:aves/model/entry.dart';
import 'package:aves/model/settings/coordinate_format.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/services/geocoding_service.dart';
import 'package:aves/theme/format.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/utils/constants.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/map/marker.dart';
import 'package:decorated_icon/decorated_icon.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MapInfoRow extends StatelessWidget {
  final ValueNotifier<AvesEntry?> entryNotifier;

  static const double iconPadding = 8.0;
  static const double iconSize = 16.0;
  static const double _interRowPadding = 2.0;

  const MapInfoRow({
    Key? key,
    required this.entryNotifier,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final orientation = context.select<MediaQueryData, Orientation>((v) => v.orientation);

    return ValueListenableBuilder<AvesEntry?>(
      valueListenable: entryNotifier,
      builder: (context, entry, child) {
        final content = orientation == Orientation.portrait
            ? [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _AddressRow(entry: entry),
                      const SizedBox(height: _interRowPadding),
                      _buildDate(context, entry),
                    ],
                  ),
                ),
              ]
            : [
                _buildDate(context, entry),
                Expanded(
                  child: _AddressRow(entry: entry),
                ),
              ];

        return Opacity(
          opacity: entry != null ? 1 : 0,
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

  Widget _buildDate(BuildContext context, AvesEntry? entry) {
    final locale = context.l10n.localeName;
    final date = entry?.bestDate;
    final dateText = date != null ? formatDateTime(date, locale) : Constants.overlayUnknown;
    return Row(
      children: [
        const SizedBox(width: iconPadding),
        const DecoratedIcon(AIcons.date, shadows: Constants.embossShadows, size: iconSize),
        const SizedBox(width: iconPadding),
        Text(
          dateText,
          strutStyle: Constants.overflowStrutStyle,
        ),
      ],
    );
  }
}

class _AddressRow extends StatefulWidget {
  final AvesEntry? entry;

  const _AddressRow({
    Key? key,
    required this.entry,
  }) : super(key: key);

  @override
  _AddressRowState createState() => _AddressRowState();
}

class _AddressRowState extends State<_AddressRow> {
  final ValueNotifier<String?> _addressLineNotifier = ValueNotifier(null);

  @override
  void didUpdateWidget(covariant _AddressRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    final entry = widget.entry;
    if (oldWidget.entry != entry) {
      _getAddressLine(entry).then((addressLine) {
        if (mounted && entry == widget.entry) {
          _addressLineNotifier.value = addressLine;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final entry = widget.entry;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(width: MapInfoRow.iconPadding),
        const DecoratedIcon(AIcons.location, shadows: Constants.embossShadows, size: MapInfoRow.iconSize),
        const SizedBox(width: MapInfoRow.iconPadding),
        Expanded(
          child: ValueListenableBuilder<String?>(
            valueListenable: _addressLineNotifier,
            builder: (context, addressLine, child) {
              final location = addressLine ??
                  (entry == null
                      ? Constants.overlayUnknown
                      : entry.hasAddress
                          ? entry.shortAddress
                          : settings.coordinateFormat.format(entry.latLng!));
              return Text(
                location,
                strutStyle: Constants.overflowStrutStyle,
                softWrap: false,
                overflow: TextOverflow.fade,
                maxLines: 1,
              );
            },
          ),
        ),
      ],
    );
  }

  Future<String?> _getAddressLine(AvesEntry? entry) async {
    if (entry != null && await availability.canLocatePlaces) {
      final addresses = await GeocodingService.getAddress(entry.latLng!, entry.geocoderLocale);
      if (addresses.isNotEmpty) {
        final address = addresses.first;
        return address.addressLine;
      }
    }
    return null;
  }
}
