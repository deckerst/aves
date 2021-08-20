import 'package:aves/model/filters/path.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/services/services.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/identity/empty.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HiddenPathTile extends StatelessWidget {
  const HiddenPathTile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(context.l10n.settingsHiddenPathsTile),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            settings: const RouteSettings(name: HiddenPathPage.routeName),
            builder: (context) => const HiddenPathPage(),
          ),
        );
      },
    );
  }
}

class HiddenPathPage extends StatelessWidget {
  static const routeName = '/settings/hidden_paths';

  const HiddenPathPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.settingsHiddenPathsTitle),
        actions: [
          IconButton(
            icon: const Icon(AIcons.add),
            onPressed: () async {
              final path = await storageService.selectDirectory();
              if (path != null && path.isNotEmpty) {
                context.read<CollectionSource>().changeFilterVisibility({PathFilter(path)}, false);
              }
            },
            tooltip: context.l10n.addPathTooltip,
          ),
        ],
      ),
      body: SafeArea(
        child: Selector<Settings, Set<PathFilter>>(
          selector: (context, s) => settings.hiddenFilters.whereType<PathFilter>().toSet(),
          builder: (context, hiddenPaths, child) {
            if (hiddenPaths.isEmpty) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _Header(),
                  const Divider(),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: EmptyContent(
                        icon: AIcons.hide,
                        text: context.l10n.settingsHiddenPathsEmpty,
                      ),
                    ),
                  ),
                ],
              );
            }

            final pathList = hiddenPaths.toList()..sort();
            return ListView(
              children: [
                const _Header(),
                const Divider(),
                ...pathList.map((pathFilter) => ListTile(
                      title: Text(pathFilter.path),
                      dense: true,
                      trailing: IconButton(
                        icon: const Icon(AIcons.clear),
                        onPressed: () {
                          context.read<CollectionSource>().changeFilterVisibility({pathFilter}, true);
                        },
                        tooltip: context.l10n.removeTooltip,
                      ),
                    )),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        children: [
          const Icon(AIcons.info),
          const SizedBox(width: 16),
          Expanded(child: Text(context.l10n.settingsHiddenPathsBanner)),
        ],
      ),
    );
  }
}
