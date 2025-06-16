import 'package:aves/model/settings/settings.dart';
import 'package:aves/theme/text.dart';
import 'package:aves/widgets/aves_app.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/viewer/info/common.dart';
import 'package:aves_map/aves_map.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:provider/provider.dart';

class Attribution extends StatelessWidget {
  final EntryMapStyle? style;

  const Attribution({
    super.key,
    required this.style,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (style == EntryMapStyles.osmLiberty) return _buildOsmAttributionMarkdown(context, l10n.mapAttributionOsmLiberty);
    if (style == EntryMapStyles.openTopoMap) return _buildOsmAttributionMarkdown(context, l10n.mapAttributionOpenTopoMap);
    if (style == EntryMapStyles.osmHot) return _buildOsmAttributionMarkdown(context, l10n.mapAttributionOsmHot);
    if (style == EntryMapStyles.stamenWatercolor) return _buildOsmAttributionMarkdown(context, l10n.mapAttributionStamen);
    return const SizedBox();
  }

  Widget _buildOsmAttributionMarkdown(BuildContext context, String data) {
    final theme = Theme.of(context);
    Widget child = MarkdownBody(
      data: '${context.l10n.mapAttributionOsmData}${AText.separator}$data',
      selectable: true,
      styleSheet: MarkdownStyleSheet(
        a: TextStyle(color: theme.colorScheme.primary),
        p: theme.textTheme.bodySmall!.merge(const TextStyle(fontSize: InfoRowGroup.fontSize)),
      ),
      onTapLink: (text, href, title) => AvesApp.launchUrl(href),
    );

    final animate = context.select<Settings, bool>((v) => v.animate);
    if (animate) {
      child = Hero(
        tag: 'map-attribution',
        flightShuttleBuilder: (flightContext, animation, flightDirection, fromHeroContext, toHeroContext) {
          return DefaultTextStyle(
            style: DefaultTextStyle.of(toHeroContext).style,
            child: MediaQuery.removeViewPadding(
              context: context,
              removeLeft: true,
              removeTop: true,
              removeRight: true,
              removeBottom: true,
              child: toHeroContext.widget,
            ),
          );
        },
        child: child,
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: child,
    );
  }
}
