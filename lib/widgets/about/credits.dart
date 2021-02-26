import 'dart:ui';

import 'package:aves/utils/constants.dart';
import 'package:aves/widgets/common/basic/link_chip.dart';
import 'package:flutter/material.dart';

class AboutCredits extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(minHeight: 48),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text('Credits', style: Constants.titleTextStyle),
            ),
          ),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(text: 'This app uses a TopoJSON file from'),
                WidgetSpan(
                  child: LinkChip(
                    text: 'World Atlas',
                    url: 'https://github.com/topojson/world-atlas',
                    textStyle: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  alignment: PlaceholderAlignment.middle,
                ),
                TextSpan(text: 'under ISC License.'),
              ],
            ),
          ),
          SizedBox(height: 16),
        ],
      ),
    );
  }
}
