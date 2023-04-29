import 'package:flutter/widgets.dart';

class SpringyScrollPhysics extends ScrollPhysics {
  @override
  final SpringDescription spring;

  const SpringyScrollPhysics({
    required this.spring,
    super.parent,
  });

  @override
  SpringyScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return SpringyScrollPhysics(
      spring: spring,
      parent: buildParent(ancestor),
    );
  }

}
