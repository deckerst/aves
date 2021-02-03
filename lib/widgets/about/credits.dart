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
              child: Text(
                'Credits',
                style: Theme.of(context).textTheme.headline6.copyWith(fontFamily: 'Concourse Caps'),
              ),
            ),
          ),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(text: 'This app uses the font '),
                WidgetSpan(
                  child: LinkChip(
                    text: 'Concourse',
                    url: 'https://mbtype.com/fonts/concourse/',
                    textStyle: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  alignment: PlaceholderAlignment.middle,
                ),
                TextSpan(text: ' for titles and the media information page.'),
              ],
            ),
          ),
          SizedBox(height: 16),
        ],
      ),
    );
  }
}
