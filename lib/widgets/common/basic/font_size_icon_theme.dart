import 'package:flutter/widgets.dart';

// scale icons according to text scale
class FontSizeIconTheme extends StatelessWidget {
  final Widget child;

  const FontSizeIconTheme({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final textScaleFactor = MediaQuery.textScaleFactorOf(context);
    final iconTheme = IconTheme.of(context);
    return IconTheme(
      data: iconTheme.copyWith(
        size: iconTheme.size! * textScaleFactor,
      ),
      child: child,
    );
  }
}
