import 'package:aves/widgets/common/basic/insets.dart';
import 'package:aves/widgets/common/basic/scaffold.dart';
import 'package:aves/widgets/common/behaviour/pop/scope.dart';
import 'package:aves/widgets/common/behaviour/pop/tv_navigation.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/navigation/tv_rail.dart';
import 'package:aves/widgets/settings/settings_definition.dart';
import 'package:aves/widgets/settings/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsTvPage extends StatelessWidget {
  const SettingsTvPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AvesScaffold(
      body: AvesPopScope(
        handlers: const [TvNavigationPopHandler.pop],
        child: Row(
          children: [
            TvRail(
              controller: context.read<TvRailController>(),
            ),
            Expanded(
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  DirectionalSafeArea(
                    start: false,
                    bottom: false,
                    child: AppBar(
                      automaticallyImplyLeading: false,
                      title: Text(context.l10n.settingsPageTitle),
                      elevation: 0,
                      primary: false,
                    ),
                  ),
                  Expanded(
                    child: MediaQuery.removePadding(
                      context: context,
                      removeLeft: true,
                      removeTop: true,
                      removeRight: true,
                      removeBottom: true,
                      child: const _Content(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Content extends StatefulWidget {
  const _Content();

  @override
  State<_Content> createState() => _ContentState();
}

class _ContentState extends State<_Content> {
  final ValueNotifier<int> _indexNotifier = ValueNotifier(0);

  @override
  void dispose() {
    _indexNotifier.dispose();
    super.dispose();
  }

  static final List<SettingsSection> sections = SettingsPage.sections;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: _indexNotifier,
      builder: (context, selectedIndex, child) {
        final rail = NavigationRail(
          extended: true,
          destinations: sections
              .map((section) => NavigationRailDestination(
                    icon: section.icon(context),
                    label: Text(section.title(context)),
                  ))
              .toList(),
          selectedIndex: selectedIndex,
          onDestinationSelected: (index) => _indexNotifier.value = index,
          minExtendedWidth: TvRail.minExtendedWidth,
        );
        return LayoutBuilder(
          builder: (context, constraints) {
            return Row(
              children: [
                SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: IntrinsicHeight(child: rail),
                  ),
                ),
                Expanded(
                  child: MediaQuery.removePadding(
                    context: context,
                    removeLeft: !context.isRtl,
                    removeRight: context.isRtl,
                    child: _Section(
                      loader: Future.value(sections[selectedIndex].tiles(context)),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _Section extends StatelessWidget {
  final Future<List<SettingsTile>> loader;

  const _Section({required this.loader});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<SettingsTile>>(
      future: loader,
      builder: (context, snapshot) {
        final tiles = snapshot.data;
        if (tiles == null) return const SizedBox();

        return SettingsListView(
          key: ValueKey(loader),
          children: tiles.map((v) => v.build(context)).toList(),
        );
      },
    );
  }
}
