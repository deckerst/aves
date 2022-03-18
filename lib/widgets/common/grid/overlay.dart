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

  static const duration = Durations.thumbnailOverlayAnimation;

  const GridItemSelectionOverlay({
    Key? key,
    required this.item,
    this.borderRadius,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isSelecting = context.select<Selection<T>, bool>((selection) => selection.isSelecting);
    final child = isSelecting
        ? Selector<Selection<T>, bool>(
            selector: (context, selection) => selection.isSelected([item]),
            builder: (context, isSelected, child) {
              var child = isSelecting
                  ? OverlayIcon(
                      key: ValueKey(isSelected),
                      icon: isSelected ? AIcons.selected : AIcons.unselected,
                      margin: EdgeInsets.zero,
                    )
                  : const SizedBox();
              child = AnimatedSwitcher(
                duration: duration,
                switchInCurve: Curves.easeOutBack,
                switchOutCurve: Curves.easeOutBack,
                transitionBuilder: (child, animation) => ScaleTransition(
                  scale: animation,
                  child: child,
                ),
                child: child,
              );
              child = AnimatedContainer(
                alignment: AlignmentDirectional.topEnd,
                padding: padding,
                decoration: BoxDecoration(
                  color: isSelected ? Colors.black54 : Colors.transparent,
                  borderRadius: borderRadius,
                ),
                duration: duration,
                child: child,
              );
              return child;
            },
          )
        : const SizedBox();
    return AnimatedSwitcher(
      duration: duration,
      child: child,
    );
  }
}
