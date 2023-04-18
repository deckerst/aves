import 'package:aves/widgets/common/fx/borders.dart';
import 'package:flutter/widgets.dart';

class ColorIndicator extends StatelessWidget {
  final Color? value;
  final Widget? child;

  static const double radius = 16;

  const ColorIndicator({
    super.key,
    required this.value,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    const dimension = radius * 2;
    return Container(
      height: dimension,
      width: dimension,
      decoration: BoxDecoration(
        color: value,
        border: AvesBorder.border(context),
        shape: BoxShape.circle,
      ),
      child: child,
    );
  }
}
