import 'dart:async';

import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/theme/text.dart';
import 'package:aves/view/view.dart';
import 'package:aves/widgets/collection/app_bar.dart';
import 'package:aves/widgets/common/basic/text/change_highlight.dart';
import 'package:aves/widgets/common/basic/text/icon_span.dart';
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
  static const _padding = EdgeInsets.only(top: 4, bottom: 8);
  static const _chipPadding = EdgeInsets.symmetric(horizontal: 4);
  static const _rowPadding = EdgeInsets.symmetric(horizontal: 4);
  static final double preferredHeight = AvesFilterChip.minChipHeight + _padding.vertical;

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
    final filters = context.select<CollectionLens, Set<CollectionFilter>>((v) => v.visibleFilters);
    return Container(
      padding: LayoutBar._padding,
      height: LayoutBar.preferredHeight,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: LayoutBar._rowPadding,
        children: [
          _buildSortOrderToggle(
            icon: AIcons.sortOrder,
            name: l10n.viewDialogReverseSortOrder,
            animationTrigger: _sortReversedNotifier,
            onPressed: () => settings.setStoredCollectionSortReverse(filters, !settings.getStoredCollectionSortReverse(filters)),
          ),
          _buildSelector<TileLayout>(
            categoryIcon: AIcons.layout,
            dialogTitle: l10n.viewDialogLayoutSectionTitle,
            values: CollectionAppBar.layoutOptions,
            getIcon: (v) => v.icon,
            getName: (context, v) => v.getName(context),
            selector: (context, v) => v.getEffectiveCollectionTileLayout(filters),
            onSelection: (v) {
              settings.setStoredCollectionTileLayout(filters, v);
              if (settings.getEffectiveCollectionSortFactor(filters) != settings.getStoredCollectionSortFactor(filters)) {
                _onSortFactorChange(filters);
              }
            },
          ),
          _buildSelector<SortFactor>(
            enabled: context.select<Settings, bool>((v) => v.getEffectiveCollectionTileLayout(filters) != .calendar),
            categoryIcon: AIcons.sort,
            dialogTitle: l10n.viewDialogSortSectionTitle,
            values: CollectionAppBar.sortOptions,
            getIcon: (v) => v.icon,
            getName: (context, v) => v.getName(context),
            selector: (context, v) => v.getEffectiveCollectionSortFactor(filters),
            onSelection: (v) {
              settings.setStoredCollectionSortFactor(filters, v);
              _onSortFactorChange(filters);
            },
          ),
          _buildSelector<EntrySectionFactor>(
            enabled: context.select<Settings, bool>((v) => v.getEffectiveCollectionTileLayout(filters) != .calendar && v.getEffectiveCollectionSortFactor(filters) == .date),
            categoryIcon: AIcons.section,
            dialogTitle: l10n.viewDialogGroupSectionTitle,
            values: CollectionAppBar.sectionOptions,
            getIcon: (v) => v.icon,
            getName: (context, v) => v.getName(context),
            selector: (context, v) => v.getEffectiveCollectionSectionFactor(filters),
            onSelection: (v) => settings.setStoredCollectionSectionFactor(filters, v),
          ),
        ],
      ),
    );
  }

  void _onSortFactorChange(Set<CollectionFilter> filters) => settings.setStoredCollectionSortReverse(filters, false);

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
      padding: LayoutBar._chipPadding,
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
                    IconSpan(icon: categoryIcon),
                    const TextSpan(text: AText.separator),
                    IconSpan(icon: getIcon(current)),
                  ],
                ),
                duration: context.read<DurationsData>().formTextStyleTransition,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSortOrderToggle({
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
      padding: LayoutBar._chipPadding,
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
