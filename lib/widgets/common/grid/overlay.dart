import 'package:aves/model/selection.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/identity/aves_icons.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GridItemSelectionOverlay<T> extends StatelessWidget {
  final T item;
  final BorderRadius? borderRadius;
  final EdgeInsets? padding;

  const GridItemSelectionOverlay({
    super.key,
    required this.item,
    this.borderRadius,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final duration = context.select<DurationsData, Duration>((v) => v.formTransition);
    final isSelecting = context.select<Selection<T>, bool>((selection) => selection.isSelecting);
    final selectableCount = context.select<Selection<T>, int>((selection) => selection.countSelectable({item}));
    return AnimatedSwitcher(
      duration: duration,
      child: isSelecting
          ? Selector<Selection<T>, double>(
              selector: (context, selection) => selection.countSelected({item}).toDouble() / selectableCount,
              builder: (context, selectedRatio, child) {
                return AnimatedContainer(
                  alignment: AlignmentDirectional.topEnd,
                  padding: padding,
                  decoration: _buildDecoration(context, selectedRatio),
                  duration: duration,
                  child: AnimatedSwitcher(
                    duration: duration,
                    switchInCurve: Curves.easeOutBack,
                    switchOutCurve: Curves.easeOutBack,
                    transitionBuilder: (child, animation) => ScaleTransition(
                      scale: animation,
                      child: child,
                    ),
                    child: OverlayIcon(
                      key: ValueKey(selectedRatio == 1),
                      icon: selectedRatio == 1 ? AIcons.selected : AIcons.unselected,
                      margin: EdgeInsets.zero,
                    ),
                  ),
                );
              },
            )
          : const SizedBox(),
    );
  }

  Decoration _buildDecoration(BuildContext context, double selectedRatio) {
    switch (selectedRatio) {
      case 0:
        return BoxDecoration(
          // define transparency to lerp to target color when selected
          color: Colors.transparent,
          borderRadius: borderRadius,
        );
      case 1:
        return BoxDecoration(
          color: _getSelectionColor(context),
          borderRadius: borderRadius,
        );
      default:
        final selectedColor = _getSelectionColor(context);
        const unselectedColor = Colors.transparent;
        return BoxDecoration(
          gradient: LinearGradient(
            begin: const Alignment(-.1, -.1),
            end: const Alignment(.1, .1),
            colors: [selectedColor, selectedColor, unselectedColor, unselectedColor],
            stops: const [0, .5, .5, 1],
            tileMode: TileMode.repeated,
          ),
          borderRadius: borderRadius,
        );
    }
  }

  Color _getSelectionColor(BuildContext context) => Theme.of(context).colorScheme.primary.withValues(alpha: .6);
}
