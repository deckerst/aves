import 'package:aves/theme/format.dart';
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
    super.key,
    required this.extent,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ProxyProvider<MediaQueryData, EntryListDetailsThemeData>(
      update: (context, mq, previous) {
        final locale = context.l10n.localeName;

        final use24hour = mq.alwaysUse24HourFormat;
        final textScaler = mq.textScaler;

        final textTheme = Theme.of(context).textTheme;
        // specify `height` for accurate paragraph height measurement
        final defaultTextHeight = DefaultTextStyle.of(context).style.height;
        final titleStyle = textTheme.bodyMedium!.copyWith(height: defaultTextHeight);
        final captionStyle = textTheme.bodySmall!.copyWith(height: defaultTextHeight);

        final titleLineHeightParagraph = RenderParagraph(
          TextSpan(
            text: 'Fake Title',
            style: titleStyle,
          ),
          textDirection: TextDirection.ltr,
          textScaler: textScaler,
        )..layout(const BoxConstraints(), parentUsesSize: true);
        final titleLineHeight = titleLineHeightParagraph.getMaxIntrinsicHeight(double.infinity);
        titleLineHeightParagraph.dispose();

        final captionLineHeightParagraph = RenderParagraph(
          TextSpan(
            text: formatDateTime(DateTime.now(), locale, use24hour),
            style: captionStyle,
          ),
          textDirection: TextDirection.ltr,
          textScaler: textScaler,
        )..layout(const BoxConstraints(), parentUsesSize: true);
        final captionLineHeight = captionLineHeightParagraph.getMaxIntrinsicHeight(double.infinity);

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
            size: textScaler.scale(captionStyle.fontSize!),
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
