import 'package:aves/widgets/common/basic/draggable_scrollbar/arrow_clipper.dart';
import 'package:aves/widgets/common/basic/draggable_scrollbar/scrollbar.dart';
import 'package:material_ui/material_ui.dart';

class AvesScrollThumb {
  static const EdgeInsetsGeometry _margin = EdgeInsetsDirectional.only(end: 1);
  static const EdgeInsets _padding = .all(2);
  static const double _width = 20;
  static final double _thumbWidth = _width + _padding.horizontal + _margin.horizontal;

  static const double thumbHeight = 48;
  static final thumbSize = Size(_thumbWidth, thumbHeight);

  static ScrollThumbBuilder builder({
    required BuildContext context,
    required double height,
  }) {
    final theme = Theme.of(context);
    const borderRadius = BorderRadius.all(Radius.circular(12));
    final scrollThumb = Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.onSurface.withAlpha(66),
        borderRadius: borderRadius,
      ),
      height: height,
      margin: _margin,
      padding: _padding,
      child: ClipPath(
        clipper: ArrowClipper(),
        child: Container(
          width: _width,
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: borderRadius,
          ),
        ),
      ),
    );
    return (thumbAnimation, labelAnimation, height, {labelText}) {
      return DraggableScrollbar.buildScrollThumbAndLabel(
        scrollThumb: scrollThumb,
        thumbAnimation: thumbAnimation,
        labelAnimation: labelAnimation,
        labelText: labelText,
      );
    };
  }
}
