import 'package:flutter/widgets.dart';

class DraggedPlaceholder extends StatelessWidget {
  final Widget child;

  const DraggedPlaceholder({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: .2,
      child: child,
    );
  }
}
