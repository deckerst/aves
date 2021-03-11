import 'package:aves/widgets/common/identity/highlight_title.dart';
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:flutter/material.dart';

class AvesExpansionTile extends StatelessWidget {
  final String title;
  final Color color;
  final ValueNotifier<String> expandedNotifier;
  final bool initiallyExpanded;
  final List<Widget> children;

  const AvesExpansionTile({
    @required this.title,
    this.color,
    this.expandedNotifier,
    this.initiallyExpanded = false,
    @required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = children?.isNotEmpty == true;
    return Theme(
      data: Theme.of(context).copyWith(
        // color used by the `ExpansionTileCard` for selected text and icons
        accentColor: Colors.white,
      ),
      child: ExpansionTileCard(
        key: Key('tilecard-$title'),
        value: title,
        expandedNotifier: expandedNotifier,
        title: HighlightTitle(
          title,
          color: color,
          enabled: enabled,
        ),
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
