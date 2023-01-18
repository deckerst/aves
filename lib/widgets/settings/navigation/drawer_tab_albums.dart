import 'package:aves/model/filters/album.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/identity/buttons/outlined_button.dart';
import 'package:aves/widgets/dialogs/pick_dialogs/album_pick_page.dart';
import 'package:aves/widgets/navigation/drawer/tile.dart';
import 'package:aves/widgets/settings/navigation/drawer_editor_banner.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DrawerAlbumTab extends StatefulWidget {
  final List<String> items;

  const DrawerAlbumTab({
    super.key,
    required this.items,
  });

  @override
  State<DrawerAlbumTab> createState() => _DrawerAlbumTabState();
}

class _DrawerAlbumTabState extends State<DrawerAlbumTab> {
  List<String> get items => widget.items;

  @override
  Widget build(BuildContext context) {
    final source = context.read<CollectionSource>();
    return Column(
      children: [
        const DrawerEditorBanner(),
        const Divider(height: 0),
        Flexible(
          child: ReorderableListView.builder(
            itemBuilder: (context, index) {
              final album = items[index];
              final filter = AlbumFilter(album, source.getAlbumDisplayName(context, album));
              return ListTile(
                key: ValueKey(album),
                leading: DrawerFilterIcon(filter: filter),
                title: DrawerFilterTitle(filter: filter),
                trailing: IconButton(
                  icon: const Icon(AIcons.clear),
                  onPressed: () {
                    setState(() => items.remove(album));
                  },
                  tooltip: context.l10n.actionRemove,
                ),
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
        AvesOutlinedButton(
          icon: const Icon(AIcons.add),
          label: context.l10n.settingsNavigationDrawerAddAlbum,
          onPressed: () async {
            final album = await pickAlbum(context: context, moveType: null);
            if (album == null || items.contains(album)) return;
            setState(() => items.add(album));
          },
        ),
      ],
    );
  }
}
