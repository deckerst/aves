import 'package:aves/model/selection.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/section_keys.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/theme/styles.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/grid/sections/list_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

class SectionHeader<T> extends StatelessWidget {
  final SectionKey sectionKey;
  final Widget? leading, trailing;
  final String title;
  final bool selectable;

  const SectionHeader({
    super.key,
    required this.sectionKey,
    this.leading,
    required this.title,
    this.trailing,
    this.selectable = true,
  });

  static const leadingSize = Size(48, 32);
  static const margin = EdgeInsets.symmetric(vertical: 0, horizontal: 8);
  static const padding = EdgeInsets.symmetric(vertical: 16, horizontal: 8);
  static const widgetSpanAlignment = PlaceholderAlignment.middle;

  @override
  Widget build(BuildContext context) {
    final onTap = selectable ? () => _toggleSectionSelection(context) : null;

    Widget child = Container(
      padding: padding,
      constraints: BoxConstraints(minHeight: leadingSize.height),
      child: GestureDetector(
        onTap: onTap,
        onLongPress: selectable
            ? Feedback.wrapForLongPress(() {
                final selection = context.read<Selection<T>>();
                if (selection.isSelecting) {
                  _toggleSectionSelection(context);
                } else {
                  selection.select();
                  selection.addToSelection(_getSectionEntries(context));
                }
              }, context)
            : null,
        child: Text.rich(
          TextSpan(
            children: [
              WidgetSpan(
                alignment: widgetSpanAlignment,
                child: _SectionSelectableLeading<T>(
                  selectable: selectable,
                  sectionKey: sectionKey,
                  browsingBuilder: leading != null
                      ? (context) => Container(
                            padding: const EdgeInsetsDirectional.only(end: 8, bottom: 4),
                            width: leadingSize.width,
                            height: leadingSize.height,
                            child: leading,
                          )
                      : null,
                  onPressed: onTap,
                ),
              ),
              TextSpan(
                text: title,
                style: AStyles.unknownTitleText,
              ),
              if (trailing != null)
                WidgetSpan(
                  alignment: widgetSpanAlignment,
                  child: Container(
                    padding: const EdgeInsetsDirectional.only(start: 8, bottom: 2),
                    child: trailing,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
    if (settings.useTvLayout) {
      // prevent ink response when tapping the header does nothing,
      // because otherwise Play Store reviewers think it is broken navigation
      child = context.select<Selection<T>, bool>((v) => v.isSelecting)
          ? InkWell(
              onTap: onTap,
              borderRadius: const BorderRadius.all(Radius.circular(123)),
              child: child,
            )
          : Focus(child: child);
    }
    return Container(
      alignment: AlignmentDirectional.centerStart,
      margin: margin,
      child: child,
    );
  }

  List<T> _getSectionEntries(BuildContext context) => context.read<SectionedListLayout<T>>().sections[sectionKey] ?? [];

  void _toggleSectionSelection(BuildContext context) {
    final sectionEntries = _getSectionEntries(context);
    final selection = context.read<Selection<T>>();
    final isSelected = selection.isSelected(sectionEntries);
    if (isSelected) {
      selection.removeFromSelection(sectionEntries);
    } else {
      selection.addToSelection(sectionEntries);
    }
  }

  // TODO TLAD [perf] cache header extent computation?
  static double getPreferredHeight({
    required BuildContext context,
    required double maxWidth,
    required String title,
    bool hasLeading = false,
    bool hasTrailing = false,
  }) {
    final textScaleFactor = MediaQuery.textScaleFactorOf(context);
    final maxContentWidth = maxWidth - (SectionHeader.padding.horizontal + SectionHeader.margin.horizontal);
    final paragraph = RenderParagraph(
      TextSpan(
        children: [
          // as of Flutter v3.7.7, `RenderParagraph` fails to lay out `WidgetSpan` offscreen
          // so we use a hair space times a magic number to match width
          TextSpan(
            // 23 hair spaces match a width of 40.0
            text: '\u200A' * (hasLeading ? 23 : 1),
            // force a higher first line to match leading icon/selector dimension
            style: TextStyle(height: 2.3 * textScaleFactor),
          ),
          if (hasTrailing) TextSpan(text: '\u200A' * 17),
          TextSpan(
            text: title,
            style: AStyles.unknownTitleText,
          ),
        ],
      ),
      textDirection: TextDirection.ltr,
      textScaleFactor: textScaleFactor,
    )..layout(BoxConstraints(maxWidth: maxContentWidth), parentUsesSize: true);
    final height = paragraph.getMaxIntrinsicHeight(maxContentWidth);
    paragraph.dispose();
    return height;
  }
}

class _SectionSelectableLeading<T> extends StatelessWidget {
  final bool selectable;
  final SectionKey sectionKey;
  final WidgetBuilder? browsingBuilder;
  final VoidCallback? onPressed;

  const _SectionSelectableLeading({
    super.key,
    this.selectable = true,
    required this.sectionKey,
    required this.browsingBuilder,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    if (!selectable) return _buildBrowsing(context);

    final isSelecting = context.select<Selection<T>, bool>((selection) => selection.isSelecting);
    final Widget child = isSelecting
        ? _SectionSelectingLeading<T>(
            sectionKey: sectionKey,
            onPressed: onPressed,
          )
        : _buildBrowsing(context);

    return FocusTraversalGroup(
      descendantsAreFocusable: false,
      descendantsAreTraversable: false,
      child: AnimatedSwitcher(
        duration: ADurations.sectionHeaderAnimation,
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
      ),
    );
  }

  Widget _buildBrowsing(BuildContext context) => browsingBuilder?.call(context) ?? SizedBox(height: SectionHeader.leadingSize.height);
}

class _SectionSelectingLeading<T> extends StatelessWidget {
  final SectionKey sectionKey;
  final VoidCallback? onPressed;

  const _SectionSelectingLeading({
    super.key,
    required this.sectionKey,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final sectionEntries = context.watch<SectionedListLayout<T>>().sections[sectionKey] ?? [];
    final selection = context.watch<Selection<T>>();
    final isSelected = selection.isSelected(sectionEntries);
    return AnimatedSwitcher(
      duration: ADurations.sectionHeaderAnimation,
      switchInCurve: Curves.easeOutBack,
      switchOutCurve: Curves.easeOutBack,
      transitionBuilder: (child, animation) => ScaleTransition(
        scale: animation,
        child: child,
      ),
      child: TooltipTheme(
        key: ValueKey(isSelected),
        data: TooltipTheme.of(context).copyWith(
          preferBelow: false,
        ),
        child: IconButton(
          iconSize: 26,
          padding: const EdgeInsetsDirectional.only(end: 6, bottom: 4),
          onPressed: onPressed,
          tooltip: isSelected ? context.l10n.collectionDeselectSectionTooltip : context.l10n.collectionSelectSectionTooltip,
          constraints: BoxConstraints(
            minHeight: SectionHeader.leadingSize.height,
            minWidth: SectionHeader.leadingSize.width,
          ),
          icon: Icon(isSelected ? AIcons.selected : AIcons.unselected),
        ),
      ),
    );
  }
}
