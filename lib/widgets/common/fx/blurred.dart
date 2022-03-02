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
  final BorderRadius? borderRadius;
  final Widget child;

  const BlurredRRect({
    Key? key,
    this.enabled = true,
    required this.borderRadius,
    required this.child,
  }) : super(key: key);

  factory BlurredRRect.all({
    Key? key,
    bool enabled = true,
    required double borderRadius,
    required Widget child,
  }) {
    return BlurredRRect(
      key: key,
      enabled: enabled,
      borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: enabled
          ? BackdropFilter(
              filter: _filter,
              child: child,
            )
          : child,
    );
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
    return ClipOval(
      child: enabled
          ? BackdropFilter(
              filter: _filter,
              child: child,
            )
          : child,
    );
  }
}
