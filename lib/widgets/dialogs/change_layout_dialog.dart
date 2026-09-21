import 'package:aves/model/settings/settings.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/theme/styles.dart';
import 'package:aves/theme/themes.dart';
import 'package:aves/widgets/common/basic/divider.dart';
import 'package:aves/widgets/common/basic/font_size_icon_theme.dart';
import 'package:aves/widgets/common/basic/text/change_highlight.dart';
import 'package:aves/widgets/common/basic/text_dropdown_button.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/extensions/theme.dart';
import 'package:aves/widgets/common/fx/rotator.dart';
import 'package:aves/widgets/common/fx/transitions.dart';
import 'package:aves/widgets/common/identity/highlight_title.dart';
import 'package:aves/widgets/common/tile_extent_controller.dart';
import 'package:aves_model/aves_model.dart';
import 'package:aves_utils/aves_utils.dart';
import 'package:decorated_icon/decorated_icon.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import 'aves_dialog.dart';

class const ChangeLayoutDialog<G>({
  super.key,
  required final (TileLayout layout, SortFactor sort, G section, bool reverse) initialValue,
  final List<ChangeLayoutDialogOption<TileLayout>> layoutOptions = const [],
  final List<ChangeLayoutDialogOption<SortFactor>> sortOptions = const [],
  final List<ChangeLayoutDialogOption<G>> sectionOptions = const [],
  required final String Function(SortFactor sort, bool reverse) sortOrder,
  final bool Function(TileLayout? layout, SortFactor? sort, G? section)? canSection,
  required final TileExtentController tileExtentController,
}) extends StatefulWidget {
  static const routeName = '/dialog/change_layout';

  @override
  State<ChangeLayoutDialog> createState() => _ChangeLayoutDialogState<G>();
}

class _ChangeLayoutDialogState<G> extends State<ChangeLayoutDialog<G>> with SingleTickerProviderStateMixin {
  late TileLayout _selectedLayout;
  late SortFactor _selectedSort;
  late G _selectedSection;
  late bool _reverseSort;
  late int _columnMin, _columnMax;
  final AChangeNotifier _sortReversedNotifier = AChangeNotifier();
  late final ValueNotifier<int> _columnCountNotifier = ValueNotifier(tileExtentController.columnCount);

  List<ChangeLayoutDialogOption<TileLayout>> get layoutOptions => widget.layoutOptions;

  List<ChangeLayoutDialogOption<SortFactor>> get sortOptions => widget.sortOptions;

  List<ChangeLayoutDialogOption<G>> get sectionOptions => widget.sectionOptions;

  TileExtentController get tileExtentController => widget.tileExtentController;

  bool get canSection => (widget.canSection ?? (l, s, g) => true).call(_selectedLayout, _selectedSort, _selectedSection);

  @override
  void initState() {
    super.initState();
    final initialValue = widget.initialValue;
    _selectedLayout = initialValue.$1;
    _selectedSort = initialValue.$2;
    _selectedSection = initialValue.$3;
    _reverseSort = initialValue.$4;

    final extentController = tileExtentController;
    final columnRange = extentController.effectiveColumnRange;
    _columnMin = columnRange.$1;
    _columnMax = columnRange.$2;
  }

  @override
  void dispose() {
    _columnCountNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return AvesDialog(
      scrollableContent: [
        const SizedBox(height: 4),
        _buildSelector(
          showDivider: false,
          icon: AIcons.layout,
          title: l10n.viewDialogLayoutSectionTitle,
          options: layoutOptions,
          value: _selectedLayout,
          onChanged: (v) {
            _selectedLayout = v as TileLayout;
            if (_selectedLayout == .calendar) {
              _selectedSort = .date;
            }
          },
        ),
        _buildSelector(
          enabled: _selectedLayout != .calendar,
          icon: AIcons.sort,
          title: l10n.viewDialogSortSectionTitle,
          options: sortOptions,
          value: _selectedSort,
          onChanged: (v) {
            _selectedSort = v as SortFactor;
            _reverseSort = false;
          },
          bottom: _buildSortOrderToggle(context),
        ),
        _buildSelector(
          show: canSection,
          icon: AIcons.section,
          title: l10n.viewDialogGroupSectionTitle,
          options: sectionOptions,
          value: _selectedSection,
          onChanged: (v) => _selectedSection = v as G,
        ),
        if (settings.showPinchGestureAlternatives)
          AnimatedSwitcher(
            duration: context.select<DurationsData, Duration>((v) => v.formTransition),
            switchInCurve: Curves.easeInOutCubic,
            switchOutCurve: Curves.easeInOutCubic,
            transitionBuilder: AvesTransitions.formTransitionBuilder,
            child: _selectedLayout != .calendar ? _buildScaler() : const SizedBox(),
          ),
      ],
      actions: [
        const CancelButton(),
        TextButton(
          key: const Key('button-apply'),
          onPressed: () {
            tileExtentController.setUserPreferredColumnCount(_columnCountNotifier.value);
            Navigator.maybeOf(context)?.pop<(TileLayout, SortFactor, G, bool)>((_selectedLayout, _selectedSort, _selectedSection, _reverseSort));
          },
          child: Text(l10n.applyButtonLabel),
        ),
      ],
    );
  }

  Widget _buildSortOrderToggle(BuildContext context) {
    Widget icon = IconButton(
      icon: const Icon(AIcons.sortOrder),
      onPressed: _toggleSortOrder,
      tooltip: context.l10n.viewDialogReverseSortOrder,
    );

    final animate = context.select<Settings, bool>((v) => v.animate);
    if (animate) {
      icon = Rotator(
        listenable: _sortReversedNotifier,
        child: icon,
      );
    }

    return Row(
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.only(start: 4),
          child: icon,
        ),
        GestureDetector(
          onTap: _toggleSortOrder,
          child: ChangeHighlightText(
            TextSpan(text: widget.sortOrder(_selectedSort, _reverseSort)),
            textStyle: TextDropdownButton.textStyle(context),
            duration: context.read<DurationsData>().formTextStyleTransition,
          ),
        ),
      ],
    );
  }

  void _toggleSortOrder() {
    _sortReversedNotifier.notify();
    setState(() => _reverseSort = !_reverseSort);
  }

  Widget _buildSelector<T>({
    bool show = true,
    bool showDivider = true,
    bool enabled = true,
    required IconData icon,
    required String title,
    required List<ChangeLayoutDialogOption<T>> options,
    required T value,
    required ValueChanged<T?> onChanged,
    Widget? bottom,
  }) {
    Widget child = const SizedBox();

    if (options.isNotEmpty && show) {
      final shadows = Theme.of(context).isDark ? AStyles.embossShadows : null;

      final label = FontSizeIconTheme(
        child: Row(
          children: [
            DecoratedIcon(icon, shadows: shadows),
            const SizedBox(width: 16),
            Expanded(
              child: HighlightTitle(
                title: title,
                showHighlight: false,
              ),
            ),
          ],
        ),
      );
      final selector = TextDropdownButton<T>(
        values: options.map((v) => v.value).toList(),
        valueText: (v) => options.firstWhere((option) => option.value == v).title,
        valueIcon: (v) => options.firstWhere((option) => option.value == v).icon,
        value: value,
        onChanged: enabled ? (v) => setState(() => onChanged(v)) : null,
        isExpanded: true,
        dropdownColor: Themes.thirdLayerColor(context),
        iconTextPadding: 12,
      );

      final textScaler = MediaQuery.textScalerOf(context);
      final iconSize = textScaler.scale(IconTheme.of(context).size!);
      child = context.isPortrait
          ? Column(
              mainAxisSize: .min,
              crossAxisAlignment: .start,
              children: [
                label,
                Padding(
                  padding: EdgeInsetsDirectional.only(start: iconSize + 16),
                  child: selector,
                ),
                if (bottom != null)
                  Padding(
                    padding: EdgeInsetsDirectional.only(start: iconSize),
                    child: bottom,
                  ),
              ],
            )
          : Row(
              mainAxisSize: .min,
              crossAxisAlignment: .start,
              children: [
                Expanded(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: kMinInteractiveDimension),
                    child: label,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: .start,
                    children: [
                      selector,
                      ?bottom,
                    ],
                  ),
                ),
              ],
            );

      child = TooltipTheme(
        data: TooltipTheme.of(context).copyWith(
          preferBelow: false,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: child,
        ),
      );

      child = Column(
        children: [
          if (showDivider) const ThinDivider(),
          child,
        ],
      );
    }

    return AnimatedSwitcher(
      duration: context.select<DurationsData, Duration>((v) => v.formTransition),
      switchInCurve: Curves.easeInOutCubic,
      switchOutCurve: Curves.easeInOutCubic,
      transitionBuilder: AvesTransitions.formTransitionBuilder,
      child: child,
    );
  }

  Widget _buildScaler() {
    return Column(
      children: [
        const ThinDivider(),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Row(
            children: [
              const Icon(AIcons.thumbnailLarge),
              Expanded(
                child: ValueListenableBuilder<int>(
                  valueListenable: _columnCountNotifier,
                  builder: (context, columnCount, child) => Slider(
                    label: context.l10n.columnCount(columnCount),
                    value: columnCount.toDouble(),
                    onChanged: (v) => _columnCountNotifier.value = v.round(),
                    min: _columnMin.toDouble(),
                    max: _columnMax.toDouble(),
                    divisions: (_columnMax - _columnMin),
                  ),
                ),
              ),
              const Icon(AIcons.thumbnailSmall),
            ],
          ),
        ),
      ],
    );
  }
}

@immutable
class const ChangeLayoutDialogOption<T>({
  required final T value,
  required final String title,
  required final IconData icon,
});
