import 'package:aves/model/settings/settings.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/theme/themes.dart';
import 'package:aves/widgets/common/basic/font_size_icon_theme.dart';
import 'package:aves/widgets/common/basic/text_dropdown_button.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/fx/transitions.dart';
import 'package:aves/widgets/common/identity/aves_caption.dart';
import 'package:aves/widgets/common/identity/highlight_title.dart';
import 'package:aves/widgets/common/tile_extent_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

import 'aves_dialog.dart';

class TileViewDialog<S, G, L> extends StatefulWidget {
  static const routeName = '/dialog/tile_view';

  final Tuple4<S?, G?, L?, bool> initialValue;
  final List<TileViewDialogOption<S>> sortOptions;
  final List<TileViewDialogOption<G>> groupOptions;
  final List<TileViewDialogOption<L>> layoutOptions;
  final String Function(S sort, bool reverse) sortOrder;
  final TileExtentController tileExtentController;
  final bool Function(S? sort, G? group, L? layout)? canGroup;

  const TileViewDialog({
    super.key,
    required this.initialValue,
    this.sortOptions = const [],
    this.groupOptions = const [],
    this.layoutOptions = const [],
    required this.sortOrder,
    this.canGroup,
    required this.tileExtentController,
  });

  @override
  State<TileViewDialog> createState() => _TileViewDialogState<S, G, L>();
}

class _TileViewDialogState<S, G, L> extends State<TileViewDialog<S, G, L>> with SingleTickerProviderStateMixin {
  late S? _selectedSort;
  late G? _selectedGroup;
  late L? _selectedLayout;
  late bool _reverseSort;
  late int _columnMin, _columnMax;
  late final ValueNotifier<int> _columnCountNotifier = ValueNotifier(tileExtentController.columnCount);

  List<TileViewDialogOption<S>> get sortOptions => widget.sortOptions;

  List<TileViewDialogOption<G>> get groupOptions => widget.groupOptions;

  List<TileViewDialogOption<L>> get layoutOptions => widget.layoutOptions;

  TileExtentController get tileExtentController => widget.tileExtentController;

  bool get canGroup => (widget.canGroup ?? (s, g, l) => true).call(_selectedSort, _selectedGroup, _selectedLayout);

  @override
  void initState() {
    super.initState();
    final initialValue = widget.initialValue;
    _selectedSort = initialValue.item1;
    _selectedGroup = initialValue.item2;
    _selectedLayout = initialValue.item3;
    _reverseSort = initialValue.item4;

    final extentController = tileExtentController;
    final columnRange = extentController.effectiveColumnRange;
    _columnMin = columnRange.$1;
    _columnMax = columnRange.$2;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return AvesDialog(
      scrollableContent: [
        _buildSection(
          icon: AIcons.sort,
          title: l10n.viewDialogSortSectionTitle,
          trailing: IconButton(
            icon: const Icon(AIcons.sortOrder),
            onPressed: () => setState(() => _reverseSort = !_reverseSort),
            tooltip: l10n.viewDialogReverseSortOrder,
          ),
          options: sortOptions,
          value: _selectedSort,
          onChanged: (v) {
            _selectedSort = v;
            _reverseSort = false;
          },
          bottom: _selectedSort != null ? AvesCaption(widget.sortOrder(_selectedSort as S, _reverseSort)) : null,
        ),
        AnimatedSwitcher(
          duration: context.read<DurationsData>().formTransition,
          switchInCurve: Curves.easeInOutCubic,
          switchOutCurve: Curves.easeInOutCubic,
          transitionBuilder: AvesTransitions.formTransitionBuilder,
          child: _buildSection(
            show: canGroup,
            icon: AIcons.group,
            title: l10n.viewDialogGroupSectionTitle,
            options: groupOptions,
            value: _selectedGroup,
            onChanged: (v) => _selectedGroup = v,
          ),
        ),
        _buildSection(
          icon: AIcons.layout,
          title: l10n.viewDialogLayoutSectionTitle,
          options: layoutOptions,
          value: _selectedLayout,
          onChanged: (v) => _selectedLayout = v,
        ),
        if (settings.showPinchGestureAlternatives)
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
      actions: [
        const CancelButton(),
        TextButton(
          key: const Key('button-apply'),
          onPressed: () {
            tileExtentController.setUserPreferredColumnCount(_columnCountNotifier.value);
            Navigator.maybeOf(context)?.pop(Tuple4(_selectedSort, _selectedGroup, _selectedLayout, _reverseSort));
          },
          child: Text(l10n.applyButtonLabel),
        )
      ],
    );
  }

  Widget _buildSection<T>({
    bool show = true,
    required IconData icon,
    required String title,
    Widget? trailing,
    required List<TileViewDialogOption<T>> options,
    required T value,
    required ValueChanged<T?> onChanged,
    Widget? bottom,
  }) {
    if (options.isEmpty || !show) return const SizedBox();

    final label = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: kMinInteractiveDimension),
      child: FontSizeIconTheme(
        child: Row(
          children: [
            Icon(icon),
            const SizedBox(width: 16),
            Expanded(
              child: HighlightTitle(
                title: title,
                showHighlight: false,
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
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

    final textScaleFactor = MediaQuery.textScaleFactorOf(context);
    final iconSize = IconTheme.of(context).size! * textScaleFactor;
    final isPortrait = MediaQuery.orientationOf(context) == Orientation.portrait;
    final child = isPortrait
        ? Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
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
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: label),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    selector,
                    if (bottom != null) bottom,
                  ],
                ),
              ),
            ],
          );

    return TooltipTheme(
      data: TooltipTheme.of(context).copyWith(
        preferBelow: false,
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 16, top: 8, right: 16),
        child: child,
      ),
    );
  }
}

@immutable
class TileViewDialogOption<T> {
  final T value;
  final String title;
  final IconData icon;

  const TileViewDialogOption({
    required this.value,
    required this.title,
    required this.icon,
  });
}
