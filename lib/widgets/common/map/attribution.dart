import 'package:aves/theme/text.dart';
import 'package:aves/widgets/aves_app.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/viewer/info/common.dart';
import 'package:aves_map/aves_map.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class Attribution extends StatelessWidget {
  final EntryMapStyle? style;

  const Attribution({
    super.key,
    required this.style,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    switch (style) {
      case EntryMapStyle.osmLiberty:
        return _buildOsmAttributionMarkdown(context, l10n.mapAttributionOsmLiberty);
      case EntryMapStyle.openTopoMap:
        return _buildOsmAttributionMarkdown(context, l10n.mapAttributionOpenTopoMap);
      case EntryMapStyle.osmHot:
        return _buildOsmAttributionMarkdown(context, l10n.mapAttributionOsmHot);
      case EntryMapStyle.stamenWatercolor:
        return _buildOsmAttributionMarkdown(context, l10n.mapAttributionStamen);
      default:
        return const SizedBox();
    }
  }

  Widget _buildOsmAttributionMarkdown(BuildContext context, String data) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: MarkdownBody(
        data: '${context.l10n.mapAttributionOsmData}${AText.separator}$data',
        selectable: true,
        styleSheet: MarkdownStyleSheet(
          a: TextStyle(color: theme.colorScheme.primary),
          p: theme.textTheme.bodySmall!.merge(const TextStyle(fontSize: InfoRowGroup.fontSize)),
        ),
        onTapLink: (text, href, title) => AvesApp.launchUrl(href),
      ),
    );
  }
}
