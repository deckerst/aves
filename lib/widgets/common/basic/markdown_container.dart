import 'package:aves/widgets/aves_app.dart';
import 'package:aves/widgets/common/fx/borders.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class MarkdownContainer extends StatelessWidget {
  final String data;
  final TextDirection? textDirection;

  const MarkdownContainer({
    super.key,
    required this.data,
    this.textDirection,
  });

  static const double maxWidth = 460;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).canvasColor,
        border: Border.all(color: Theme.of(context).dividerColor, width: AvesBorder.curvedBorderWidth),
        borderRadius: const BorderRadius.all(Radius.circular(16)),
      ),
      constraints: const BoxConstraints(maxWidth: maxWidth),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        child: Theme(
          data: Theme.of(context).copyWith(
            scrollbarTheme: ScrollbarThemeData(
              thumbVisibility: MaterialStateProperty.all(true),
              radius: const Radius.circular(16),
              crossAxisMargin: 6,
              mainAxisMargin: 16,
              interactive: true,
            ),
          ),
          child: Scrollbar(
            child: Directionality(
              textDirection: textDirection ?? Directionality.of(context),
              child: Markdown(
                data: data,
                selectable: true,
                onTapLink: (text, href, title) => AvesApp.launchUrl(href),
                shrinkWrap: true,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
