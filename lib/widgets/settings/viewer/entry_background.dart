import 'package:aves/model/settings/enums/entry_background.dart';
import 'package:aves/model/settings/enums/enums.dart';
import 'package:aves/widgets/common/basic/color_indicator.dart';
import 'package:aves/widgets/common/fx/checkered_decoration.dart';
import 'package:flutter/material.dart';

class EntryBackgroundSelector extends StatefulWidget {
  final ValueGetter<EntryBackground> getter;
  final ValueSetter<EntryBackground> setter;

  const EntryBackgroundSelector({
    super.key,
    required this.getter,
    required this.setter,
  });

  @override
  State<EntryBackgroundSelector> createState() => _EntryBackgroundSelectorState();
}

class _EntryBackgroundSelectorState extends State<EntryBackgroundSelector> {
  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<EntryBackground>(
        items: _buildItems(context),
        value: widget.getter(),
        onChanged: (selected) {
          if (selected != null) {
            widget.setter(selected);
            setState(() {});
          }
        },
      ),
    );
  }

  List<DropdownMenuItem<EntryBackground>> _buildItems(BuildContext context) {
    return [
      EntryBackground.white,
      EntryBackground.black,
      EntryBackground.checkered,
    ].map((selected) {
      return DropdownMenuItem<EntryBackground>(
        value: selected,
        child: ColorIndicator(
          value: selected.isColor ? selected.color : null,
          child: selected == EntryBackground.checkered
              ? ClipOval(
                  child: CustomPaint(
                    painter: CheckeredPainter(
                      checkSize: ColorIndicator.radius,
                    ),
                  ),
                )
              : null,
        ),
      );
    }).toList();
  }
}
