import 'package:aves/model/settings.dart';
import 'package:flutter/material.dart';

class LaunchPageSelector extends StatefulWidget {
  @override
  _LaunchPageSelectorState createState() => _LaunchPageSelectorState();
}

class _LaunchPageSelectorState extends State<LaunchPageSelector> {
  @override
  Widget build(BuildContext context) {
    return DropdownButton<LaunchPage>(
      items: LaunchPage.values
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
      value: settings.launchPage,
      onChanged: (selected) {
        settings.launchPage = selected;
        setState(() {});
      },
    );
  }
}
