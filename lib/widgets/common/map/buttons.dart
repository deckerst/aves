import 'package:aves/model/settings/enums.dart';
import 'package:aves/model/settings/map_style.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/services/android_app_service.dart';
import 'package:aves/services/services.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/fx/blurred.dart';
import 'package:aves/widgets/common/fx/borders.dart';
import 'package:aves/widgets/dialogs/aves_dialog.dart';
import 'package:aves/widgets/dialogs/aves_selection_dialog.dart';
import 'package:aves/widgets/viewer/overlay/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:latlong2/latlong.dart';

class MapButtonPanel extends StatelessWidget {
  final LatLng latLng;
  final Future<void> Function(double amount)? zoomBy;

  static const double padding = 4;

  const MapButtonPanel({
    Key? key,
    required this.latLng,
    this.zoomBy,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Align(
        alignment: AlignmentDirectional.centerEnd,
        child: Padding(
          padding: const EdgeInsets.all(padding),
          child: TooltipTheme(
            data: TooltipTheme.of(context).copyWith(
              preferBelow: false,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                MapOverlayButton(
                  icon: AIcons.openOutside,
                  onPressed: () => AndroidAppService.openMap(latLng).then((success) {
                    if (!success) showNoMatchingAppDialog(context);
                  }),
                  tooltip: context.l10n.entryActionOpenMap,
                ),
                const SizedBox(height: padding),
                MapOverlayButton(
                  icon: AIcons.layers,
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
                const Spacer(),
                MapOverlayButton(
                  icon: AIcons.zoomIn,
                  onPressed: zoomBy != null ? () => zoomBy!(1) : null,
                  tooltip: context.l10n.viewerInfoMapZoomInTooltip,
                ),
                const SizedBox(height: padding),
                MapOverlayButton(
                  icon: AIcons.zoomOut,
                  onPressed: zoomBy != null ? () => zoomBy!(-1) : null,
                  tooltip: context.l10n.viewerInfoMapZoomOutTooltip,
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
  final IconData icon;
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
            icon: Icon(icon),
            onPressed: onPressed,
            tooltip: tooltip,
          ),
        ),
      ),
    );
  }
}
