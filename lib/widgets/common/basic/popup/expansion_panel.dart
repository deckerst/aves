import 'package:aves/theme/durations.dart';
import 'package:aves/widgets/common/basic/popup/menu_row.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PopupMenuExpansionPanel<T> extends PopupMenuEntry<T> {
  final bool enabled;
  final String value;
  final ValueNotifier<String?>? expandedNotifier;
  final IconData icon;
  final String title;
  final List<PopupMenuEntry<T>> items;

  const PopupMenuExpansionPanel({
    super.key,
    this.enabled = true,
    this.height = kMinInteractiveDimension,
    required this.value,
    this.expandedNotifier,
    required this.icon,
    required this.title,
    required this.items,
  });

  @override
  final double height;

  @override
  bool represents(void value) => false;

  @override
  State<PopupMenuExpansionPanel<T>> createState() => _PopupMenuExpansionPanelState<T>();
}

class _PopupMenuExpansionPanelState<T> extends State<PopupMenuExpansionPanel<T>> {
  final ValueNotifier<String?> _internalExpandedNotifier = ValueNotifier(null);

  ValueNotifier<String?> get expandedNotifier => widget.expandedNotifier ?? _internalExpandedNotifier;

  @override
  void dispose() {
    _internalExpandedNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final style = PopupMenuTheme.of(context).labelTextStyle!.resolve(
      <WidgetState>{
        if (!widget.enabled) WidgetState.disabled,
      },
    )!;
    final animationDuration = context.select<DurationsData, Duration>((v) => v.expansionTileAnimation);

    Widget child = ValueListenableBuilder<String?>(
      valueListenable: expandedNotifier,
      builder: (context, expandedValue, child) {
        return ExpansionPanelList(
          expansionCallback: (index, isExpanded) {
            expandedNotifier.value = isExpanded ? widget.value : null;
          },
          animationDuration: animationDuration,
          expandedHeaderPadding: EdgeInsets.zero,
          elevation: 0,
          children: [
            ExpansionPanel(
              headerBuilder: (context, isExpanded) {
                return DefaultTextStyle(
                  style: style,
                  child: IconTheme.merge(
                    data: IconThemeData(
                      color: widget.enabled ? null : Theme.of(context).disabledColor,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: MenuRow(
                        text: widget.title,
                        icon: Icon(widget.icon),
                      ),
                    ),
                  ),
                );
              },
              body: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const PopupMenuDivider(height: 0),
                  ...widget.items,
                  const PopupMenuDivider(height: 0),
                ],
              ),
              isExpanded: expandedValue == widget.value,
              canTapOnHeader: true,
              backgroundColor: Colors.transparent,
            ),
          ],
        );
      },
    );
    if (!widget.enabled) {
      child = IgnorePointer(child: child);
    }
    return child;
  }
}
