import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/model/source/enums.dart';
import 'package:aves/model/source/section_keys.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

class SectionHeader extends StatelessWidget {
  final SectionKey sectionKey;
  final Widget leading, trailing;
  final String title;
  final bool selectable;

  const SectionHeader({
    Key key,
    @required this.sectionKey,
    this.leading,
    @required this.title,
    this.trailing,
    this.selectable = true,
  }) : super(key: key);

  static const leadingDimension = 32.0;
  static const leadingPadding = EdgeInsets.only(right: 8, bottom: 4);
  static const trailingPadding = EdgeInsets.only(left: 8, bottom: 2);
  static const padding = EdgeInsets.all(16);
  static const widgetSpanAlignment = PlaceholderAlignment.middle;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: AlignmentDirectional.centerStart,
      padding: padding,
      constraints: BoxConstraints(minHeight: leadingDimension),
      child: GestureDetector(
        onTap: () => _toggleSectionSelection(context),
        child: Text.rich(
          TextSpan(
            children: [
              WidgetSpan(
                alignment: widgetSpanAlignment,
                child: _SectionSelectableLeading(
                  selectable: selectable,
                  sectionKey: sectionKey,
                  browsingBuilder: leading != null
                      ? (context) => Container(
                            padding: leadingPadding,
                            width: leadingDimension,
                            height: leadingDimension,
                            child: leading,
                          )
                      : null,
                  onPressed: () => _toggleSectionSelection(context),
                ),
              ),
              TextSpan(
                text: title,
                style: Constants.titleTextStyle,
              ),
              if (trailing != null)
                WidgetSpan(
                  alignment: widgetSpanAlignment,
                  child: Container(
                    padding: trailingPadding,
                    child: trailing,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _toggleSectionSelection(BuildContext context) {
    final collection = Provider.of<CollectionLens>(context, listen: false);
    final sectionEntries = collection.sections[sectionKey];
    final selected = collection.isSelected(sectionEntries);
    if (selected) {
      collection.removeFromSelection(sectionEntries);
    } else {
      collection.addToSelection(sectionEntries);
    }
  }

  // TODO TLAD cache header extent computation?
  static double getPreferredHeight({
    @required BuildContext context,
    @required double maxWidth,
    @required String title,
    bool hasLeading = false,
    bool hasTrailing = false,
  }) {
    final textScaleFactor = MediaQuery.textScaleFactorOf(context);
    final maxContentWidth = maxWidth - SectionHeader.padding.horizontal;
    final para = RenderParagraph(
      TextSpan(
        children: [
          // as of Flutter v1.22.3, `RenderParagraph` fails to lay out `WidgetSpan` offscreen
          // so we use a hair space times a magic number to match width
          TextSpan(
            text: '\u200A' * (hasLeading ? 23 : 1),
            // force a higher first line to match leading icon/selector dimension
            style: TextStyle(height: 2.3 * textScaleFactor),
          ), // 23 hair spaces match a width of 40.0
          if (hasTrailing) TextSpan(text: '\u200A' * 17),
          TextSpan(
            text: title,
            style: Constants.titleTextStyle,
          ),
        ],
      ),
      textDirection: TextDirection.ltr,
      textScaleFactor: textScaleFactor,
    )..layout(BoxConstraints(maxWidth: maxContentWidth), parentUsesSize: true);
    return para.getMaxIntrinsicHeight(maxContentWidth);
  }
}

class _SectionSelectableLeading extends StatelessWidget {
  final bool selectable;
  final SectionKey sectionKey;
  final WidgetBuilder browsingBuilder;
  final VoidCallback onPressed;

  const _SectionSelectableLeading({
    Key key,
    this.selectable = true,
    @required this.sectionKey,
    @required this.browsingBuilder,
    @required this.onPressed,
  }) : super(key: key);

  static const leadingDimension = SectionHeader.leadingDimension;

  @override
  Widget build(BuildContext context) {
    if (!selectable) return _buildBrowsing(context);

    final collection = Provider.of<CollectionLens>(context);
    return ValueListenableBuilder<Activity>(
      valueListenable: collection.activityNotifier,
      builder: (context, activity, child) {
        final child = collection.isSelecting
            ? AnimatedBuilder(
                animation: collection.selectionChangeNotifier,
                builder: (context, child) {
                  final sectionEntries = collection.sections[sectionKey];
                  final selected = collection.isSelected(sectionEntries);
                  final child = TooltipTheme(
                    key: ValueKey(selected),
                    data: TooltipTheme.of(context).copyWith(
                      preferBelow: false,
                    ),
                    child: IconButton(
                      iconSize: 26,
                      padding: EdgeInsets.only(top: 1),
                      alignment: AlignmentDirectional.topStart,
                      icon: Icon(selected ? AIcons.selected : AIcons.unselected),
                      onPressed: onPressed,
                      tooltip: selected ? 'Deselect section' : 'Select section',
                      constraints: BoxConstraints(
                        minHeight: leadingDimension,
                        minWidth: leadingDimension,
                      ),
                    ),
                  );
                  return AnimatedSwitcher(
                    duration: Durations.sectionHeaderAnimation,
                    switchInCurve: Curves.easeOutBack,
                    switchOutCurve: Curves.easeOutBack,
                    transitionBuilder: (child, animation) => ScaleTransition(
                      scale: animation,
                      child: child,
                    ),
                    child: child,
                  );
                },
              )
            : _buildBrowsing(context);
        return AnimatedSwitcher(
          duration: Durations.sectionHeaderAnimation,
          switchInCurve: Curves.easeInOut,
          switchOutCurve: Curves.easeInOut,
          transitionBuilder: (child, animation) {
            Widget transition = ScaleTransition(
              scale: animation,
              child: child,
            );
            if (browsingBuilder == null) {
              // when switching with a header that has no icon,
              // we also transition the size for a smooth push to the text
              transition = SizeTransition(
                axis: Axis.horizontal,
                sizeFactor: animation,
                child: transition,
              );
            }
            return transition;
          },
          child: child,
        );
      },
    );
  }

  Widget _buildBrowsing(BuildContext context) => browsingBuilder?.call(context) ?? SizedBox(height: leadingDimension);
}
