import 'package:aves/widgets/common/identity/highlight_title.dart';
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:flutter/material.dart';

class AvesExpansionTile extends StatelessWidget {
  final String value;
  final Widget leading;
  final String title;
  final Color color;
  final ValueNotifier<String> expandedNotifier;
  final bool initiallyExpanded, showHighlight;
  final List<Widget> children;

  const AvesExpansionTile({
    String value,
    this.leading,
    @required this.title,
    this.color,
    this.expandedNotifier,
    this.initiallyExpanded = false,
    this.showHighlight = true,
    @required this.children,
  }): value = value ?? title;

  @override
  Widget build(BuildContext context) {
    final enabled = children?.isNotEmpty == true;
    Widget titleChild = HighlightTitle(
      title,
      color: color,
      enabled: enabled,
      showHighlight: showHighlight,
    );
    if (leading != null) {
      titleChild = Row(
        children: [
          leading,
          SizedBox(width: 8),
          Expanded(child: titleChild),
        ],
      );
    }
    return Theme(
      data: Theme.of(context).copyWith(
        // color used by the `ExpansionTileCard` for selected text and icons
        accentColor: Colors.white,
      ),
      child: ExpansionTileCard(
        key: Key('tilecard-$value'),
        value: value,
        expandedNotifier: expandedNotifier,
        title: titleChild,
        expandable: enabled,
        initiallyExpanded: initiallyExpanded,
        finalPadding: EdgeInsets.symmetric(vertical: 6.0),
        baseColor: Colors.grey[900],
        expandedColor: Colors.grey[850],
        shadowColor: Theme.of(context).shadowColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Divider(thickness: 1, height: 1),
            SizedBox(height: 4),
            if (enabled) ...children,
          ],
        ),
      ),
    );
  }
}
