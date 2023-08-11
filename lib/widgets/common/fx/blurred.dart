import 'dart:ui';

import 'package:flutter/material.dart';

final _filter = ImageFilter.blur(sigmaX: 4, sigmaY: 4);
// do not use `ColorFilter.matrix` for identity,
// as it yields performance issues when there are other layers on top
final _identity = ImageFilter.matrix(Matrix4.identity().storage);

class BlurredRect extends StatelessWidget {
  final bool enabled;
  final Widget child;

  const BlurredRect({
    super.key,
    this.enabled = true,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        // do not modify tree when disabling filter
        filter: enabled ? _filter : _identity,
        child: child,
      ),
    );
  }
}

class BlurredRRect extends StatelessWidget {
  final bool enabled;
  final BorderRadius? borderRadius;
  final Widget child;

  const BlurredRRect({
    super.key,
    this.enabled = true,
    required this.borderRadius,
    required this.child,
  });

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
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: BackdropFilter(
        // do not modify tree when disabling filter
        filter: enabled ? _filter : _identity,
        child: child,
      ),
    );
  }
}

class BlurredOval extends StatelessWidget {
  final bool enabled;
  final Widget child;

  const BlurredOval({
    super.key,
    this.enabled = true,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: BackdropFilter(
        // do not modify tree when disabling filter
        filter: enabled ? _filter : _identity,
        child: child,
      ),
    );
  }
}
