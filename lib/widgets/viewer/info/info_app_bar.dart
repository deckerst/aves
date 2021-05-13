import 'package:aves/model/entry.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/app_bar_title.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/viewer/info/info_search.dart';
import 'package:aves/widgets/viewer/info/metadata/metadata_section.dart';
import 'package:flutter/material.dart';

class InfoAppBar extends StatelessWidget {
  final AvesEntry entry;
  final ValueNotifier<Map<String, MetadataDirectory>> metadataNotifier;
  final VoidCallback onBackPressed;

  const InfoAppBar({
    required this.entry,
    required this.metadataNotifier,
    required this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      leading: IconButton(
        key: Key('back-button'),
        icon: Icon(AIcons.goUp),
        onPressed: onBackPressed,
        tooltip: context.l10n.viewerInfoBackToViewerTooltip,
      ),
      title: InteractiveAppBarTitle(
        onTap: () => _goToSearch(context),
        child: Text(context.l10n.viewerInfoPageTitle),
      ),
      actions: [
        IconButton(
          icon: Icon(AIcons.search),
          onPressed: () => _goToSearch(context),
          tooltip: MaterialLocalizations.of(context).searchFieldLabel,
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
        searchFieldLabel: context.l10n.viewerInfoSearchFieldLabel,
        entry: entry,
        metadataNotifier: metadataNotifier,
      ),
    );
  }
}
