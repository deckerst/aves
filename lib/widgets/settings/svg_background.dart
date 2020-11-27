import 'package:aves/model/settings/settings.dart';
import 'package:aves/widgets/common/fx/borders.dart';
import 'package:flutter/material.dart';

class SvgBackgroundSelector extends StatefulWidget {
  @override
  _SvgBackgroundSelectorState createState() => _SvgBackgroundSelectorState();
}

class _SvgBackgroundSelectorState extends State<SvgBackgroundSelector> {
  @override
  Widget build(BuildContext context) {
    const radius = 24.0;
    return DropdownButtonHideUnderline(
      child: DropdownButton<int>(
        items: [0xFFFFFFFF, 0xFF000000, 0x00000000].map((selected) {
          return DropdownMenuItem<int>(
            value: selected,
            child: Container(
              height: radius,
              width: radius,
              decoration: BoxDecoration(
                color: Color(selected),
                border: AvesCircleBorder.build(context),
                shape: BoxShape.circle,
              ),
              child: selected == 0
                  ? Icon(
                      Icons.clear,
                      size: 20,
                      color: Colors.white30,
                    )
                  : null,
            ),
          );
        }).toList(),
        value: settings.svgBackground,
        onChanged: (selected) {
          settings.svgBackground = selected;
          setState(() {});
        },
      ),
    );
  }
}
