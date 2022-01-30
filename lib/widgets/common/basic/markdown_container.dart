import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';

class MarkdownContainer extends StatelessWidget {
  final String data;
  final TextDirection? textDirection;

  const MarkdownContainer({
    Key? key,
    required this.data,
    this.textDirection,
  }) : super(key: key);

  static const double maxWidth = 460;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(16)),
        color: Colors.white10,
      ),
      constraints: const BoxConstraints(maxWidth: maxWidth),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        child: Theme(
          data: Theme.of(context).copyWith(
            scrollbarTheme: const ScrollbarThemeData(
              isAlwaysShown: true,
              radius: Radius.circular(16),
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
                onTapLink: (text, href, title) async {
                  if (href != null && await canLaunch(href)) {
                    await launch(href);
                  }
                },
                shrinkWrap: true,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
