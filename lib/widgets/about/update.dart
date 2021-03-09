import 'package:aves/model/availability.dart';
import 'package:aves/utils/constants.dart';
import 'package:aves/widgets/about/news_badge.dart';
import 'package:aves/widgets/common/basic/link_chip.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:flutter/material.dart';

class AboutUpdate extends StatefulWidget {
  @override
  _AboutUpdateState createState() => _AboutUpdateState();
}

class _AboutUpdateState extends State<AboutUpdate> {
  Future<bool> _updateChecker;

  @override
  void initState() {
    super.initState();
    _updateChecker = availability.isNewVersionAvailable;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _updateChecker,
      builder: (context, snapshot) {
        final newVersionAvailable = snapshot.data == true;
        if (!newVersionAvailable) return SizedBox();
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
                            TextSpan(text: context.l10n.aboutUpdate, style: Constants.titleTextStyle),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(text: context.l10n.aboutUpdateLinks1),
                        WidgetSpan(
                          child: LinkChip(
                            text: context.l10n.aboutUpdateGithub,
                            url: 'https://github.com/deckerst/aves/releases',
                            textStyle: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          alignment: PlaceholderAlignment.middle,
                        ),
                        TextSpan(text: context.l10n.aboutUpdateLinks2),
                        WidgetSpan(
                          child: LinkChip(
                            text: context.l10n.aboutUpdateGooglePlay,
                            url: 'https://play.google.com/store/apps/details?id=deckers.thibault.aves',
                            textStyle: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          alignment: PlaceholderAlignment.middle,
                        ),
                        TextSpan(text: context.l10n.aboutUpdateLinks3),
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
