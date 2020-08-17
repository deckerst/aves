import 'package:aves/model/settings.dart';
import 'package:aves/widgets/fullscreen/info/location_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../dialog.dart';

class MapStyleDialog extends StatefulWidget {
  @override
  _MapStyleDialogState createState() => _MapStyleDialogState();
}

class _MapStyleDialogState extends State<MapStyleDialog> {
  EntryMapStyle _selectedStyle;

  @override
  void initState() {
    super.initState();
    _selectedStyle = settings.infoMapStyle;
  }

  @override
  Widget build(BuildContext context) {
    return AvesDialog(
      title: 'Map Style',
      scrollableContent: EntryMapStyle.values.map((style) => _buildRadioListTile(style, style.name)).toList(),
      actions: [
        FlatButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'.toUpperCase()),
        ),
        FlatButton(
          onPressed: () => Navigator.pop(context, _selectedStyle),
          child: Text('Apply'.toUpperCase()),
        ),
      ],
    );
  }

  Widget _buildRadioListTile(EntryMapStyle style, String title) => RadioListTile<EntryMapStyle>(
        value: style,
        groupValue: _selectedStyle,
        onChanged: (style) => setState(() => _selectedStyle = style),
        title: Text(
          title,
          softWrap: false,
          overflow: TextOverflow.fade,
          maxLines: 1,
        ),
      );
}
