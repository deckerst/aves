import 'package:aves/widgets/common/basic/draggable_scrollbar.dart';
import 'package:flutter/material.dart';

const double avesScrollThumbHeight = 48;

// height and background color do not change
// so we do not rely on the builder props
ScrollThumbBuilder avesScrollThumbBuilder({
  required double height,
  required Color backgroundColor,
}) {
  final scrollThumb = Container(
    decoration: const BoxDecoration(
      color: Colors.black26,
      borderRadius: BorderRadius.all(Radius.circular(12)),
    ),
    height: height,
    margin: const EdgeInsetsDirectional.only(end: 1),
    padding: const EdgeInsets.all(2),
    child: ClipPath(
      clipper: ArrowClipper(),
      child: Container(
        width: 20.0,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: const BorderRadius.all(Radius.circular(12)),
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
