import 'package:flutter/material.dart';
import 'package:outline_material_icons/outline_material_icons.dart';

class EmptyContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const color = Color(0xFF607D8B);
    return Align(
      alignment: const FractionalOffset(.5, .4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(
            OMIcons.photo,
            size: 64,
            color: color,
          ),
          SizedBox(height: 16),
          Text(
            'Nothing!',
            style: TextStyle(
              color: color,
              fontSize: 22,
              fontFamily: 'Concourse',
            ),
          ),
        ],
      ),
    );
  }
}
