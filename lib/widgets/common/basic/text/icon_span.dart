import 'package:flutter/widgets.dart';

class IconSpan extends WidgetSpan {
  new({
    required IconData icon,
    double? size,
    List<Shadow>? shadows,
    EdgeInsetsGeometry? padding,
  }) : super(
         child: padding != null
             ? Padding(
                 padding: padding,
                 child: _buildIcon(icon, size, shadows),
               )
             : _buildIcon(icon, size, shadows),
         alignment: .middle,
       );

  static Icon _buildIcon(IconData icon, double? size, shadows) {
    return Icon(icon, size: size, shadows: shadows);
  }
}
