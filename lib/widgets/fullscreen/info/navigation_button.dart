import 'package:aves/utils/color_utils.dart';
import 'package:flutter/material.dart';

class NavigationButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const NavigationButton({
    @required this.label,
    @required this.onPressed,
  });

  static const double buttonBorderWidth = 2;

  @override
  Widget build(BuildContext context) {
    return OutlineButton(
      onPressed: onPressed,
      borderSide: BorderSide(
        color: stringToColor(label),
        width: buttonBorderWidth,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(42),
      ),
      child: Text(label),
    );
  }
}
