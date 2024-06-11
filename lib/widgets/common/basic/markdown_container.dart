import 'package:aves/model/settings/settings.dart';
import 'package:aves/theme/themes.dart';
import 'package:aves/widgets/aves_app.dart';
import 'package:aves/widgets/common/fx/borders.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class MarkdownContainer extends StatelessWidget {
  final String data;
  final TextDirection? textDirection;
  final ScrollController? scrollController;

  const MarkdownContainer({
    super.key,
    required this.data,
    this.textDirection,
    this.scrollController,
  });

  static const double mobileMaxWidth = 460;

  @override
  Widget build(BuildContext context) {
    final useTvLayout = settings.useTvLayout;

    Widget child = Directionality(
      textDirection: textDirection ?? Directionality.of(context),
      child: Markdown(
        data: data,
        selectable: true,
        onTapLink: (text, href, title) => AvesApp.launchUrl(href),
        controller: scrollController,
        shrinkWrap: true,
      ),
    );

    if (!useTvLayout) {
      child = Theme(
        data: Theme.of(context).copyWith(
          scrollbarTheme: ScrollbarThemeData(
            thumbVisibility: WidgetStateProperty.all(true),
            radius: const Radius.circular(16),
            crossAxisMargin: 6,
            mainAxisMargin: 16,
            interactive: true,
          ),
        ),
        child: Scrollbar(
          child: child,
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Themes.secondLayerColor(context),
        border: Border.all(
          color: Theme.of(context).dividerColor,
          width: AvesBorder.curvedBorderWidth(context),
        ),
        borderRadius: const BorderRadius.all(Radius.circular(16)),
      ),
      constraints: BoxConstraints(maxWidth: useTvLayout ? double.infinity : mobileMaxWidth),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        child: child,
      ),
    );
  }
}
