import 'package:aves/model/settings/enums.dart';
import 'package:aves/model/settings/map_style.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/services/android_app_service.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/fx/blurred.dart';
import 'package:aves/widgets/common/fx/borders.dart';
import 'package:aves/widgets/common/map/compass.dart';
import 'package:aves/widgets/common/map/zoomed_bounds.dart';
import 'package:aves/widgets/dialogs/aves_dialog.dart';
import 'package:aves/widgets/dialogs/aves_selection_dialog.dart';
import 'package:aves/widgets/viewer/overlay/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:latlong2/latlong.dart';

class MapButtonPanel extends StatelessWidget {
  final ValueNotifier<ZoomedBounds> boundsNotifier;
  final Future<void> Function(double amount)? zoomBy;
  final VoidCallback? resetRotation;

  static const double padding = 4;

  const MapButtonPanel({
    Key? key,
    required this.boundsNotifier,
    this.zoomBy,
    this.resetRotation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final iconTheme = IconTheme.of(context);
    final iconSize = Size.square(iconTheme.size!);
    return Positioned.fill(
      child: Align(
        alignment: AlignmentDirectional.centerEnd,
        child: Padding(
          padding: const EdgeInsets.all(padding),
          child: TooltipTheme(
            data: TooltipTheme.of(context).copyWith(
              preferBelow: false,
            ),
            child: Stack(
              children: [
                if (resetRotation != null)
                  Positioned(
                    left: 0,
                    child: ValueListenableBuilder<ZoomedBounds>(
                      valueListenable: boundsNotifier,
                      builder: (context, bounds, child) {
                        final degrees = bounds.rotation;
                        return AnimatedOpacity(
                          opacity: degrees == 0 ? 0 : 1,
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
                            tooltip: context.l10n.viewerInfoMapZoomInTooltip,
                          ),
                        );
                      },
                    ),
                  ),
                Positioned(
                  right: 0,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      MapOverlayButton(
                        icon: const Icon(AIcons.openOutside),
                        onPressed: () => AndroidAppService.openMap(boundsNotifier.value.center).then((success) {
                          if (!success) showNoMatchingAppDialog(context);
                        }),
                        tooltip: context.l10n.entryActionOpenMap,
                      ),
                      const SizedBox(height: padding),
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
                                title: context.l10n.viewerInfoMapStyleTitle,
                              );
                            },
                          );
                          // wait for the dialog to hide as applying the change may block the UI
                          await Future.delayed(Durations.dialogTransitionAnimation * timeDilation);
                          if (style != null && style != settings.infoMapStyle) {
                            settings.infoMapStyle = style;
                          }
                        },
                        tooltip: context.l10n.viewerInfoMapStyleTooltip,
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
                        tooltip: context.l10n.viewerInfoMapZoomInTooltip,
                      ),
                      const SizedBox(height: padding),
                      MapOverlayButton(
                        icon: const Icon(AIcons.zoomOut),
                        onPressed: zoomBy != null ? () => zoomBy?.call(-1) : null,
                        tooltip: context.l10n.viewerInfoMapZoomOutTooltip,
                      ),
                    ],
                  ),
                ),
              ],
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
    return BlurredOval(
      enabled: blurred,
      child: Material(
        type: MaterialType.circle,
        color: overlayBackgroundColor(blurred: blurred),
        child: Ink(
          decoration: BoxDecoration(
            border: AvesBorder.border,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            iconSize: 20,
            visualDensity: VisualDensity.compact,
            icon: icon,
            onPressed: onPressed,
            tooltip: tooltip,
          ),
        ),
      ),
    );
  }
}
