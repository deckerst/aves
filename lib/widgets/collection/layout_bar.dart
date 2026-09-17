import 'dart:async';

import 'package:aves/model/settings/settings.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/theme/text.dart';
import 'package:aves/view/view.dart';
import 'package:aves/widgets/collection/app_bar.dart';
import 'package:aves/widgets/collection/collection_page.dart';
import 'package:aves/widgets/common/basic/text/change_highlight.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/fx/rotator.dart';
import 'package:aves/widgets/common/identity/aves_filter_chip.dart';
import 'package:aves/widgets/dialogs/selection_dialogs/common.dart';
import 'package:aves/widgets/dialogs/selection_dialogs/single_selection.dart';
import 'package:aves_model/aves_model.dart';
import 'package:aves_utils/aves_utils.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

class const LayoutBar({super.key}) extends StatefulWidget {
  static const EdgeInsets chipPadding = EdgeInsets.symmetric(horizontal: 4);
  static const EdgeInsets rowPadding = EdgeInsets.symmetric(horizontal: 4);
  static const EdgeInsets padding = EdgeInsets.only(top: 4, bottom: 8);
  static final double preferredHeight = AvesFilterChip.minChipHeight + padding.vertical;

  @override
  State<LayoutBar> createState() => _LayoutBarState();
}

class _LayoutBarState extends State<LayoutBar> {
  final Set<StreamSubscription> _subscriptions = {};
  final AChangeNotifier _sortReversedNotifier = AChangeNotifier();

  @override
  void initState() {
    super.initState();
    _subscriptions.add(settings.updateStream.where((event) => event.key == SettingKeys.collectionSortReverseKey).listen((_) => _sortReversedNotifier.notify()));
  }

  @override
  void dispose() {
    _subscriptions
      ..forEach((sub) => sub.cancel())
      ..clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      padding: LayoutBar.padding,
      height: LayoutBar.preferredHeight,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: LayoutBar.rowPadding,
        children: [
          _buildToggler(
            icon: AIcons.sortOrder,
            name: l10n.viewDialogReverseSortOrder,
            animationTrigger: _sortReversedNotifier,
            onPressed: () => settings.collectionSortReverse = !settings.collectionSortReverse,
          ),
          _buildSelector<TileLayout>(
            categoryIcon: AIcons.layout,
            dialogTitle: l10n.viewDialogLayoutSectionTitle,
            values: CollectionAppBar.layoutOptions,
            getIcon: (v) => v.icon,
            getName: (context, v) => v.getName(context),
            selector: (context, v) => v.effectiveCollectionTileLayout,
            onSelection: (v) {
              settings.setTileLayout(CollectionPage.routeName, v);
              if (settings.effectiveCollectionSortFactor != settings.collectionSortFactor) {
                _onSortFactorChange();
              }
            },
          ),
          _buildSelector<SortFactor>(
            enabled: context.select<Settings, bool>((v) => v.effectiveCollectionTileLayout != .calendar),
            categoryIcon: AIcons.sort,
            dialogTitle: l10n.viewDialogSortSectionTitle,
            values: CollectionAppBar.sortOptions,
            getIcon: (v) => v.icon,
            getName: (context, v) => v.getName(context),
            selector: (context, v) => v.effectiveCollectionSortFactor,
            onSelection: (v) {
              settings.collectionSortFactor = v;
              _onSortFactorChange();
            },
          ),
          _buildSelector<EntrySectionFactor>(
            enabled: context.select<Settings, bool>((v) => v.effectiveCollectionTileLayout != .calendar && v.effectiveCollectionSortFactor == .date),
            categoryIcon: AIcons.section,
            dialogTitle: l10n.viewDialogGroupSectionTitle,
            values: CollectionAppBar.sectionOptions,
            getIcon: (v) => v.icon,
            getName: (context, v) => v.getName(context),
            selector: (context, v) => v.effectiveCollectionSectionFactor,
            onSelection: (v) => settings.collectionSectionFactor = v,
          ),
        ],
      ),
    );
  }

  void _onSortFactorChange() => settings.collectionSortReverse = false;

  Widget _buildSelector<T>({
    required IconData categoryIcon,
    required String dialogTitle,
    required List<T> values,
    required IconData Function(T) getIcon,
    required String Function(BuildContext, T) getName,
    required T Function(BuildContext, Settings) selector,
    required ValueChanged<T> onSelection,
    bool show = true,
    bool enabled = true,
  }) {
    return Padding(
      padding: LayoutBar.chipPadding,
      child: Center(
        child: Selector<Settings, T>(
          selector: selector,
          builder: (context, current, child) {
            return OutlinedButton(
              style: _buttonStyle(context),
              onPressed: enabled
                  ? () => showSelectionDialog<T>(
                      context: context,
                      builder: (context) => AvesSingleSelectionDialog<T>(
                        initialValue: current,
                        options: Map.fromEntries(values.map((v) => MapEntry(v, getName(context, v)))),
                        optionIconBuilder: getIcon,
                        title: dialogTitle,
                      ),
                      onSelection: onSelection,
                    )
                  : null,
              child: ChangeHighlightText(
                TextSpan(
                  children: [
                    WidgetSpan(
                      child: Icon(categoryIcon),
                      alignment: PlaceholderAlignment.middle,
                    ),
                    const TextSpan(text: AText.separator),
                    WidgetSpan(
                      child: Icon(getIcon(current)),
                      alignment: PlaceholderAlignment.middle,
                    ),
                  ],
                ),
                textStyle: DefaultTextStyle.of(context).style,
                changeBlurRadius: 8,
                duration: context.read<DurationsData>().formTextStyleTransition,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildToggler({
    required IconData icon,
    required String name,
    required Listenable animationTrigger,
    required VoidCallback onPressed,
  }) {
    final animate = context.select<Settings, bool>((v) => v.animate);

    Widget child = Icon(icon);
    if (animate) {
      child = Rotator(
        listenable: animationTrigger,
        child: child,
      );
    }
    return Padding(
      padding: LayoutBar.chipPadding,
      child: Center(
        child: OutlinedButton(
          style: _buttonStyle(context),
          onPressed: onPressed,
          child: child,
        ),
      ),
    );
  }

  static ButtonStyle _buttonStyle(BuildContext context) {
    final theme = Theme.of(context);
    return ButtonStyle(
      foregroundColor: WidgetStateProperty.resolveWith<Color>((states) {
        return states.contains(WidgetState.disabled) ? theme.disabledColor : theme.colorScheme.onSurface;
      }),
      padding: WidgetStateProperty.resolveWith<EdgeInsetsGeometry>((states) => const EdgeInsets.symmetric(horizontal: 12)),
      minimumSize: WidgetStateProperty.resolveWith<Size>((states) => const Size.square(kMinInteractiveDimension)),
    );
  }
}
