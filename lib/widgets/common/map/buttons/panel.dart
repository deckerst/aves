import 'package:aves/model/settings/enums/map_style.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/map/buttons/button.dart';
import 'package:aves/widgets/common/map/buttons/coordinate_filter.dart';
import 'package:aves/widgets/common/map/compass.dart';
import 'package:aves/widgets/dialogs/aves_selection_dialog.dart';
import 'package:aves_map/aves_map.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

class MapButtonPanel extends StatelessWidget {
  final ValueNotifier<ZoomedBounds> boundsNotifier;
  final Future<void> Function(double amount)? zoomBy;
  final void Function(BuildContext context)? openMapPage;
  final VoidCallback? resetRotation;

  const MapButtonPanel({
    super.key,
    required this.boundsNotifier,
    this.zoomBy,
    this.openMapPage,
    this.resetRotation,
  });

  @override
  Widget build(BuildContext context) {
    final iconTheme = IconTheme.of(context);
    final iconSize = Size.square(iconTheme.size!);

    Widget? navigationButton;
    switch (context.select<MapThemeData, MapNavigationButton>((v) => v.navigationButton)) {
      case MapNavigationButton.back:
        navigationButton = MapOverlayButton(
          icon: const BackButtonIcon(),
          onPressed: () => Navigator.pop(context),
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
        );
        break;
      case MapNavigationButton.map:
        if (openMapPage != null) {
          navigationButton = MapOverlayButton(
            icon: const Icon(AIcons.map),
            onPressed: () => openMapPage?.call(context),
            tooltip: context.l10n.openMapPageTooltip,
          );
        }
        break;
    }

    final showCoordinateFilter = context.select<MapThemeData, bool>((v) => v.showCoordinateFilter);
    final visualDensity = context.select<MapThemeData, VisualDensity?>((v) => v.visualDensity);
    final double padding = visualDensity == VisualDensity.compact ? 4 : 8;

    return Positioned.fill(
      child: TooltipTheme(
        data: TooltipTheme.of(context).copyWith(
          preferBelow: false,
        ),
        child: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              Positioned(
                left: padding,
                right: padding,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: padding),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (navigationButton != null) ...[
                            navigationButton,
                            SizedBox(height: padding),
                          ],
                          ValueListenableBuilder<ZoomedBounds>(
                            valueListenable: boundsNotifier,
                            builder: (context, bounds, child) {
                              final degrees = bounds.rotation;
                              final opacity = degrees == 0 ? .0 : 1.0;
                              final animationDuration = context.select<DurationsData, Duration>((v) => v.viewerOverlayAnimation);
                              return IgnorePointer(
                                ignoring: opacity == 0,
                                child: AnimatedOpacity(
                                  opacity: opacity,
                                  duration: animationDuration,
                                  child: MapOverlayButton(
                                    icon: Transform(
                                      origin: iconSize.center(Offset.zero),
                                      transform: Matrix4.rotationZ(degToRadian(degrees)),
                                      child: CustomPaint(
                                        painter: CompassPainter(
                                          color: iconTheme.color!,
                                        ),
                                        size: iconSize,
                                      ),
                                    ),
                                    onPressed: () => resetRotation?.call(),
                                    tooltip: context.l10n.mapPointNorthUpTooltip,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    showCoordinateFilter
                        ? Expanded(
                            child: OverlayCoordinateFilterChip(
                              boundsNotifier: boundsNotifier,
                              padding: padding,
                            ),
                          )
                        : const Spacer(),
                    Padding(
                      padding: EdgeInsets.only(top: padding),
                      child: MapOverlayButton(
                        // key is expected by test driver
                        buttonKey: const Key('map-menu-layers'),
                        icon: const Icon(AIcons.layers),
                        onPressed: () => showSelectionDialog<EntryMapStyle>(
                          context: context,
                          builder: (context) => AvesSelectionDialog<EntryMapStyle>(
                            initialValue: settings.mapStyle,
                            options: Map.fromEntries(availability.mapStyles.map((v) => MapEntry(v, v.getName(context)))),
                            title: context.l10n.mapStyleDialogTitle,
                          ),
                          onSelection: (v) => settings.mapStyle = v,
                        ),
                        tooltip: context.l10n.mapStyleTooltip,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                right: padding,
                bottom: padding,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    MapOverlayButton(
                      icon: const Icon(AIcons.zoomIn),
                      onPressed: zoomBy != null ? () => zoomBy?.call(1) : null,
                      tooltip: context.l10n.mapZoomInTooltip,
                    ),
                    SizedBox(height: padding),
                    MapOverlayButton(
                      icon: const Icon(AIcons.zoomOut),
                      onPressed: zoomBy != null ? () => zoomBy?.call(-1) : null,
                      tooltip: context.l10n.mapZoomOutTooltip,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
