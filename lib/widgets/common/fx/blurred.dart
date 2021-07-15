import 'dart:ui';

import 'package:flutter/material.dart';

final _filter = ImageFilter.blur(sigmaX: 4, sigmaY: 4);

class BlurredRect extends StatelessWidget {
  final bool enabled;
  final Widget child;

  const BlurredRect({
    Key? key,
    this.enabled = true,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return enabled
        ? ClipRect(
            child: BackdropFilter(
              filter: _filter,
              child: child,
            ),
          )
        : child;
  }
}

class BlurredRRect extends StatelessWidget {
  final bool enabled;
  final double borderRadius;
  final Widget child;

  const BlurredRRect({
    Key? key,
    this.enabled = true,
    required this.borderRadius,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return enabled
        ? ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
            child: BackdropFilter(
              filter: _filter,
              child: child,
            ),
          )
        : child;
  }
}

class BlurredOval extends StatelessWidget {
  final bool enabled;
  final Widget child;

  const BlurredOval({
    Key? key,
    this.enabled = true,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return enabled
        ? ClipOval(
            child: BackdropFilter(
              filter: _filter,
              child: child,
            ),
          )
        : child;
  }
}
