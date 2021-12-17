import 'dart:math';

import 'package:aves/model/source/enums.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:tuple/tuple.dart';

import 'aves_dialog.dart';

class TileViewDialog<S, G, L> extends StatefulWidget {
  final Tuple3<S?, G?, L?> initialValue;
  final Map<S, String> sortOptions;
  final Map<G, String> groupOptions;
  final Map<L, String> layoutOptions;

  const TileViewDialog({
    Key? key,
    required this.initialValue,
    this.sortOptions = const {},
    this.groupOptions = const {},
    this.layoutOptions = const {},
  }) : super(key: key);

  @override
  _TileViewDialogState createState() => _TileViewDialogState<S, G, L>();
}

class _TileViewDialogState<S, G, L> extends State<TileViewDialog<S, G, L>> with SingleTickerProviderStateMixin {
  late S? _selectedSort;
  late G? _selectedGroup;
  late L? _selectedLayout;
  late final TabController _tabController;
  late final String _optionLines;

  Map<S, String> get sortOptions => widget.sortOptions;

  Map<G, String> get groupOptions => widget.groupOptions;

  Map<L, String> get layoutOptions => widget.layoutOptions;

  double tabBarHeight(BuildContext context) => 64 * max(1, MediaQuery.textScaleFactorOf(context));

  static const double tabIndicatorWeight = 2;

  @override
  void initState() {
    super.initState();
    final initialValue = widget.initialValue;
    _selectedSort = initialValue.item1;
    _selectedGroup = initialValue.item2;
    _selectedLayout = initialValue.item3;

    final allOptions = [
      sortOptions,
      groupOptions,
      layoutOptions,
    ];

    final tabCount = allOptions.where((options) => options.isNotEmpty).length;
    _tabController = TabController(length: tabCount, vsync: this);
    _tabController.addListener(_onTabChange);

    _optionLines = allOptions.expand((v) => v.values).fold('', (previousValue, element) => '$previousValue\n$element');
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChange);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tabs = <Tuple2<Tab, Widget>>[
      if (sortOptions.isNotEmpty)
        Tuple2(
          _buildTab(context, AIcons.sort, l10n.viewDialogTabSort),
          Column(
            children: sortOptions.entries
                .map((kv) => _buildRadioListTile<S>(
                      kv.key,
                      kv.value,
                      () => _selectedSort,
                      (v) => _selectedSort = v,
                    ))
                .toList(),
          ),
        ),
      if (groupOptions.isNotEmpty)
        Tuple2(
          _buildTab(context, AIcons.group, l10n.viewDialogTabGroup, color: canGroup ? null : Theme.of(context).disabledColor),
          Column(
            children: groupOptions.entries
                .map((kv) => _buildRadioListTile<G>(
                      kv.key,
                      kv.value,
                      () => _selectedGroup,
                      (v) => _selectedGroup = v,
                    ))
                .toList(),
          ),
        ),
      if (layoutOptions.isNotEmpty)
        Tuple2(
          _buildTab(context, AIcons.layout, l10n.viewDialogTabLayout),
          Column(
            children: layoutOptions.entries
                .map((kv) => _buildRadioListTile<L>(
                      kv.key,
                      kv.value,
                      () => _selectedLayout,
                      (v) => _selectedLayout = v,
                    ))
                .toList(),
          ),
        ),
    ];

    final contentWidget = DecoratedBox(
      decoration: AvesDialog.contentDecoration(context),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final availableBodyHeight = constraints.maxHeight - tabBarHeight(context) - tabIndicatorWeight;
          final maxHeight = min(availableBodyHeight, tabBodyMaxHeight(context));
          return Column(
            mainAxisSize: MainAxisSize.min,
            // crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Material(
                borderRadius: const BorderRadius.only(
                  topLeft: AvesDialog.cornerRadius,
                  topRight: AvesDialog.cornerRadius,
                ),
                clipBehavior: Clip.antiAlias,
                child: TabBar(
                  indicatorWeight: tabIndicatorWeight,
                  tabs: tabs.map((t) => t.item1).toList(),
                  controller: _tabController,
                ),
              ),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: maxHeight,
                ),
                child: TabBarView(
                  controller: _tabController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: tabs
                      .map((t) => SingleChildScrollView(
                            child: t.item2,
                          ))
                      .toList(),
                ),
              ),
            ],
          );
        },
      ),
    );

    const actionsPadding = EdgeInsets.symmetric(horizontal: 8);
    const double actionsSpacing = 8.0;
    final actionsWidget = Padding(
      padding: actionsPadding.add(const EdgeInsets.all(actionsSpacing)),
      child: OverflowBar(
        alignment: MainAxisAlignment.end,
        spacing: actionsSpacing,
        overflowAlignment: OverflowBarAlignment.end,
        children: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, Tuple3(_selectedSort, _selectedGroup, _selectedLayout)),
            child: Text(l10n.applyButtonLabel),
          )
        ],
      ),
    );

    Widget dialogChild = LayoutBuilder(
      builder: (context, constraints) {
        final availableBodyWidth = constraints.maxWidth;
        final maxWidth = min(availableBodyWidth, tabBodyMaxWidth(context));
        return ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: maxWidth,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Flexible(child: contentWidget),
              actionsWidget,
            ],
          ),
        );
      },
    );

    return Dialog(
      shape: AvesDialog.shape(context),
      child: dialogChild,
    );
  }

  Tab _buildTab(BuildContext context, IconData icon, String text, {Color? color}) {
    // cannot use `IconTheme` over `TabBar` to change size,
    // because `TabBar` does so internally
    final textScaleFactor = MediaQuery.textScaleFactorOf(context);
    final iconSize = IconTheme.of(context).size! * textScaleFactor;
    return Tab(
      height: tabBarHeight(context),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: iconSize,
            color: color,
          ),
          const SizedBox(height: 4),
          Text(
            text,
            style: TextStyle(color: color),
            softWrap: false,
            overflow: TextOverflow.fade,
          ),
        ],
      ),
    );
  }

  bool get canGroup => _selectedSort == EntrySortFactor.date || _selectedSort is ChipSortFactor;

  void _onTabChange() {
    if (!canGroup && _tabController.index == 1) {
      _tabController.index = _tabController.previousIndex;
    }
  }

  // based on `ListTile` height computation (one line, no subtitle, not dense)
  double singleOptionTileHeight(BuildContext context) => 56.0 + Theme.of(context).visualDensity.baseSizeAdjustment.dy;

  double tabBodyMaxWidth(BuildContext context) {
    final para = RenderParagraph(
      TextSpan(text: _optionLines, style: Theme.of(context).textTheme.subtitle1!),
      textDirection: TextDirection.ltr,
      textScaleFactor: MediaQuery.textScaleFactorOf(context),
    )..layout(const BoxConstraints(), parentUsesSize: true);
    final textWidth = para.getMaxIntrinsicWidth(double.infinity);

    // from `RadioListTile` layout
    const contentPadding = 32;
    const leadingWidth = kMinInteractiveDimension + 8;
    return contentPadding + leadingWidth + textWidth;
  }

  double tabBodyMaxHeight(BuildContext context) =>
      [
        sortOptions,
        groupOptions,
        layoutOptions,
      ].map((v) => v.length).fold(0, max) *
      singleOptionTileHeight(context);

  Widget _buildRadioListTile<T>(T value, String title, T? Function() get, void Function(T value) set) {
    return RadioListTile<T>(
      // key is expected by test driver
      key: Key(value.toString()),
      value: value,
      groupValue: get(),
      onChanged: (v) => setState(() => set(v!)),
      title: Text(
        title,
        softWrap: false,
        overflow: TextOverflow.fade,
        maxLines: 1,
      ),
    );
  }
}
