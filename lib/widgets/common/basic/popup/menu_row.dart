import 'package:flutter/material.dart';

class MenuRow extends StatelessWidget {
  final String text;
  final Widget? icon;

  const MenuRow({
    super.key,
    required this.text,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null)
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 12),
            child: IconTheme.merge(
              data: IconThemeData(
                color: ListTileTheme.of(context).iconColor,
              ),
              child: icon!,
            ),
          ),
        Flexible(
          child: Text(text),
        ),
      ],
    );
  }
}

// scale icons according to text scale
class MenuIconTheme extends StatelessWidget {
  final Widget child;

  const MenuIconTheme({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final iconTheme = IconTheme.of(context);
    return IconTheme(
      data: iconTheme.copyWith(
        size: iconTheme.size! * MediaQuery.textScaleFactorOf(context),
      ),
      child: child,
    );
  }
}
