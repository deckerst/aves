import 'package:material_ui/material_ui.dart';

class const ScrollLabel({
  super.key,
  required final Widget child,
  required final Animation<double> animation,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: animation,
      child: Container(
        margin: const EdgeInsetsDirectional.only(end: 12.0),
        child: Material(
          elevation: 4.0,
          borderRadius: const BorderRadius.all(Radius.circular(16)),
          child: child,
        ),
      ),
    );
  }
}
