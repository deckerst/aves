import 'package:aves/model/device.dart';
import 'package:aves/theme/themes.dart';
import 'package:aves/widgets/about/app_ref.dart';
import 'package:aves/widgets/about/credits.dart';
import 'package:aves/widgets/about/translators.dart';
import 'package:aves/widgets/about/tv_license_page.dart';
import 'package:aves/widgets/common/basic/insets.dart';
import 'package:aves/widgets/common/basic/scaffold.dart';
import 'package:aves/widgets/common/behaviour/pop/scope.dart';
import 'package:aves/widgets/common/behaviour/pop/tv_navigation.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/identity/buttons/outlined_button.dart';
import 'package:aves/widgets/navigation/tv_rail.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AboutTvPage extends StatelessWidget {
  const AboutTvPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AvesScaffold(
      body: AvesPopScope(
        handlers: [tvNavigationPopHandler],
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
                      title: Text(context.l10n.aboutPageTitle),
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

enum _Section { links, credits, translators, licenses }

class _ContentState extends State<_Content> {
  final FocusNode _railFocusNode = FocusNode();
  final ValueNotifier<int> _railIndexNotifier = ValueNotifier(0);

  static const double railWidth = 256;

  @override
  void dispose() {
    _railIndexNotifier.dispose();
    _railFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: _railIndexNotifier,
      builder: (context, selectedIndex, child) {
        final rail = Focus(
          focusNode: _railFocusNode,
          skipTraversal: true,
          canRequestFocus: false,
          child: ConstrainedBox(
            constraints: BoxConstraints.loose(const Size.fromWidth(railWidth)),
            child: Center(
              child: ListView.builder(
                itemBuilder: (context, index) {
                  final isSelected = index == selectedIndex;
                  final theme = Theme.of(context);
                  final colors = theme.colorScheme;
                  return ListTile(
                    title: DefaultTextStyle(
                      style: theme.textTheme.bodyLarge!.copyWith(
                        color: isSelected ? colors.primary : colors.onSurface.withValues(alpha: .64),
                      ),
                      child: _getTitle(_Section.values[index]),
                    ),
                    selected: isSelected,
                    contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
                    onTap: () => _railIndexNotifier.value = index,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(123)),
                    ),
                  );
                },
                itemCount: _Section.values.length,
              ),
            ),
          ),
        );

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            rail,
            Expanded(
              child: MediaQuery.removePadding(
                context: context,
                removeLeft: !context.isRtl,
                removeRight: context.isRtl,
                child: _getBody(_Section.values[selectedIndex]),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _getTitle(_Section key) {
    switch (key) {
      case _Section.links:
        return Text('${context.l10n.appName} ${device.packageVersion}');
      case _Section.credits:
        return Text(context.l10n.aboutCreditsSectionTitle);
      case _Section.translators:
        return Text(context.l10n.aboutTranslatorsSectionTitle);
      case _Section.licenses:
        return Text(context.l10n.aboutLicensesSectionTitle);
    }
  }

  Widget _getBody(_Section key) {
    switch (key) {
      case _Section.links:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: AppReference.buildLinks(context)
              .map((v) => Padding(
                    padding: const EdgeInsets.all(16),
                    child: v,
                  ))
              .toList(),
        );
      case _Section.credits:
        return Padding(
          padding: const EdgeInsets.all(16),
          child: AboutCredits.buildBody(context),
        );
      case _Section.translators:
        return Padding(
          padding: const EdgeInsets.all(16),
          child: AboutTranslators.buildBody(context),
        );
      case _Section.licenses:
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(context.l10n.aboutLicensesBanner),
              const SizedBox(height: 16),
              Center(
                child: AvesOutlinedButton(
                  label: context.l10n.aboutLicensesShowAllButtonLabel,
                  onPressed: () => Navigator.maybeOf(context)?.push(
                    MaterialPageRoute(
                      builder: (context) {
                        final theme = Theme.of(context);
                        final listTileTheme = theme.listTileTheme;
                        return Theme(
                          data: theme.copyWith(
                            listTileTheme: listTileTheme.copyWith(
                              tileColor: Themes.firstLayerColor(context),
                            ),
                          ),
                          child: const TvLicensePage(),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
    }
  }
}
