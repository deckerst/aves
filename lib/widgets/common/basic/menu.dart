import 'package:aves/theme/durations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MenuRow extends StatelessWidget {
  final String text;
  final Widget? icon;

  const MenuRow({
    super.key,
    required this.text,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null)
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 12),
            child: IconTheme.merge(
              data: IconThemeData(
                color: ListTileTheme.of(context).iconColor,
              ),
              child: icon!,
            ),
          ),
        Flexible(
          child: Text(text),
        ),
      ],
    );
  }
}

// scale icons according to text scale
class MenuIconTheme extends StatelessWidget {
  final Widget child;

  const MenuIconTheme({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final iconTheme = IconTheme.of(context);
    return IconTheme(
      data: iconTheme.copyWith(
        size: iconTheme.size! * MediaQuery.textScaleFactorOf(context),
      ),
      child: child,
    );
  }
}

class PopupMenuItemExpansionPanel<T> extends StatefulWidget {
  final bool enabled;
  final String value;
  final ValueNotifier<String?> expandedNotifier;
  final IconData icon;
  final String title;
  final List<PopupMenuEntry<T>> items;

  PopupMenuItemExpansionPanel({
    super.key,
    this.enabled = true,
    required this.value,
    ValueNotifier<String?>? expandedNotifier,
    required this.icon,
    required this.title,
    required this.items,
  }) : expandedNotifier = expandedNotifier ?? ValueNotifier(null);

  @override
  State<PopupMenuItemExpansionPanel<T>> createState() => _PopupMenuItemExpansionPanelState<T>();
}

class _PopupMenuItemExpansionPanelState<T> extends State<PopupMenuItemExpansionPanel<T>> {
  // ref `_kMenuHorizontalPadding` used in `PopupMenuItem`
  static const double _horizontalPadding = 16;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    var style = PopupMenuTheme.of(context).textStyle ?? theme.textTheme.titleMedium!;
    if (!widget.enabled) {
      style = style.copyWith(color: theme.disabledColor);
    }
    final animationDuration = context.select<DurationsData, Duration>((v) => v.expansionTileAnimation);

    Widget child = ValueListenableBuilder<String?>(
      valueListenable: widget.expandedNotifier,
      builder: (context, expandedValue, child) {
        return ExpansionPanelList(
          expansionCallback: (index, isExpanded) {
            widget.expandedNotifier.value = isExpanded ? null : widget.value;
          },
          animationDuration: animationDuration,
          expandedHeaderPadding: EdgeInsets.zero,
          elevation: 0,
          children: [
            ExpansionPanel(
              headerBuilder: (context, isExpanded) => DefaultTextStyle(
                style: style,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: _horizontalPadding),
                  child: MenuRow(
                    text: widget.title,
                    icon: Icon(widget.icon),
                  ),
                ),
              ),
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
