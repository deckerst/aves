import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/entry/extensions/location.dart';
import 'package:aves/model/settings/enums/coordinate_format.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/services/geocoding_service.dart';
import 'package:aves/theme/format.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/theme/styles.dart';
import 'package:aves/theme/text.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves_map/aves_map.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MapInfoRow extends StatelessWidget {
  final ValueNotifier<AvesEntry?> entryNotifier;

  static const double iconPadding = 8.0;
  static const double _interRowPadding = 2.0;

  const MapInfoRow({
    super.key,
    required this.entryNotifier,
  });

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
                      _DateRow(entry: entry),
                    ],
                  ),
                ),
              ]
            : [
                _DateRow(entry: entry),
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

  static double getIconSize(BuildContext context) => 16.0 * context.select<MediaQueryData, double>((mq) => mq.textScaleFactor);
}

class _AddressRow extends StatefulWidget {
  final AvesEntry? entry;

  const _AddressRow({
    required this.entry,
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
    if (oldWidget.entry != widget.entry) {
      _updateAddress();
    }
  }

  @override
  Widget build(BuildContext context) {
    final entry = widget.entry;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(width: MapInfoRow.iconPadding),
        Icon(AIcons.location, size: MapInfoRow.getIconSize(context)),
        const SizedBox(width: MapInfoRow.iconPadding),
        Expanded(
          child: Container(
            alignment: AlignmentDirectional.centerStart,
            // addresses can include non-latin scripts with inconsistent line height,
            // which is especially an issue for relayout/painting of heavy Google map,
            // so we give extra height to give breathing room to the text and stabilize layout
            height: Theme.of(context).textTheme.bodyMedium!.fontSize! * context.select<MediaQueryData, double>((mq) => mq.textScaleFactor) * 2,
            child: ValueListenableBuilder<String?>(
              valueListenable: _addressLineNotifier,
              builder: (context, addressLine, child) {
                final location = addressLine ??
                    (entry == null
                        ? AText.valueNotAvailable
                        : entry.hasAddress
                            ? entry.shortAddress
                            : settings.coordinateFormat.format(context.l10n, entry.latLng!));
                return Text(
                  location,
                  strutStyle: AStyles.overflowStrut,
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
    final entry = widget.entry;
    final addressLine = await _getAddressLine(entry);
    if (mounted && entry == widget.entry) {
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

class _DateRow extends StatelessWidget {
  final AvesEntry? entry;

  const _DateRow({
    required this.entry,
  });

  @override
  Widget build(BuildContext context) {
    final locale = context.l10n.localeName;
    final use24hour = context.select<MediaQueryData, bool>((v) => v.alwaysUse24HourFormat);

    final date = entry?.bestDate;
    final dateText = date != null ? formatDateTime(date, locale, use24hour) : AText.valueNotAvailable;
    return Row(
      children: [
        const SizedBox(width: MapInfoRow.iconPadding),
        Icon(AIcons.date, size: MapInfoRow.getIconSize(context)),
        const SizedBox(width: MapInfoRow.iconPadding),
        Expanded(
          child: Text(
            dateText,
            strutStyle: AStyles.overflowStrut,
            softWrap: false,
            overflow: TextOverflow.fade,
            maxLines: 1,
          ),
        ),
      ],
    );
  }
}
