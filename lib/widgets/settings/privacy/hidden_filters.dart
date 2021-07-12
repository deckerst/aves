import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/identity/aves_filter_chip.dart';
import 'package:aves/widgets/common/identity/empty.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HiddenFilterTile extends StatelessWidget {
  const HiddenFilterTile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(context.l10n.settingsHiddenFiltersTile),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            settings: const RouteSettings(name: HiddenFilterPage.routeName),
            builder: (context) => const HiddenFilterPage(),
          ),
        );
      },
    );
  }
}

class HiddenFilterPage extends StatelessWidget {
  static const routeName = '/settings/hidden';

  const HiddenFilterPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.settingsHiddenFiltersTitle),
      ),
      body: SafeArea(
        child: Selector<Settings, Set<CollectionFilter>>(
          selector: (context, s) => settings.hiddenFilters,
          builder: (context, hiddenFilters, child) {
            if (hiddenFilters.isEmpty) {
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
                        text: context.l10n.settingsHiddenFiltersEmpty,
                      ),
                    ),
                  ),
                ],
              );
            }

            final filterList = hiddenFilters.toList()..sort();
            return ListView(
              children: [
                const _Header(),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: filterList
                        .map((filter) => AvesFilterChip(
                              filter: filter,
                              removable: true,
                              onTap: (filter) => context.read<CollectionSource>().changeFilterVisibility({filter}, true),
                              onLongPress: null,
                            ))
                        .toList(),
                  ),
                ),
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
          Expanded(child: Text(context.l10n.settingsHiddenFiltersBanner)),
        ],
      ),
    );
  }
}
