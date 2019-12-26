import 'dart:ui';

import 'package:flutter/material.dart';

class BlurredRect extends StatelessWidget {
  final Widget child;

  const BlurredRect({Key key, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
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
      borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
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
        filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
        child: child,
      ),
    );
  }
}
