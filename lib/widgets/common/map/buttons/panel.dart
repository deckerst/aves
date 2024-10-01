import 'package:aves/model/settings/settings.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/view/view.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/map/buttons/button.dart';
import 'package:aves/widgets/common/map/buttons/coordinate_filter.dart';
import 'package:aves/widgets/common/map/compass.dart';
import 'package:aves/widgets/common/map/map_action_delegate.dart';
import 'package:aves_map/aves_map.dart';
import 'package:aves_model/aves_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

class MapButtonPanel extends StatelessWidget {
  final AvesMapController? controller;
  final ValueNotifier<ZoomedBounds> boundsNotifier;
  final void Function(BuildContext context)? openMapPage;
  final VoidCallback? resetRotation;

  const MapButtonPanel({
    super.key,
    required this.controller,
    required this.boundsNotifier,
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
        if (!settings.useTvLayout) {
          navigationButton = MapOverlayButton(
            icon: const BackButtonIcon(),
            onPressed: () => Navigator.maybeOf(context)?.pop(),
            tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          );
        }
      case MapNavigationButton.close:
        navigationButton = MapOverlayButton(
          icon: const CloseButtonIcon(),
          onPressed: SystemNavigator.pop,
          tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
        );
      case MapNavigationButton.map:
        if (openMapPage != null) {
          navigationButton = MapOverlayButton(
            icon: const Icon(AIcons.map),
            onPressed: () => openMapPage?.call(context),
            tooltip: context.l10n.openMapPageTooltip,
          );
        }
      case MapNavigationButton.none:
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
                              return IgnorePointer(
                                ignoring: opacity == 0,
                                child: AnimatedOpacity(
                                  opacity: opacity,
                                  duration: context.select<DurationsData, Duration>((v) => v.viewerOverlayAnimation),
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
                      // key is expected by test driver
                      child: Column(
                        children: [
                          _buildButton(context, MapAction.selectStyle, buttonKey: const Key('map-menu-layers')),
                          SizedBox(height: padding),
                          _buildButton(context, MapAction.openMapApp),
                        ],
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
                    _buildButton(context, MapAction.zoomIn),
                    SizedBox(height: padding),
                    _buildButton(context, MapAction.zoomOut),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context, MapAction action, {Key? buttonKey}) => MapOverlayButton(
        buttonKey: buttonKey,
        icon: action.getIcon(),
        onPressed: () => MapActionDelegate(controller).onActionSelected(context, action),
        tooltip: action.getText(context),
      );
}
