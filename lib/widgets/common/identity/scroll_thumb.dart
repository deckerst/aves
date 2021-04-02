import 'package:aves/widgets/common/basic/draggable_scrollbar.dart';
import 'package:flutter/material.dart';

const double avesScrollThumbHeight = 48;

// height and background color do not change
// so we do not rely on the builder props
ScrollThumbBuilder avesScrollThumbBuilder({
  @required double height,
  @required Color backgroundColor,
}) {
  final scrollThumb = Container(
    decoration: BoxDecoration(
      color: Colors.black26,
      borderRadius: BorderRadius.circular(12),
    ),
    height: height,
    margin: EdgeInsets.only(right: .5),
    padding: EdgeInsets.all(2),
    child: ClipPath(
      clipper: ArrowClipper(),
      child: Container(
        width: 20.0,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
  );
  return (backgroundColor, thumbAnimation, labelAnimation, height, {labelText}) {
    return DraggableScrollbar.buildScrollThumbAndLabel(
      scrollThumb: scrollThumb,
      backgroundColor: backgroundColor,
      thumbAnimation: thumbAnimation,
      labelAnimation: labelAnimation,
      labelText: labelText,
    );
  };
}
