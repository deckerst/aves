import 'package:aves/model/image_entry.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/app_bar_title.dart';
import 'package:aves/widgets/viewer/info/info_search.dart';
import 'package:aves/widgets/viewer/info/metadata/metadata_section.dart';
import 'package:flutter/material.dart';

class InfoAppBar extends StatelessWidget {
  final ImageEntry entry;
  final ValueNotifier<Map<String, MetadataDirectory>> metadataNotifier;
  final VoidCallback onBackPressed;

  const InfoAppBar({
    @required this.entry,
    @required this.metadataNotifier,
    @required this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      leading: IconButton(
        key: Key('back-button'),
        icon: Icon(AIcons.goUp),
        onPressed: onBackPressed,
        tooltip: 'Back to viewer',
      ),
      title: TappableAppBarTitle(
        onTap: () => _goToSearch(context),
        child: Text('Info'),
      ),
      actions: [
        IconButton(
          icon: Icon(AIcons.search),
          onPressed: () => _goToSearch(context),
          tooltip: 'Search',
        ),
      ],
      titleSpacing: 0,
      floating: true,
    );
  }

  void _goToSearch(BuildContext context) {
    showSearch(
      context: context,
      delegate: InfoSearchDelegate(
        entry: entry,
        metadataNotifier: metadataNotifier,
      ),
    );
  }
}
