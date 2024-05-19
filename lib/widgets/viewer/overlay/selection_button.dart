import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/selection.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/theme/text.dart';
import 'package:aves/widgets/common/basic/text/animated_diff.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/identity/buttons/overlay_button.dart';
import 'package:aves/widgets/viewer/overlay/bottom.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SelectionButton extends StatelessWidget {
  final AvesEntry mainEntry;
  final Animation<double> scale;

  static const double padding = 8;
  static const duration = ADurations.thumbnailOverlayAnimation;

  const SelectionButton({
    super.key,
    required this.mainEntry,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final selection = context.read<Selection<AvesEntry>>();
    return SafeArea(
      top: false,
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.only(left: padding, right: padding, bottom: padding),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          textDirection: ViewerBottomOverlay.actionsDirection,
          children: [
            const Spacer(),
            ScalingOverlayTextButton(
              scale: scale,
              onPressed: () => selection.toggleSelection(mainEntry),
              child: Selector<Selection<AvesEntry>?, int>(
                selector: (context, selection) => selection?.selectedItems.length ?? 0,
                builder: (context, count, child) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    textDirection: ViewerBottomOverlay.actionsDirection,
                    children: [
                      AnimatedDiffText(
                        count == 0 ? l10n.collectionSelectPageTitle : l10n.itemCount(count),
                        duration: duration,
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Text(AText.separator),
                      ),
                      Selector<Selection<AvesEntry>, bool>(
                        selector: (context, selection) => selection.isSelected({mainEntry}),
                        builder: (context, isSelected, child) {
                          return AnimatedSwitcher(
                            duration: duration,
                            switchInCurve: Curves.easeOutBack,
                            switchOutCurve: Curves.easeOutBack,
                            transitionBuilder: (child, animation) => ScaleTransition(
                              scale: animation,
                              child: child,
                            ),
                            child: Icon(
                              isSelected ? AIcons.selected : AIcons.unselected,
                              key: ValueKey(isSelected),
                            ),
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
