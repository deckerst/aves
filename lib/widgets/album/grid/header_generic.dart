import 'dart:math';

import 'package:aves/model/collection_lens.dart';
import 'package:aves/model/collection_source.dart';
import 'package:aves/model/image_entry.dart';
import 'package:aves/utils/android_file_utils.dart';
import 'package:aves/utils/constants.dart';
import 'package:aves/widgets/album/grid/header_album.dart';
import 'package:aves/widgets/album/grid/header_date.dart';
import 'package:aves/widgets/common/fx/outlined_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class SectionHeader extends StatelessWidget {
  final CollectionLens collection;
  final Map<dynamic, List<ImageEntry>> sections;
  final dynamic sectionKey;

  const SectionHeader({
    Key key,
    @required this.collection,
    @required this.sections,
    @required this.sectionKey,
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
        ? IgnorePointer(
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
      final hasTrailing = androidFileUtils.isOnSD(sectionKey);
      final text = source.getUniqueAlbumName(sectionKey);
      final maxWidth = scrollableWidth - TitleSectionHeader.padding.horizontal;
      final para = RenderParagraph(
        TextSpan(
          children: [
            if (hasLeading)
              // `RenderParagraph` fails to lay out `WidgetSpan` offscreen as of Flutter v1.17.0
              // so we use a hair space times a magic number to match leading width
              TextSpan(text: '\u200A' * 23), // 23 hair spaces match a width of 40.0
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
  final Widget leading, trailing;
  final String title;

  const TitleSectionHeader({
    Key key,
    this.leading,
    this.title,
    this.trailing,
  }) : super(key: key);

  static const leadingDimension = 32.0;
  static const leadingPadding = EdgeInsets.only(right: 8, bottom: 4);
  static const trailingPadding = EdgeInsets.only(left: 8, bottom: 4);
  static const padding = EdgeInsets.all(16);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: AlignmentDirectional.centerStart,
      padding: padding,
      constraints: const BoxConstraints(minHeight: leadingDimension),
      child: OutlinedText(
        leadingBuilder: leading != null
            ? (context, isShadow) => Container(
                  padding: leadingPadding,
                  width: leadingDimension,
                  height: leadingDimension,
                  child: isShadow ? null : leading,
                )
            : null,
        text: title,
        trailingBuilder: trailing != null
            ? (context, isShadow) => Container(
                  padding: trailingPadding,
                  child: isShadow ? null : trailing,
                )
            : null,
        style: Constants.titleTextStyle,
        outlineWidth: 2,
      ),
    );
  }
}
