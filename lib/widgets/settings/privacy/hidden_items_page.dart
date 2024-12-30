import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/basic/font_size_icon_theme.dart';
import 'package:aves/widgets/common/basic/scaffold.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/identity/aves_filter_chip.dart';
import 'package:aves/widgets/common/identity/empty.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HiddenItemsPage extends StatelessWidget {
  static const routeName = '/settings/hidden_items';

  const HiddenItemsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AvesScaffold(
      appBar: AppBar(
        automaticallyImplyLeading: !settings.useTvLayout,
        title: Text(l10n.settingsHiddenItemsPageTitle),
      ),
      body: SafeArea(
        child: Selector<Settings, Set<CollectionFilter>>(
          selector: (context, s) => settings.hiddenFilters.toSet(),
          builder: (context, activatedHiddenFilters, child) {
            return Selector<Settings, Set<CollectionFilter>>(
              selector: (context, s) => settings.deactivatedHiddenFilters.toSet(),
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
        ),
      ),
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
