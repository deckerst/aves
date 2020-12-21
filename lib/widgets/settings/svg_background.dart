import 'package:aves/model/settings/entry_background.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/widgets/common/fx/borders.dart';
import 'package:aves/widgets/common/fx/checkered_decoration.dart';
import 'package:flutter/material.dart';

class SvgBackgroundSelector extends StatefulWidget {
  @override
  _SvgBackgroundSelectorState createState() => _SvgBackgroundSelectorState();
}

class _SvgBackgroundSelectorState extends State<SvgBackgroundSelector> {
  @override
  Widget build(BuildContext context) {
    const radius = 12.0;
    return DropdownButtonHideUnderline(
      child: DropdownButton<EntryBackground>(
        items: [
          EntryBackground.white,
          EntryBackground.black,
          EntryBackground.checkered,
          EntryBackground.transparent,
        ].map((selected) {
          Widget child;
          switch (selected) {
            case EntryBackground.transparent:
              child = Icon(
                Icons.clear,
                size: 20,
                color: Colors.white30,
              );
              break;
            case EntryBackground.checkered:
              child = ClipOval(
                child: DecoratedBox(
                  decoration: CheckeredDecoration(
                    checkSize: radius,
                  ),
                ),
              );
              break;
            default:
              break;
          }
          return DropdownMenuItem<EntryBackground>(
            value: selected,
            child: Container(
              height: radius * 2,
              width: radius * 2,
              decoration: BoxDecoration(
                color: selected.isColor ? selected.color : null,
                border: AvesCircleBorder.build(context),
                shape: BoxShape.circle,
              ),
              child: child,
            ),
          );
        }).toList(),
        value: settings.vectorBackground,
        onChanged: (selected) {
          settings.vectorBackground = selected;
          setState(() {});
        },
      ),
    );
  }
}
