import 'package:aves/model/settings/settings.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/theme/styles.dart';
import 'package:aves/theme/themes.dart';
import 'package:aves/widgets/common/basic/divider.dart';
import 'package:aves/widgets/common/basic/font_size_icon_theme.dart';
import 'package:aves/widgets/common/basic/text/animated_diff.dart';
import 'package:aves/widgets/common/basic/text_dropdown_button.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/extensions/theme.dart';
import 'package:aves/widgets/common/fx/transitions.dart';
import 'package:aves/widgets/common/identity/highlight_title.dart';
import 'package:aves/widgets/common/tile_extent_controller.dart';
import 'package:decorated_icon/decorated_icon.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import 'aves_dialog.dart';

class const ChangeLayoutDialog<L, S, G>({
  super.key,
  required final (L layout, S sort, G section, bool reverse) initialValue,
  final List<ChangeLayoutDialogOption<L>> layoutOptions = const [],
  final List<ChangeLayoutDialogOption<S>> sortOptions = const [],
  final List<ChangeLayoutDialogOption<G>> sectionOptions = const [],
  required final String Function(S sort, bool reverse) sortOrder,
  final bool Function(L? layout, S? sort, G? section)? canSort,
  final bool Function(L? layout, S? sort, G? section)? canSection,
  final bool Function(L? layout, S? sort, G? section)? canScale,
  required final TileExtentController tileExtentController,
}) extends StatefulWidget {
  static const routeName = '/dialog/change_layout';

  @override
  State<ChangeLayoutDialog> createState() => _ChangeLayoutDialogState<L, S, G>();
}

class _ChangeLayoutDialogState<L, S, G> extends State<ChangeLayoutDialog<L, S, G>> with SingleTickerProviderStateMixin {
  late L _selectedLayout;
  late S _selectedSort;
  late G _selectedSection;
  late bool _reverseSort;
  late int _columnMin, _columnMax;
  late final ValueNotifier<int> _columnCountNotifier = ValueNotifier(tileExtentController.columnCount);

  List<ChangeLayoutDialogOption<L>> get layoutOptions => widget.layoutOptions;

  List<ChangeLayoutDialogOption<S>> get sortOptions => widget.sortOptions;

  List<ChangeLayoutDialogOption<G>> get sectionOptions => widget.sectionOptions;

  TileExtentController get tileExtentController => widget.tileExtentController;

  bool get canSort => (widget.canSort ?? (l, s, g) => true).call(_selectedLayout, _selectedSort, _selectedSection);

  bool get canSection => (widget.canSection ?? (l, s, g) => true).call(_selectedLayout, _selectedSort, _selectedSection);

  bool get canScale => (widget.canScale ?? (l, s, g) => true).call(_selectedLayout, _selectedSort, _selectedSection);

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

    final duration = context.select<DurationsData, Duration>((v) => v.formTransition);
    const transitionBuilder = AvesTransitions.formTransitionBuilder;
    return AvesDialog(
      scrollableContent: [
        _buildSelector(
          icon: AIcons.layout,
          title: l10n.viewDialogLayoutSectionTitle,
          options: layoutOptions,
          value: _selectedLayout,
          onChanged: (v) => _selectedLayout = v as L,
        ),
        AnimatedSwitcher(
          duration: duration,
          switchInCurve: Curves.easeInOutCubic,
          switchOutCurve: Curves.easeInOutCubic,
          transitionBuilder: transitionBuilder,
          child: _buildSelector(
            show: canSort,
            icon: AIcons.sort,
            title: l10n.viewDialogSortSectionTitle,
            options: sortOptions,
            value: _selectedSort,
            onChanged: (v) {
              _selectedSort = v as S;
              _reverseSort = false;
            },
            bottom: _selectedSort != null
                ? Row(
                    children: [
                      Expanded(
                        child: AnimatedDiffText(
                          widget.sortOrder(_selectedSort, _reverseSort),
                          duration: duration,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(AIcons.sortOrder),
                        onPressed: () => setState(() => _reverseSort = !_reverseSort),
                        tooltip: l10n.viewDialogReverseSortOrder,
                      ),
                    ],
                  )
                : null,
          ),
        ),
        AnimatedSwitcher(
          duration: duration,
          switchInCurve: Curves.easeInOutCubic,
          switchOutCurve: Curves.easeInOutCubic,
          transitionBuilder: transitionBuilder,
          child: _buildSelector(
            show: canSection,
            icon: AIcons.section,
            title: l10n.viewDialogGroupSectionTitle,
            options: sectionOptions,
            value: _selectedSection,
            onChanged: (v) => _selectedSection = v as G,
          ),
        ),
        if (settings.showPinchGestureAlternatives)
          AnimatedSwitcher(
            duration: duration,
            switchInCurve: Curves.easeInOutCubic,
            switchOutCurve: Curves.easeInOutCubic,
            transitionBuilder: transitionBuilder,
            child: _buildScaler(
              show: canScale,
            ),
          ),
      ],
      actions: [
        const CancelButton(),
        TextButton(
          key: const Key('button-apply'),
          onPressed: () {
            tileExtentController.setUserPreferredColumnCount(_columnCountNotifier.value);
            Navigator.maybeOf(context)?.pop<(L, S, G, bool)>((_selectedLayout, _selectedSort, _selectedSection, _reverseSort));
          },
          child: Text(l10n.applyButtonLabel),
        ),
      ],
    );
  }

  Widget _buildSelector<T>({
    bool show = true,
    required IconData icon,
    required String title,
    required List<ChangeLayoutDialogOption<T>> options,
    required T value,
    required ValueChanged<T?> onChanged,
    Widget? bottom,
  }) {
    if (options.isEmpty || !show) return const SizedBox();

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
      onChanged: (v) => setState(() => onChanged(v)),
      isExpanded: true,
      dropdownColor: Themes.thirdLayerColor(context),
    );

    final textScaler = MediaQuery.textScalerOf(context);
    final iconSize = textScaler.scale(IconTheme.of(context).size!);
    final isPortrait = MediaQuery.orientationOf(context) == Orientation.portrait;
    Widget child = isPortrait
        ? Column(
            mainAxisSize: .min,
            crossAxisAlignment: .start,
            children: [
              label,
              Padding(
                padding: EdgeInsetsDirectional.only(start: iconSize + 16, end: 12),
                child: selector,
              ),
              if (bottom != null)
                Padding(
                  padding: EdgeInsetsDirectional.only(start: iconSize + 16),
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
        const ThinDivider(),
        child,
      ],
    );
    return child;
  }

  Widget _buildScaler({bool show = true}) {
    if (!show) return const SizedBox();

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
