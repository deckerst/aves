import 'package:aves/utils/constants.dart';
import 'package:aves/widgets/common/data_providers/media_query_data_provider.dart';
import 'package:aves/widgets/settings/coordinate_format.dart';
import 'package:aves/widgets/settings/launch_page.dart';
import 'package:aves/widgets/settings/svg_background.dart';
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
                    Text('Launch page:'),
                    SizedBox(width: 8),
                    Flexible(child: LaunchPageSelector()),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('SVG background:'),
                    SizedBox(width: 8),
                    Flexible(child: SvgBackgroundSelector()),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Coordinate format:'),
                    SizedBox(width: 8),
                    Flexible(child: CoordinateFormatSelector()),
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
