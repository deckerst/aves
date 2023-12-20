import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/multipage.dart';
import 'package:aves/theme/text.dart';
import 'package:aves/widgets/viewer/multipage/controller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class OverlayPositionTitleRow extends StatelessWidget {
  final AvesEntry entry;
  final String? collectionPosition;
  final MultiPageController? multiPageController;

  const OverlayPositionTitleRow({
    super.key,
    required this.entry,
    required this.collectionPosition,
    required this.multiPageController,
  });

  String? get title => entry.bestTitle;

  bool get isNotEmpty => collectionPosition != null || multiPageController != null || title != null;

  @override
  Widget build(BuildContext context) {
    Text toText({String? pagePosition}) => Text(
          [
            if (collectionPosition != null) collectionPosition,
            if (pagePosition != null) pagePosition,
            if (title != null) '${Unicode.FSI}$title${Unicode.PDI}',
          ].join(AText.separator),
        );

    if (multiPageController == null) return toText();

    return StreamBuilder<MultiPageInfo?>(
      stream: multiPageController!.infoStream,
      builder: (context, snapshot) {
        final multiPageInfo = multiPageController!.info;
        String? pagePosition;
        if (multiPageInfo != null) {
          // page count may be 0 when we know an entry to have multiple pages
          // but fail to get information about these pages
          final pageCount = multiPageInfo.pageCount;
          if (pageCount > 0) {
            final page = multiPageInfo.getById(entry.pageId ?? entry.id) ?? multiPageInfo.defaultPage;
            pagePosition = '${(page?.index ?? 0) + 1}/$pageCount';
          }
        }
        return toText(pagePosition: pagePosition);
      },
    );
  }
}
