import 'package:flutter/material.dart';
import 'package:outline_material_icons/outline_material_icons.dart';

class MenuRow extends StatelessWidget {
  final String text;
  final IconData icon;
  final bool checked;

  const MenuRow({
    Key key,
    this.text,
    this.icon,
    this.checked,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (checked != null) ...[
          Opacity(
            opacity: checked ? 1 : 0,
            child: Icon(OMIcons.done),
          ),
          const SizedBox(width: 8),
        ],
        if (icon != null) ...[
          Icon(icon),
          const SizedBox(width: 8),
        ],
        Text(text),
      ],
    );
  }
}
