import 'package:aves/model/settings/settings.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/extensions/media_query.dart';
import 'package:aves/widgets/settings/navigation/drawer_editor_banner.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

typedef ItemWidgetBuilder<T> = Widget Function(T item);

class DrawerFixedListTab<T> extends StatefulWidget {
  final List<T> items;
  final Set<T> visibleItems;
  final ItemWidgetBuilder<T> leading;
  final ItemWidgetBuilder<T> title;

  const DrawerFixedListTab({
    super.key,
    required this.items,
    required this.visibleItems,
    required this.leading,
    required this.title,
  });

  @override
  State<DrawerFixedListTab<T>> createState() => _DrawerFixedListTabState<T>();
}

class _DrawerFixedListTabState<T> extends State<DrawerFixedListTab<T>> {
  Set<T> get visibleItems => widget.visibleItems;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (!settings.useTvLayout) ...[
          const DrawerEditorBanner(),
          const Divider(height: 0),
        ],
        Flexible(
          child: Selector<MediaQueryData, double>(
            selector: (context, mq) => mq.effectiveBottomPadding,
            builder: (context, mqPaddingBottom, child) {
              // `ReorderableListView` does not automatically pad
              // for `MediaQuery` insets, like regular `ListView`
              return ReorderableListView.builder(
                padding: EdgeInsets.only(bottom: mqPaddingBottom),
                itemBuilder: (context, index) {
                  final filter = widget.items[index];
                  final visible = visibleItems.contains(filter);
                  void onPressed() {
                    setState(() {
                      if (visible) {
                        visibleItems.remove(filter);
                      } else {
                        visibleItems.add(filter);
                      }
                    });
                  }

                  return Opacity(
                    key: ValueKey(filter),
                    opacity: visible ? 1 : .4,
                    child: ListTile(
                      leading: widget.leading(filter),
                      title: widget.title(filter),
                      trailing: IconButton(
                        icon: Icon(visible ? AIcons.hide : AIcons.show),
                        onPressed: onPressed,
                        tooltip: visible ? context.l10n.hideTooltip : context.l10n.showTooltip,
                      ),
                      onTap: settings.useTvLayout ? onPressed : null,
                    ),
                  );
                },
                itemCount: widget.items.length,
                onReorder: (oldIndex, newIndex) {
                  setState(() {
                    if (oldIndex < newIndex) newIndex -= 1;
                    widget.items.insert(newIndex, widget.items.removeAt(oldIndex));
                  });
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
