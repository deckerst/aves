import 'package:aves/theme/durations.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/theme/themes.dart';
import 'package:aves/widgets/common/basic/text_dropdown_button.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/identity/highlight_title.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

import 'aves_dialog.dart';

class TileViewDialog<S, G, L> extends StatefulWidget {
  final Tuple4<S?, G?, L?, bool> initialValue;
  final Map<S, String> sortOptions;
  final Map<G, String> groupOptions;
  final Map<L, String> layoutOptions;
  final String Function(S sort, bool reverse) sortOrder;
  final bool Function(S? sort, G? group, L? layout)? canGroup;

  const TileViewDialog({
    super.key,
    required this.initialValue,
    this.sortOptions = const {},
    this.groupOptions = const {},
    this.layoutOptions = const {},
    required this.sortOrder,
    this.canGroup,
  });

  @override
  State<TileViewDialog> createState() => _TileViewDialogState<S, G, L>();
}

class _TileViewDialogState<S, G, L> extends State<TileViewDialog<S, G, L>> with SingleTickerProviderStateMixin {
  late S? _selectedSort;
  late G? _selectedGroup;
  late L? _selectedLayout;
  late bool _reverseSort;

  Map<S, String> get sortOptions => widget.sortOptions;

  Map<G, String> get groupOptions => widget.groupOptions;

  Map<L, String> get layoutOptions => widget.layoutOptions;

  bool get canGroup => (widget.canGroup ?? (s, g, l) => true).call(_selectedSort, _selectedGroup, _selectedLayout);

  @override
  void initState() {
    super.initState();
    final initialValue = widget.initialValue;
    _selectedSort = initialValue.item1;
    _selectedGroup = initialValue.item2;
    _selectedLayout = initialValue.item3;
    _reverseSort = initialValue.item4;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return AvesDialog(
      scrollableContent: [
        _buildSection(
          icon: AIcons.sort,
          title: l10n.viewDialogTabSort,
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
          bottom: _selectedSort != null
              ? Text(
                  widget.sortOrder(_selectedSort as S, _reverseSort),
                  style: Theme.of(context).textTheme.caption,
                )
              : null,
        ),
        AnimatedSwitcher(
          duration: context.read<DurationsData>().formTransition,
          switchInCurve: Curves.easeInOutCubic,
          switchOutCurve: Curves.easeInOutCubic,
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: SizeTransition(
              sizeFactor: animation,
              axisAlignment: -1,
              child: child,
            ),
          ),
          child: _buildSection(
            show: canGroup,
            icon: AIcons.group,
            title: l10n.viewDialogTabGroup,
            options: groupOptions,
            value: _selectedGroup,
            onChanged: (v) => _selectedGroup = v,
          ),
        ),
        _buildSection(
          icon: AIcons.layout,
          title: l10n.viewDialogTabLayout,
          options: layoutOptions,
          value: _selectedLayout,
          onChanged: (v) => _selectedLayout = v,
        ),
      ],
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
        ),
        TextButton(
          key: const Key('button-apply'),
          onPressed: () => Navigator.pop(context, Tuple4(_selectedSort, _selectedGroup, _selectedLayout, _reverseSort)),
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
    required Map<T, String> options,
    required T value,
    required ValueChanged<T?> onChanged,
    Widget? bottom,
  }) {
    if (options.isEmpty || !show) return const SizedBox();

    final iconSize = IconTheme.of(context).size! * MediaQuery.textScaleFactorOf(context);
    return TooltipTheme(
      data: TooltipTheme.of(context).copyWith(
        preferBelow: false,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(
                minHeight: kMinInteractiveDimension,
              ),
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
            Padding(
              padding: EdgeInsetsDirectional.only(start: iconSize + 16, end: 12),
              child: TextDropdownButton<T>(
                values: options.keys.toList(),
                valueText: (v) => options[v] ?? v.toString(),
                value: value,
                onChanged: (v) => setState(() => onChanged(v)),
                isExpanded: true,
                dropdownColor: Themes.thirdLayerColor(context),
              ),
            ),
            if (bottom != null)
              Padding(
                padding: EdgeInsetsDirectional.only(start: iconSize + 16),
                child: bottom,
              ),
          ],
        ),
      ),
    );
  }
}
