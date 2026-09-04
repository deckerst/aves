import 'package:material_ui/material_ui.dart';

class ScrollLabel extends StatelessWidget {
  final Animation<double> animation;
  final Color backgroundColor;
  final Widget child;

  const new({
    super.key,
    required this.child,
    required this.animation,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: animation,
      child: Container(
        margin: const EdgeInsetsDirectional.only(end: 12.0),
        child: Material(
          elevation: 4.0,
          color: backgroundColor,
          borderRadius: const BorderRadius.all(Radius.circular(16)),
          child: child,
        ),
      ),
    );
  }
}
