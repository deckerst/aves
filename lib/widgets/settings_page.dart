import 'package:aves/model/settings.dart';
import 'package:aves/utils/constants.dart';
import 'package:aves/widgets/common/data_providers/media_query_data_provider.dart';
import 'package:aves/widgets/fullscreen/info/location_section.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MediaQueryDataProvider(
      child: DefaultTabController(
        length: 4,
        child: Scaffold(
          appBar: AppBar(
            title: Text('Preferences'),
          ),
          body: SafeArea(
            child: ListView(
              padding: EdgeInsets.all(16),
              children: [
                Text('General', style: Constants.titleTextStyle),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Launch Page:'),
                    SizedBox(width: 8),
                    Flexible(child: LaunchPageSelector()),
                  ],
                ),
                SizedBox(height: 16),
                Text('Maps', style: Constants.titleTextStyle),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Storage:'),
                    SizedBox(width: 8),
                    Flexible(child: InfoMapStyleSelector()),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class InfoMapStyleSelector extends StatefulWidget {
  @override
  _InfoMapStyleSelectorState createState() => _InfoMapStyleSelectorState();
}

class _InfoMapStyleSelectorState extends State<InfoMapStyleSelector> {
  @override
  Widget build(BuildContext context) {
    return DropdownButton<EntryMapStyle>(
      items: EntryMapStyle.values
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
      value: settings.infoMapStyle,
      onChanged: (selected) {
        settings.infoMapStyle = selected;
        setState(() {});
      },
    );
  }
}

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
