import 'package:flutter/widgets.dart';

class DraggedPlaceholder extends StatelessWidget {
  final Widget child;

  const DraggedPlaceholder({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: .2,
      child: child,
    );
  }
}
