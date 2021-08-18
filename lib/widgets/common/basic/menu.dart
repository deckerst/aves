import 'package:flutter/material.dart';

class MenuRow extends StatelessWidget {
  final String text;
  final Widget? icon;

  const MenuRow({
    Key? key,
    required this.text,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (icon != null)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: icon,
          ),
        Expanded(child: Text(text)),
      ],
    );
  }
}

// scale icons according to text scale
class MenuIconTheme extends StatelessWidget {
  final Widget child;

  const MenuIconTheme({
    Key? key,
    required this.child,
  }) : super(key: key);

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
