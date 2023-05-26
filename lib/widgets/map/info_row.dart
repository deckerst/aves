import 'package:aves/model/entry/entry.dart';
import 'package:aves/widgets/map/address_row.dart';
import 'package:aves/widgets/map/date_row.dart';
import 'package:aves_map/aves_map.dart';
import 'package:flutter/material.dart';

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
    return ValueListenableBuilder<AvesEntry?>(
      valueListenable: entryNotifier,
      builder: (context, entry, child) {
        final isPortrait = MediaQuery.orientationOf(context) == Orientation.portrait;
        final content = isPortrait
            ? [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MapAddressRow(entry: entry),
                      const SizedBox(height: _interRowPadding),
                      MapDateRow(entry: entry),
                    ],
                  ),
                ),
              ]
            : [
                MapDateRow(entry: entry),
                Expanded(
                  child: MapAddressRow(entry: entry),
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

  static double getIconSize(BuildContext context) {
    final textScaleFactor = MediaQuery.textScaleFactorOf(context);
    return 16 * textScaleFactor;
  }
}
