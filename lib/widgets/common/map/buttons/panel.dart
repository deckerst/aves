import 'package:aves/model/settings/enums/accessibility_animations.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/view/view.dart';
import 'package:aves/widgets/common/basic/popup/menu_row.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/map/buttons/button.dart';
import 'package:aves/widgets/common/map/buttons/coordinate_filter.dart';
import 'package:aves/widgets/common/map/compass.dart';
import 'package:aves/widgets/common/map/map_action_delegate.dart';
import 'package:aves/widgets/common/providers/map_theme_provider.dart';
import 'package:aves_map/aves_map.dart';
import 'package:aves_model/aves_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

class MapButtonPanel extends StatefulWidget {
  final AvesMapController controller;
  final ValueNotifier<ZoomedBounds> boundsNotifier;
  final void Function(BuildContext context)? openMapPage;

  const MapButtonPanel({
    super.key,
    required this.controller,
    required this.boundsNotifier,
    this.openMapPage,
  });

  @override
  State<MapButtonPanel> createState() => _MapButtonPanelState();
}

class _MapButtonPanelState extends State<MapButtonPanel> {
  late MapActionDelegate _actionDelegate;

  @override
  void initState() {
    super.initState();
    _updateDelegate();
  }

  @override
  void didUpdateWidget(covariant MapButtonPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateDelegate();
  }

  void _updateDelegate() => _actionDelegate = MapActionDelegate(widget.controller);

  @override
  Widget build(BuildContext context) {
    final showCoordinateFilter = context.select<MapThemeData, bool>((v) => v.showCoordinateFilter);
    final visualDensity = context.select<MapThemeData, VisualDensity>((v) => v.visualDensity);
    final double padding = 8 + visualDensity.horizontal * 2;

    Widget? topLeftButton = _buildNavigationButton(context);
    Widget? topRightButton = _buildTopRightButton(context);

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
                          if (topLeftButton != null) ...[
                            topLeftButton,
                            SizedBox(height: padding),
                          ],
                          _buildCompass(context),
                        ],
                      ),
                    ),
                    showCoordinateFilter
                        ? Expanded(
                            child: OverlayCoordinateFilterChip(
                              boundsNotifier: widget.boundsNotifier,
                              padding: padding,
                            ),
                          )
                        : const Spacer(),
                    Padding(
                      padding: EdgeInsets.only(top: padding),
                      // key is expected by test driver
                      child: Column(
                        children: [
                          if (topRightButton != null) ...[
                            topRightButton,
                            SizedBox(height: padding),
                          ],
                          // key is expected by test driver
                          _buildActionButton(context, MapAction.selectStyle, buttonKey: const Key('map-menu-layers')),
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
                    _buildActionButton(context, MapAction.zoomIn),
                    SizedBox(height: padding),
                    _buildActionButton(context, MapAction.zoomOut),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget? _buildNavigationButton(BuildContext context) {
    Widget? child;
    switch (context.select<MapThemeData, MapNavigationButton>((v) => v.navigationButton)) {
      case MapNavigationButton.back:
        if (!settings.useTvLayout) {
          child = MapOverlayButton.icon(
            icon: const BackButtonIcon(),
            onPressed: () => Navigator.maybeOf(context)?.pop(),
            tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          );
        }
      case MapNavigationButton.close:
        child = MapOverlayButton.icon(
          icon: const CloseButtonIcon(),
          onPressed: SystemNavigator.pop,
          tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
        );
      case MapNavigationButton.map:
        final _openMapPage = widget.openMapPage;
        if (_openMapPage != null) {
          child = MapOverlayButton.icon(
            icon: const Icon(AIcons.showFullscreenCorners),
            onPressed: () => _openMapPage.call(context),
            tooltip: context.l10n.openMapPageTooltip,
          );
        }
      case MapNavigationButton.none:
        break;
    }
    if (child != null) {
      child = _heroify(context, 'top-left', child);
    }
    return child;
  }

  Widget? _buildTopRightButton(BuildContext context) {
    const heroTag = 'top-right';

    final actions = [
      MapAction.openMapApp,
      MapAction.addShortcut,
    ].where((action) => _actionDelegate.isVisible(context, action)).toList();

    Widget? child;
    if (actions.length == 1) {
      child = _buildActionButton(context, actions.first, heroTag: heroTag);
    } else if (actions.length > 1) {
      child = MapOverlayButton(builder: (context, visualDensity, child) {
        final animations = context.read<Settings>().accessibilityAnimations;
        return PopupMenuButton<MapAction>(
          itemBuilder: (context) => actions
              .map((action) => PopupMenuItem(
                    value: action,
                    child: MenuRow(
                      text: action.getText(context),
                      icon: action.getIcon(),
                    ),
                  ))
              .toList(),
          onSelected: (action) async {
            // wait for the popup menu to hide before proceeding with the action
            await Future.delayed(animations.popUpAnimationDelay * timeDilation);
            _actionDelegate.onActionSelected(context, action);
          },
          iconSize: MapOverlayButton.iconSize(visualDensity),
          popUpAnimationStyle: animations.popUpAnimationStyle,
        );
      });
      child = _heroify(context, heroTag, child);
    }
    return child;
  }

  Widget _buildCompass(BuildContext context) {
    final iconTheme = IconTheme.of(context);
    final iconSize = Size.square(iconTheme.size!);
    return ValueListenableBuilder<ZoomedBounds>(
      valueListenable: widget.boundsNotifier,
      builder: (context, bounds, child) {
        final degrees = bounds.rotation;
        final opacity = degrees == 0 ? .0 : 1.0;
        return IgnorePointer(
          ignoring: opacity == 0,
          child: AnimatedOpacity(
            opacity: opacity,
            duration: context.select<DurationsData, Duration>((v) => v.viewerOverlayAnimation),
            child: MapOverlayButton.icon(
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
              onPressed: widget.controller.resetRotation,
              tooltip: context.l10n.mapPointNorthUpTooltip,
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButton(BuildContext context, MapAction action, {Key? buttonKey, String? heroTag}) {
    final child = MapOverlayButton.icon(
      buttonKey: buttonKey,
      icon: action.getIcon(),
      onPressed: () => _actionDelegate.onActionSelected(context, action),
      tooltip: action.getText(context),
    );
    return _heroify(context, heroTag ?? action.name, child);
  }

  Widget _heroify(BuildContext context, String? tag, Widget child) {
    if (tag != null) {
      final animate = context.select<Settings, bool>((v) => v.animate);
      if (animate) {
        return Hero(
          tag: 'map-button-$tag',
          flightShuttleBuilder: MapTheme.heroFlightShuttleBuilder,
          child: child,
        );
      }
    }
    return child;
  }
}
