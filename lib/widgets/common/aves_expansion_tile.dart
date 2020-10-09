import 'package:aves/widgets/common/highlight_title.dart';
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:flutter/material.dart';

class AvesExpansionTile extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final ValueNotifier<String> expandedNotifier;

  const AvesExpansionTile({
    @required this.title,
    @required this.children,
    this.expandedNotifier,
  });

  @override
  Widget build(BuildContext context) {
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
          fontSize: 18,
        ),
        children: [
          Divider(thickness: 1, height: 1),
          SizedBox(height: 4),
          ...children,
        ],
        baseColor: Colors.grey[900],
        expandedColor: Colors.grey[850],
      ),
    );
  }
}
