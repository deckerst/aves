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
    return AnimatedSwitcher(
      duration: duration,
      child: isSelecting
          ? Selector<Selection<T>, bool>(
              selector: (context, selection) => selection.isSelected({item}),
              builder: (context, isSelected, child) {
                return AnimatedContainer(
                  alignment: AlignmentDirectional.topEnd,
                  padding: padding,
                  decoration: BoxDecoration(
                    color: isSelected ? Theme.of(context).colorScheme.primary.withValues(alpha: .6) : Colors.transparent,
                    borderRadius: borderRadius,
                  ),
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
                      key: ValueKey(isSelected),
                      icon: isSelected ? AIcons.selected : AIcons.unselected,
                      margin: EdgeInsets.zero,
                    ),
                  ),
                );
              },
            )
          : const SizedBox(),
    );
  }
}
