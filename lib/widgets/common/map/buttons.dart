import 'package:aves/model/settings/enums.dart';
import 'package:aves/model/settings/map_style.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/fx/blurred.dart';
import 'package:aves/widgets/common/fx/borders.dart';
import 'package:aves/widgets/common/map/compass.dart';
import 'package:aves/widgets/common/map/theme.dart';
import 'package:aves/widgets/common/map/zoomed_bounds.dart';
import 'package:aves/widgets/dialogs/aves_selection_dialog.dart';
import 'package:aves/widgets/viewer/overlay/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

typedef MapOpener = void Function(BuildContext context);

class MapButtonPanel extends StatelessWidget {
  final ValueNotifier<ZoomedBounds> boundsNotifier;
  final Future<void> Function(double amount)? zoomBy;
  final MapOpener? openMapPage;
  final VoidCallback? resetRotation;

  const MapButtonPanel({
    Key? key,
    required this.boundsNotifier,
    this.zoomBy,
    this.openMapPage,
    this.resetRotation,
  }) : super(key: key);

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

    final visualDensity = context.select<MapThemeData, VisualDensity?>((v) => v.visualDensity);
    final double padding = visualDensity == VisualDensity.compact ? 4 : 8;

    return Positioned.fill(
      child: Align(
        alignment: AlignmentDirectional.centerEnd,
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: TooltipTheme(
            data: TooltipTheme.of(context).copyWith(
              preferBelow: false,
            ),
            child: SafeArea(
              bottom: false,
              child: Stack(
                children: [
                  Positioned(
                    left: 0,
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
                            return IgnorePointer(
                              ignoring: opacity == 0,
                              child: AnimatedOpacity(
                                opacity: opacity,
                                duration: Durations.viewerOverlayAnimation,
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
                  Positioned(
                    right: 0,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        MapOverlayButton(
                          icon: const Icon(AIcons.layers),
                          onPressed: () async {
                            final hasPlayServices = await availability.hasPlayServices;
                            final availableStyles = EntryMapStyle.values.where((style) => !style.isGoogleMaps || hasPlayServices);
                            final preferredStyle = settings.infoMapStyle;
                            final initialStyle = availableStyles.contains(preferredStyle) ? preferredStyle : availableStyles.first;
                            final style = await showDialog<EntryMapStyle>(
                              context: context,
                              builder: (context) {
                                return AvesSelectionDialog<EntryMapStyle>(
                                  initialValue: initialStyle,
                                  options: Map.fromEntries(availableStyles.map((v) => MapEntry(v, v.getName(context)))),
                                  title: context.l10n.mapStyleTitle,
                                );
                              },
                            );
                            // wait for the dialog to hide as applying the change may block the UI
                            await Future.delayed(Durations.dialogTransitionAnimation * timeDilation);
                            if (style != null && style != settings.infoMapStyle) {
                              settings.infoMapStyle = style;
                            }
                          },
                          tooltip: context.l10n.mapStyleTooltip,
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
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
        ),
      ),
    );
  }
}

class MapOverlayButton extends StatelessWidget {
  final Widget icon;
  final String tooltip;
  final VoidCallback? onPressed;

  const MapOverlayButton({
    Key? key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final blurred = settings.enableOverlayBlurEffect;
    return Selector<MapThemeData, Animation<double>>(
      selector: (context, v) => v.scale,
      builder: (context, scale, child) => ScaleTransition(
        scale: scale,
        child: child,
      ),
      child: BlurredOval(
        enabled: blurred,
        child: Material(
          type: MaterialType.circle,
          color: overlayBackgroundColor(blurred: blurred),
          child: Ink(
            decoration: BoxDecoration(
              border: AvesBorder.border,
              shape: BoxShape.circle,
            ),
            child: Selector<MapThemeData, VisualDensity?>(
              selector: (context, v) => v.visualDensity,
              builder: (context, visualDensity, child) => IconButton(
                iconSize: 20,
                visualDensity: visualDensity,
                icon: icon,
                onPressed: onPressed,
                tooltip: tooltip,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
