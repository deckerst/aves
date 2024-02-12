import 'package:aves/widgets/common/fx/borders.dart';
import 'package:flutter/widgets.dart';

class ColorIndicator extends StatelessWidget {
  final Color? value;
  final Color? alternate;
  final Widget? child;

  static const double radius = 16;

  const ColorIndicator({
    super.key,
    required this.value,
    this.alternate,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    const dimension = radius * 2;

    Gradient? gradient;
    final _value = value;
    final _alternate = alternate;
    if (_value != null && _alternate != null && _alternate != _value) {
      gradient = LinearGradient(
        begin: AlignmentDirectional.topStart,
        end: AlignmentDirectional.bottomEnd,
        colors: [_value, _value, _alternate, _alternate],
        stops: const [0, .5, .5, 1],
      );
    }

    return Container(
      height: dimension,
      width: dimension,
      decoration: BoxDecoration(
        color: _value,
        border: AvesBorder.border(context),
        gradient: gradient,
        shape: BoxShape.circle,
      ),
      child: child,
    );
  }
}
