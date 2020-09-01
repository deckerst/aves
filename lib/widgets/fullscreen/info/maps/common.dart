import 'package:aves/model/settings.dart';
import 'package:aves/services/android_app_service.dart';
import 'package:aves/widgets/common/aves_selection_dialog.dart';
import 'package:aves/widgets/common/borders.dart';
import 'package:aves/widgets/common/fx/blurred.dart';
import 'package:aves/widgets/common/icons.dart';
import 'package:aves/widgets/fullscreen/info/location_section.dart';
import 'package:aves/widgets/fullscreen/overlay/common.dart';
import 'package:flutter/material.dart';

class MapDecorator extends StatelessWidget {
  final Widget child;

  static const BorderRadius mapBorderRadius = BorderRadius.all(Radius.circular(24)); // to match button circles

  const MapDecorator({@required this.child});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onScaleStart: (details) {
        // absorb scale gesture here to prevent scrolling
        // and triggering by mistake a move to the image page above
      },
      child: ClipRRect(
        borderRadius: mapBorderRadius,
        child: Container(
          color: Colors.white70,
          height: 200,
          child: child,
        ),
      ),
    );
  }
}

class MapButtonPanel extends StatelessWidget {
  final String geoUri;
  final void Function(double amount) zoomBy;

  static const double padding = 4;

  const MapButtonPanel({
    @required this.geoUri,
    @required this.zoomBy,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Align(
        alignment: AlignmentDirectional.centerEnd,
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: TooltipTheme(
            data: TooltipTheme.of(context).copyWith(
              preferBelow: false,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                MapOverlayButton(
                  icon: AIcons.openInNew,
                  onPressed: () => AndroidAppService.openMap(geoUri),
                  tooltip: 'Show on map...',
                ),
                SizedBox(height: padding),
                MapOverlayButton(
                  icon: AIcons.layers,
                  onPressed: () async {
                    final style = await showDialog<EntryMapStyle>(
                      context: context,
                      builder: (context) => AvesSelectionDialog<EntryMapStyle>(
                        initialValue: settings.infoMapStyle,
                        options: Map.fromEntries(EntryMapStyle.values.map((v) => MapEntry(v, v.name))),
                        title: 'Map Style',
                      ),
                    );
                    if (style != null) {
                      settings.infoMapStyle = style;
                      MapStyleChangedNotification().dispatch(context);
                    }
                  },
                  tooltip: 'Style map...',
                ),
                Spacer(),
                MapOverlayButton(
                  icon: AIcons.zoomIn,
                  onPressed: () => zoomBy(1),
                  tooltip: 'Zoom in',
                ),
                SizedBox(height: padding),
                MapOverlayButton(
                  icon: AIcons.zoomOut,
                  onPressed: () => zoomBy(-1),
                  tooltip: 'Zoom out',
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
  final VoidCallback onPressed;

  const MapOverlayButton({
    @required this.icon,
    @required this.tooltip,
    @required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return BlurredOval(
      child: Material(
        type: MaterialType.circle,
        color: kOverlayBackgroundColor,
        child: Ink(
          decoration: BoxDecoration(
            border: AvesCircleBorder.build(context),
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

class MapStyleChangedNotification extends Notification {}
