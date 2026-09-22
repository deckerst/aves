import 'package:flutter/widgets.dart';

class const DraggedPlaceholder({
  super.key,
  required final Widget child,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: .2,
      child: child,
    );
  }
}
