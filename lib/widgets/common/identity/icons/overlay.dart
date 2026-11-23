import 'package:aves/widgets/common/basic/text/fading_line.dart';
import 'package:aves/widgets/common/extensions/theme.dart';
import 'package:aves/widgets/common/grid/theme.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

class const OverlayIcon({
  super.key,
  final IconData? icon,
  final double iconScale = 1,
  final String? text,
  // default margin for multiple icons in a `Column`
  final EdgeInsetsGeometry margin = defaultMargin,
  final Offset? relativeOffset,
}) extends StatelessWidget {
  static const defaultMargin = EdgeInsets.only(left: 1, right: 1, bottom: 1);

  @override
  Widget build(BuildContext context) {
    final size = context.select<GridThemeData, double>((t) => t.iconSize);

    Widget? child;
    EdgeInsetsGeometry? padding;

    if (icon != null) {
      child = _buildIcon(size);

      if (text != null) {
        padding = EdgeInsetsDirectional.only(end: size / 4);
        child = Row(
          mainAxisSize: .min,
          crossAxisAlignment: .center,
          children: [
            child,
            const SizedBox(width: 2),
            Flexible(
              child: _buildText(context),
            ),
          ],
        );
      }
    } else if (text != null) {
      padding = EdgeInsets.symmetric(horizontal: size / 4);
      child = _buildText(context);
    }

    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: Theme.of(context).isDark ? const Color(0xAA000000) : const Color(0xCCFFFFFF),
        borderRadius: BorderRadius.all(Radius.circular(size)),
      ),
      child: child,
    );
  }

  Widget _buildIcon(double size) {
    Widget iconChild = Icon(
      icon,
      size: size,
    );

    if (relativeOffset != null) {
      iconChild = FractionalTranslation(
        translation: relativeOffset!,
        child: iconChild,
      );
    }

    if (iconScale != 1) {
      // using a transform is better than modifying the icon size to properly center the scaled icon
      iconChild = Transform.scale(
        scale: iconScale,
        child: iconChild,
      );
    }

    iconChild = SizedBox(
      width: size,
      height: size,
      child: iconChild,
    );
    return iconChild;
  }

  Widget _buildText(BuildContext context) {
    return FadingLine(
      text!,
      // consistent with the color used for the icon next to it
      style: TextStyle(color: IconTheme.of(context).color),
    );
  }
}
