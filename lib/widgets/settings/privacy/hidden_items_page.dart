import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/filters/path.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/basic/font_size_icon_theme.dart';
import 'package:aves/widgets/common/basic/scaffold.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/identity/aves_filter_chip.dart';
import 'package:aves/widgets/common/identity/buttons/outlined_button.dart';
import 'package:aves/widgets/common/identity/empty.dart';
import 'package:aves/widgets/settings/privacy/file_picker/file_picker_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';

class HiddenItemsPage extends StatelessWidget {
  static const routeName = '/settings/hidden_items';

  const HiddenItemsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tabs = <(Tab, Widget)>[
      (
        Tab(text: l10n.settingsHiddenItemsTabFilters),
        const _HiddenFilters(),
      ),
      (
        Tab(text: l10n.settingsHiddenItemsTabPaths),
        const _HiddenPaths(),
      ),
    ];

    return DefaultTabController(
      length: tabs.length,
      child: AvesScaffold(
        appBar: AppBar(
          automaticallyImplyLeading: !settings.useTvLayout,
          title: Text(l10n.settingsHiddenItemsPageTitle),
          bottom: TabBar(
            tabs: tabs.map((t) => t.$1).toList(),
          ),
        ),
        body: SafeArea(
          child: TabBarView(
            children: tabs.map((t) => t.$2).toList(),
          ),
        ),
      ),
    );
  }
}

class _HiddenFilters extends StatelessWidget {
  const _HiddenFilters();

  @override
  Widget build(BuildContext context) {
    bool filterPredicate(CollectionFilter v) => v is! PathFilter;
    return Selector<Settings, Set<CollectionFilter>>(
      selector: (context, s) => settings.hiddenFilters.where(filterPredicate).toSet(),
      builder: (context, activatedHiddenFilters, child) {
        return Selector<Settings, Set<CollectionFilter>>(
          selector: (context, s) => settings.deactivatedHiddenFilters.where(filterPredicate).toSet(),
          builder: (context, deactivatedHiddenFilters, child) {
            final allHiddenFilters = {
              ...activatedHiddenFilters,
              ...deactivatedHiddenFilters,
            };
            if (allHiddenFilters.isEmpty) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Banner(bannerText: context.l10n.settingsHiddenFiltersBanner),
                  const Divider(height: 0),
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

            final filterList = allHiddenFilters.toList()..sort();
            return ListView(
              children: [
                _Banner(bannerText: context.l10n.settingsHiddenFiltersBanner),
                const Divider(height: 0),
                const SizedBox(height: 8),
                ...filterList.map((filter) {
                  void onRemove(CollectionFilter filter) => settings.changeFilterVisibility({filter}, true);
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              return Row(
                                children: [
                                  AvesFilterChip(
                                    filter: filter,
                                    maxWidth: constraints.maxWidth,
                                    onTap: onRemove,
                                    onRemove: onRemove,
                                    onLongPress: null,
                                  ),
                                  const Spacer(),
                                ],
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Switch(
                          value: activatedHiddenFilters.contains(filter),
                          onChanged: (v) => settings.activateHiddenFilter(filter, v),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            );
          },
        );
      },
    );
  }
}

class _HiddenPaths extends StatelessWidget {
  const _HiddenPaths();

  @override
  Widget build(BuildContext context) {
    return Selector<Settings, Set<PathFilter>>(
      selector: (context, s) => {
        ...settings.hiddenFilters,
        ...settings.deactivatedHiddenFilters,
      }.whereType<PathFilter>().toSet(),
      builder: (context, hiddenPaths, child) {
        final pathList = hiddenPaths.toList()..sort();
        return Column(
          children: [
            _Banner(bannerText: context.l10n.settingsHiddenPathsBanner),
            const Divider(height: 0),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  ...pathList.map((pathFilter) {
                    void onPressed() => settings.changeFilterVisibility({pathFilter}, true);
                    return ListTile(
                      title: Text(pathFilter.path),
                      dense: true,
                      trailing: IconButton(
                        icon: const Icon(AIcons.clear),
                        onPressed: onPressed,
                        tooltip: context.l10n.actionRemove,
                      ),
                      onTap: settings.useTvLayout ? onPressed : null,
                    );
                  }),
                ],
              ),
            ),
            const Divider(height: 0),
            const SizedBox(height: 8),
            AvesOutlinedButton(
              icon: const Icon(AIcons.add),
              label: context.l10n.addPathTooltip,
              onPressed: () async {
                final path = await Navigator.maybeOf(context)?.push(
                  MaterialPageRoute<String>(
                    settings: const RouteSettings(name: FilePickerPage.routeName),
                    builder: (context) => const FilePickerPage(),
                  ),
                );
                // wait for the dialog to hide as applying the change may block the UI
                await Future.delayed(ADurations.pageTransitionAnimation * timeDilation);
                if (path != null && path.isNotEmpty) {
                  settings.changeFilterVisibility({PathFilter(path)}, false);
                }
              },
            ),
          ],
        );
      },
    );
  }
}

class _Banner extends StatelessWidget {
  final String bannerText;

  const _Banner({required this.bannerText});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const FontSizeIconTheme(child: Icon(AIcons.info)),
          const SizedBox(width: 16),
          Expanded(child: Text(bannerText)),
        ],
      ),
    );
  }
}
