import 'package:aves/model/filters/coordinate.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/theme/themes.dart';
import 'package:aves/utils/debouncer.dart';
import 'package:aves/widgets/common/fx/blurred.dart';
import 'package:aves/widgets/common/identity/aves_filter_chip.dart';
import 'package:aves/widgets/viewer/controls/notifications.dart';
import 'package:aves_map/aves_map.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OverlayCoordinateFilterChip extends StatefulWidget {
  final ValueNotifier<ZoomedBounds> boundsNotifier;
  final double padding;

  const OverlayCoordinateFilterChip({
    super.key,
    required this.boundsNotifier,
    required this.padding,
  });

  @override
  State<OverlayCoordinateFilterChip> createState() => _OverlayCoordinateFilterChipState();
}

class _OverlayCoordinateFilterChipState extends State<OverlayCoordinateFilterChip> {
  final Debouncer _debouncer = Debouncer(delay: ADurations.mapInfoDebounceDelay);
  final ValueNotifier<ZoomedBounds?> _idleBoundsNotifier = ValueNotifier(null);

  @override
  void initState() {
    super.initState();
    _registerWidget(widget);
  }

  @override
  void didUpdateWidget(covariant OverlayCoordinateFilterChip oldWidget) {
    super.didUpdateWidget(oldWidget);
    _unregisterWidget(oldWidget);
    _registerWidget(widget);
  }

  @override
  void dispose() {
    _unregisterWidget(widget);
    super.dispose();
  }

  void _registerWidget(OverlayCoordinateFilterChip widget) {
    widget.boundsNotifier.addListener(_onBoundsChanged);
  }

  void _unregisterWidget(OverlayCoordinateFilterChip widget) {
    widget.boundsNotifier.removeListener(_onBoundsChanged);
  }

  @override
  Widget build(BuildContext context) {
    final blurred = settings.enableBlurEffect;
    final theme = Theme.of(context);
    return Theme(
      data: theme.copyWith(
        scaffoldBackgroundColor: Themes.overlayBackgroundColor(brightness: theme.brightness, blurred: blurred),
      ),
      child: Align(
        alignment: Alignment.topLeft,
        child: Selector<MapThemeData, Animation<double>>(
          selector: (context, v) => v.scale,
          builder: (context, scale, child) => SizeTransition(
            sizeFactor: scale,
            axisAlignment: 1,
            child: FadeTransition(
              opacity: scale,
              child: child,
            ),
          ),
          child: ValueListenableBuilder<ZoomedBounds?>(
            valueListenable: _idleBoundsNotifier,
            builder: (context, bounds, child) {
              if (bounds == null) return const SizedBox();
              final filter = CoordinateFilter(
                bounds.sw,
                bounds.ne,
                // more stable format when bounds change
                minuteSecondPadding: true,
              );
              return Padding(
                padding: EdgeInsets.all(widget.padding),
                child: BlurredRRect.all(
                  enabled: blurred,
                  borderRadius: AvesFilterChip.defaultRadius,
                  child: AvesFilterChip(
                    filter: filter,
                    useFilterColor: false,
                    maxWidth: double.infinity,
                    onTap: (filter) => FilterSelectedNotification(CoordinateFilter(bounds.sw, bounds.ne)).dispatch(context),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _onBoundsChanged() {
    _debouncer(() => _idleBoundsNotifier.value = widget.boundsNotifier.value);
  }
}
