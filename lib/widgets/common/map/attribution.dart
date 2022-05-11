import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/viewer/info/common.dart';
import 'package:aves_map/aves_map.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';

class Attribution extends StatelessWidget {
  final EntryMapStyle style;

  const Attribution({
    Key? key,
    required this.style,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    switch (style) {
      case EntryMapStyle.osmHot:
        return _buildAttributionMarkdown(context, context.l10n.mapAttributionOsmHot);
      case EntryMapStyle.stamenToner:
      case EntryMapStyle.stamenWatercolor:
        return _buildAttributionMarkdown(context, context.l10n.mapAttributionStamen);
      default:
        return const SizedBox();
    }
  }

  Widget _buildAttributionMarkdown(BuildContext context, String data) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: MarkdownBody(
        data: data,
        selectable: true,
        styleSheet: MarkdownStyleSheet(
          a: TextStyle(color: theme.colorScheme.secondary),
          p: theme.textTheme.caption!.merge(const TextStyle(fontSize: InfoRowGroup.fontSize)),
        ),
        onTapLink: (text, href, title) async {
          if (href != null) {
            final url = Uri.parse(href);
            if (await canLaunchUrl(url)) {
              await launchUrl(url, mode: LaunchMode.externalApplication);
            }
          }
        },
      ),
    );
  }
}
