import 'package:aves/model/availability.dart';
import 'package:aves/utils/constants.dart';
import 'package:aves/widgets/about/news_badge.dart';
import 'package:aves/widgets/common/basic/link_chip.dart';
import 'package:flutter/material.dart';

class AboutNewVersion extends StatefulWidget {
  @override
  _AboutNewVersionState createState() => _AboutNewVersionState();
}

class _AboutNewVersionState extends State<AboutNewVersion> {
  Future<bool> _newVersionLoader;

  @override
  void initState() {
    super.initState();
    _newVersionLoader = availability.isNewVersionAvailable;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _newVersionLoader,
      builder: (context, snapshot) {
        final newVersion = snapshot.data == true;
        if (!newVersion) return SizedBox();
        return Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ConstrainedBox(
                    constraints: BoxConstraints(minHeight: 48),
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Text.rich(
                        TextSpan(
                          children: [
                            WidgetSpan(
                              child: Padding(
                                padding: EdgeInsetsDirectional.only(end: 8),
                                child: AboutNewsBadge(),
                              ),
                              alignment: PlaceholderAlignment.middle,
                            ),
                            TextSpan(text: 'New Version Available', style: Constants.titleTextStyle),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(text: 'A new version of Aves is available on '),
                        WidgetSpan(
                          child: LinkChip(
                            text: 'Github',
                            url: 'https://github.com/deckerst/aves/releases',
                            textStyle: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          alignment: PlaceholderAlignment.middle,
                        ),
                        TextSpan(text: ' and '),
                        WidgetSpan(
                          child: LinkChip(
                            text: 'Google Play',
                            url: 'https://play.google.com/store/apps/details?id=deckers.thibault.aves',
                            textStyle: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          alignment: PlaceholderAlignment.middle,
                        ),
                        TextSpan(text: '.'),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                ],
              ),
            ),
            Divider(),
          ],
        );
      },
    );
  }
}
