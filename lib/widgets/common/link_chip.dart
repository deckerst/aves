import 'package:aves/widgets/common/icons.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class LinkChip extends StatelessWidget {
  final String text;
  final String url;
  final Color color;
  final TextStyle textStyle;

  static const borderRadius = BorderRadius.all(Radius.circular(8));

  const LinkChip({
    Key key,
    @required this.text,
    @required this.url,
    this.color,
    this.textStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final effectiveTextStyle = (textStyle ?? DefaultTextStyle.of(context).style).copyWith(
      color: color,
    );
    return InkWell(
      borderRadius: borderRadius,
      onTap: () async {
        if (await canLaunch(url)) {
          await launch(url);
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              style: effectiveTextStyle,
            ),
            const SizedBox(width: 8),
            Icon(
              AIcons.openInNew,
              size: Theme.of(context).textTheme.bodyText2.fontSize,
              color: color,
            )
          ],
        ),
      ),
    );
  }
}
