import 'package:material_ui/material_ui.dart';

class InteractiveAppBarTitle extends StatelessWidget {
  final GestureTapCallback? onTap;
  final Widget child;

  const new({
    super.key,
    this.onTap,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final textScaler = MediaQuery.textScalerOf(context);
    return GestureDetector(
      onTap: onTap,
      // use a `Container` with a dummy color to make it expand
      // so that we can also detect taps around the title `Text`
      child: Container(
        alignment: AlignmentDirectional.centerStart,
        color: Colors.transparent,
        height: textScaler.scale(kToolbarHeight),
        child: child,
      ),
    );
  }
}
