import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/identity/buttons/overlay_button.dart';
import 'package:aves_video/aves_video.dart';
import 'package:material_ui/material_ui.dart';

class const VideoABRepeatOverlay({
  super.key,
  required final AvesVideoController? controller,
  required final Animation<double> scale,
}) extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _VideoABRepeatOverlayState();
}

class _VideoABRepeatOverlayState extends State<VideoABRepeatOverlay> {
  final ValueNotifier<ABRepeat?> _internalAbRepeatNotifier = ValueNotifier(null);

  Animation<double> get scale => widget.scale;

  AvesVideoController? get controller => widget.controller;

  ValueNotifier<ABRepeat?> get abRepeatNotifier => controller?.abRepeatNotifier ?? _internalAbRepeatNotifier;

  @override
  void dispose() {
    _internalAbRepeatNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return ValueListenableBuilder<ABRepeat?>(
      valueListenable: abRepeatNotifier,
      builder: (context, abRepeat, child) {
        if (abRepeat == null) return const SizedBox();

        Widget boundButton;
        if (abRepeat.start == null) {
          boundButton = IconButton(
            icon: const Icon(AIcons.setBoundStart),
            onPressed: controller?.setABRepeatStart,
            tooltip: l10n.videoRepeatActionSetStart,
          );
        } else if (abRepeat.end == null) {
          boundButton = IconButton(
            icon: const Icon(AIcons.setBoundEnd),
            onPressed: controller?.setABRepeatEnd,
            tooltip: l10n.videoRepeatActionSetEnd,
          );
        } else {
          boundButton = IconButton(
            icon: const Icon(AIcons.resetBounds),
            onPressed: controller?.resetABRepeat,
            tooltip: l10n.resetTooltip,
          );
        }
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            mainAxisSize: .min,
            children: [
              const Spacer(),
              OverlayButton(
                scale: scale,
                child: boundButton,
              ),
              const SizedBox(width: 8),
              OverlayButton(
                scale: scale,
                child: IconButton(
                  icon: const Icon(AIcons.repeatOff),
                  onPressed: () => controller?.toggleABRepeat(),
                  tooltip: l10n.stopTooltip,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
