import 'package:aves/model/filters/container/album_group.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/identity/buttons/outlined_button.dart';
import 'package:aves/widgets/dialogs/pick_dialogs/album_pick_page.dart';
import 'package:aves/widgets/filter_grids/common/enums.dart';
import 'package:aves/widgets/navigation/drawer/tile.dart';
import 'package:aves/widgets/settings/navigation/drawer_editor_banner.dart';
import 'package:flutter/material.dart';

class DrawerAlbumTab extends StatefulWidget {
  final List<AlbumBaseFilter> items;

  const DrawerAlbumTab({
    super.key,
    required this.items,
  });

  @override
  State<DrawerAlbumTab> createState() => _DrawerAlbumTabState();
}

class _DrawerAlbumTabState extends State<DrawerAlbumTab> {
  List<AlbumBaseFilter> get items => widget.items;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (!settings.useTvLayout) ...[
          const DrawerEditorBanner(),
          const Divider(height: 0),
        ],
        Flexible(
          child: ReorderableListView.builder(
            itemBuilder: (context, index) {
              final filter = items[index];
              void onPressed() => setState(() => items.remove(filter));
              return ListTile(
                key: ValueKey(filter.key),
                leading: DrawerFilterIcon(filter: filter),
                title: DrawerFilterTitle(filter: filter),
                trailing: IconButton(
                  icon: const Icon(AIcons.clear),
                  onPressed: onPressed,
                  tooltip: context.l10n.actionRemove,
                ),
                onTap: settings.useTvLayout ? onPressed : null,
              );
            },
            itemCount: items.length,
            onReorder: (oldIndex, newIndex) {
              setState(() {
                if (oldIndex < newIndex) newIndex -= 1;
                items.insert(newIndex, items.removeAt(oldIndex));
              });
            },
            shrinkWrap: true,
          ),
        ),
        const Divider(height: 0),
        const SizedBox(height: 8),
        SafeArea(
          child: AvesOutlinedButton(
            icon: const Icon(AIcons.add),
            label: context.l10n.settingsNavigationDrawerAddAlbum,
            onPressed: () async {
              final albumFilter = await pickAlbum(
                context: context,
                moveType: null,
                chipTypes: AlbumChipType.values,
                initialGroup: null,
              );
              if (albumFilter == null || items.contains(albumFilter)) return;
              setState(() => items.add(albumFilter));
            },
          ),
        ),
      ],
    );
  }
}
