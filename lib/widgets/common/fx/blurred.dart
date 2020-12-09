import 'dart:ui';

import 'package:flutter/material.dart';

final _filter = ImageFilter.blur(sigmaX: 4, sigmaY: 4);

class BlurredRect extends StatelessWidget {
  final Widget child;

  const BlurredRect({Key key, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: _filter,
        child: child,
      ),
    );
  }
}

class BlurredRRect extends StatelessWidget {
  final double borderRadius;
  final Widget child;

  const BlurredRRect({Key key, this.borderRadius, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: _filter,
        child: child,
      ),
    );
  }
}

class BlurredOval extends StatelessWidget {
  final Widget child;

  const BlurredOval({Key key, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: BackdropFilter(
        filter: _filter,
        child: child,
      ),
    );
  }
}
