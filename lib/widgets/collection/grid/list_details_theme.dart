import 'package:aves/theme/format.dart';
import 'package:aves/utils/constants.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

class EntryListDetailsTheme extends StatelessWidget {
  final double extent;
  final Widget child;

  static const EdgeInsets contentMargin = EdgeInsets.symmetric(horizontal: 8);
  static const EdgeInsets contentPadding = EdgeInsets.symmetric(vertical: 4);
  static const double titleDetailPadding = 6;

  const EntryListDetailsTheme({
    Key? key,
    required this.extent,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ProxyProvider<MediaQueryData, EntryListDetailsThemeData>(
      update: (context, mq, previous) {
        final locale = context.l10n.localeName;

        final use24hour = mq.alwaysUse24HourFormat;
        final textScaleFactor = mq.textScaleFactor;

        final textTheme = Theme.of(context).textTheme;
        final titleStyle = textTheme.bodyText2!;
        final captionStyle = textTheme.caption!;

        final titleLineHeight = (RenderParagraph(
          TextSpan(text: 'Fake Title', style: titleStyle),
          textDirection: TextDirection.ltr,
          textScaleFactor: textScaleFactor,
        )..layout(const BoxConstraints(), parentUsesSize: true))
            .getMaxIntrinsicHeight(double.infinity);

        final captionLineHeight = (RenderParagraph(
          TextSpan(text: formatDateTime(DateTime.now(), locale, use24hour), style: captionStyle),
          textDirection: TextDirection.ltr,
          textScaleFactor: textScaleFactor,
          strutStyle: Constants.overflowStrutStyle,
        )..layout(const BoxConstraints(), parentUsesSize: true))
            .getMaxIntrinsicHeight(double.infinity);

        var titleMaxLines = 1;
        var showDate = false;
        var showLocation = false;

        var availableHeight = extent - contentMargin.vertical - contentPadding.vertical;
        if (availableHeight >= titleLineHeight + titleDetailPadding + captionLineHeight) {
          showDate = true;
          availableHeight -= titleLineHeight + titleDetailPadding + captionLineHeight;
          if (availableHeight >= captionLineHeight) {
            showLocation = true;
            availableHeight -= captionLineHeight;
            titleMaxLines += availableHeight ~/ titleLineHeight;
          }
        }

        return EntryListDetailsThemeData(
          extent: extent,
          titleMaxLines: titleMaxLines,
          showDate: showDate,
          showLocation: showLocation,
          titleStyle: titleStyle,
          captionStyle: captionStyle,
          iconTheme: IconThemeData(
            color: captionStyle.color,
            size: captionStyle.fontSize! * textScaleFactor,
          ),
        );
      },
      child: child,
    );
  }
}

class EntryListDetailsThemeData {
  final double extent;
  final int titleMaxLines;
  final bool showDate, showLocation;
  final TextStyle titleStyle, captionStyle;
  final IconThemeData iconTheme;

  const EntryListDetailsThemeData({
    required this.extent,
    required this.titleMaxLines,
    required this.showDate,
    required this.showLocation,
    required this.titleStyle,
    required this.captionStyle,
    required this.iconTheme,
  });
}
