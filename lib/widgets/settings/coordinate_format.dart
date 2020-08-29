import 'package:aves/model/settings.dart';
import 'package:flutter/material.dart';

class CoordinateFormatSelector extends StatefulWidget {
  @override
  _CoordinateFormatSelectorState createState() => _CoordinateFormatSelectorState();
}

class _CoordinateFormatSelectorState extends State<CoordinateFormatSelector> {
  @override
  Widget build(BuildContext context) {
    return DropdownButton<CoordinateFormat>(
      items: CoordinateFormat.values
          .map((selected) => DropdownMenuItem(
                value: selected,
                child: Text(
                  selected.name,
                  softWrap: false,
                  overflow: TextOverflow.fade,
                  maxLines: 1,
                ),
              ))
          .toList(),
      value: settings.coordinateFormat,
      onChanged: (selected) {
        settings.coordinateFormat = selected;
        setState(() {});
      },
    );
  }
}
