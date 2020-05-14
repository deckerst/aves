import 'dart:math';

import 'package:aves/model/collection_lens.dart';
import 'package:aves/model/collection_source.dart';
import 'package:aves/utils/android_file_utils.dart';
import 'package:aves/utils/constants.dart';
import 'package:aves/widgets/album/grid/header_album.dart';
import 'package:aves/widgets/album/grid/header_date.dart';
import 'package:aves/widgets/common/icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';

class SectionHeader extends StatelessWidget {
  final CollectionLens collection;
  final dynamic sectionKey;
  final double height;

  const SectionHeader({
    Key key,
    @required this.collection,
    @required this.sectionKey,
    @required this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget header;
    switch (collection.sortFactor) {
      case SortFactor.date:
        if (collection.sortFactor == SortFactor.date) {
          switch (collection.groupFactor) {
            case GroupFactor.album:
              header = _buildAlbumSectionHeader();
              break;
            case GroupFactor.month:
              header = MonthSectionHeader(key: ValueKey(sectionKey), date: sectionKey as DateTime);
              break;
            case GroupFactor.day:
              header = DaySectionHeader(key: ValueKey(sectionKey), date: sectionKey as DateTime);
              break;
          }
        }
        break;
      case SortFactor.size:
        break;
      case SortFactor.name:
        header = _buildAlbumSectionHeader();
        break;
    }
    return header != null
        ? SizedBox(
            height: height,
            child: header,
          )
        : const SizedBox.shrink();
  }

  Widget _buildAlbumSectionHeader() {
    final folderPath = sectionKey as String;
    return AlbumSectionHeader(
      key: ValueKey(folderPath),
      folderPath: folderPath,
      albumName: collection.source.getUniqueAlbumName(folderPath),
    );
  }

  // TODO TLAD cache header extent computation?
  static double computeHeaderHeight(CollectionSource source, dynamic sectionKey, double scrollableWidth) {
    var headerExtent = 0.0;
    if (sectionKey is String) {
      // only compute height for album headers, as they're the only likely ones to split on multiple lines
      final hasLeading = androidFileUtils.getAlbumType(sectionKey) != AlbumType.Default;
      final hasTrailing = androidFileUtils.isOnRemovableStorage(sectionKey);
      final text = source.getUniqueAlbumName(sectionKey);
      final maxWidth = scrollableWidth - TitleSectionHeader.padding.horizontal;
      final para = RenderParagraph(
        TextSpan(
          children: [
            // `RenderParagraph` fails to lay out `WidgetSpan` offscreen as of Flutter v1.17.0
            // so we use a hair space times a magic number to match width
            TextSpan(
              text: '\u200A' * (hasLeading ? 23 : 1),
              // force a higher first line to match leading icon/selector dimension
              style: const TextStyle(height: 2.3),
            ), // 23 hair spaces match a width of 40.0
            if (hasTrailing)
              TextSpan(text: '\u200A' * 17),
            TextSpan(
              text: text,
              style: Constants.titleTextStyle,
            ),
          ],
        ),
        textDirection: TextDirection.ltr,
      )..layout(BoxConstraints(maxWidth: maxWidth), parentUsesSize: true);
      headerExtent = para.getMaxIntrinsicHeight(maxWidth);
    }
    headerExtent = max(headerExtent, TitleSectionHeader.leadingDimension) + TitleSectionHeader.padding.vertical;
    return headerExtent;
  }
}

class TitleSectionHeader extends StatelessWidget {
  final dynamic sectionKey;
  final Widget leading, trailing;
  final String title;

  const TitleSectionHeader({
    Key key,
    @required this.sectionKey,
    this.leading,
    @required this.title,
    this.trailing,
  }) : super(key: key);

  static const leadingDimension = 32.0;
  static const leadingPadding = EdgeInsets.only(right: 8, bottom: 4);
  static const trailingPadding = EdgeInsets.only(left: 8, bottom: 4);
  static const padding = EdgeInsets.all(16);
  static const widgetSpanAlignment = PlaceholderAlignment.middle;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: AlignmentDirectional.centerStart,
      padding: padding,
      constraints: const BoxConstraints(minHeight: leadingDimension),
      child: RichText(
        text: TextSpan(
          children: [
            WidgetSpan(
              alignment: widgetSpanAlignment,
              child: SectionSelectableLeading(
                sectionKey: sectionKey,
                browsingBuilder: leading != null
                    ? (context) => Container(
                          padding: leadingPadding,
                          width: leadingDimension,
                          height: leadingDimension,
                          child: leading,
                        )
                    : null,
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
    );
  }
}

class SectionSelectableLeading extends StatelessWidget {
  final dynamic sectionKey;
  final WidgetBuilder browsingBuilder;

  const SectionSelectableLeading({
    Key key,
    @required this.sectionKey,
    @required this.browsingBuilder,
  }) : super(key: key);

  static const leadingDimension = TitleSectionHeader.leadingDimension;

  @override
  Widget build(BuildContext context) {
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
                  final child = IconButton(
                    key: ValueKey(selected),
                    iconSize: 26,
                    padding: const EdgeInsets.only(top: 1),
                    alignment: Alignment.topLeft,
                    icon: Icon(selected ? AIcons.selected : AIcons.unselected),
                    onPressed: () {
                      if (selected) {
                        collection.removeFromSelection(sectionEntries);
                      } else {
                        collection.addToSelection(sectionEntries);
                      }
                    },
                    tooltip: selected ? 'Deselect section' : 'Select section',
                    constraints: const BoxConstraints(
                      minHeight: leadingDimension,
                      minWidth: leadingDimension,
                    ),
                  );
                  return AnimatedSwitcher(
                    duration: Duration(milliseconds: (200 * timeDilation).toInt()),
                    switchInCurve: Curves.easeOutBack,
                    switchOutCurve: Curves.easeOutBack,
                    transitionBuilder: (child, animation) => ScaleTransition(
                      child: child,
                      scale: animation,
                    ),
                    child: child,
                  );
                },
              )
            : browsingBuilder?.call(context) ?? const SizedBox(height: leadingDimension);
        return AnimatedSwitcher(
          duration: Duration(milliseconds: (200 * timeDilation).toInt()),
          switchInCurve: Curves.easeInOut,
          switchOutCurve: Curves.easeInOut,
          transitionBuilder: (child, animation) {
            Widget transition = ScaleTransition(
              child: child,
              scale: animation,
            );
            if (browsingBuilder == null) {
              // when switching with a header that has no icon,
              // we also transition the size for a smooth push to the text
              transition = SizeTransition(
                axis: Axis.horizontal,
                child: transition,
                sizeFactor: animation,
              );
            }
            return transition;
          },
          child: child,
        );
      },
    );
  }
}
