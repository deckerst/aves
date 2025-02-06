import 'package:aves/widgets/common/extensions/theme.dart';
import 'package:flutter/material.dart';

class AvesBorder {
  static Color _borderColor(BuildContext context) => Theme.of(context).isDark ? Colors.white30 : Colors.black26;

  // 1 device pixel for straight lines is fine
  static double straightBorderWidth(BuildContext context) => 1 / MediaQuery.devicePixelRatioOf(context);

  // 1 device pixel for curves is too thin
  static double curvedBorderWidth(BuildContext context) => MediaQuery.devicePixelRatioOf(context) > 2 ? 0.5 : 1.0;

  static BorderSide straightSide(BuildContext context, {double? width}) => BorderSide(
        color: _borderColor(context),
        width: width ?? straightBorderWidth(context),
      );

  static BorderSide curvedSide(BuildContext context, {double? width}) => BorderSide(
        color: _borderColor(context),
        width: width ?? curvedBorderWidth(context),
      );

  static Border border(BuildContext context, {double? width}) => Border.fromBorderSide(curvedSide(context, width: width));
}
