import 'package:aves/model/entry.dart';
import 'package:flutter/foundation.dart';

class MultiPageInfo {
  final List<SinglePageInfo> pages;

  int get pageCount => pages.length;

  MultiPageInfo({
    this.pages,
  });

  factory MultiPageInfo.fromPageMaps(List<Map> pageMaps) {
    return MultiPageInfo(pages: pageMaps.map((page) => SinglePageInfo.fromMap(page)).toList());
  }

  SinglePageInfo getByIndex(int index) => pages.firstWhere((page) => page.index == index, orElse: () => null);

  SinglePageInfo getById(int pageId) => pages.firstWhere((page) => page.pageId == pageId, orElse: () => null);

  @override
  String toString() => '$runtimeType#${shortHash(this)}{pages=$pages}';
}

class SinglePageInfo {
  final int index, pageId;
  final String mimeType;
  final bool isDefault;
  final int width, height, durationMillis;

  SinglePageInfo({
    this.index,
    this.pageId,
    this.mimeType,
    this.isDefault,
    this.width,
    this.height,
    this.durationMillis,
  });

  factory SinglePageInfo.fromMap(Map map) {
    final index = map['page'] as int;
    return SinglePageInfo(
      index: index,
      pageId: map['trackId'] as int ?? index,
      mimeType: map['mimeType'] as String,
      isDefault: map['isDefault'] as bool ?? false,
      width: map['width'] as int ?? 0,
      height: map['height'] as int ?? 0,
      durationMillis: map['durationMillis'] as int,
    );
  }

  @override
  String toString() => '$runtimeType#${shortHash(this)}{index=$index, pageId=$pageId, mimeType=$mimeType, isDefault=$isDefault, width=$width, height=$height, durationMillis=$durationMillis}';
}

class AvesPageEntry extends AvesEntry {
  final SinglePageInfo pageInfo;

  AvesPageEntry({
    @required this.pageInfo,
    String uri,
    String path,
    int contentId,
    int pageId,
    String sourceMimeType,
    int width,
    int height,
    int sourceRotationDegrees,
    int sizeBytes,
    String sourceTitle,
    int dateModifiedSecs,
    int sourceDateTakenMillis,
    int durationMillis,
  }) : super(
          uri: uri,
          path: path,
          contentId: contentId,
          pageId: pageId,
          sourceMimeType: pageInfo.mimeType ?? sourceMimeType,
          width: pageInfo.width ?? width,
          height: pageInfo.height ?? height,
          sourceRotationDegrees: sourceRotationDegrees,
          sizeBytes: sizeBytes,
          sourceTitle: sourceTitle,
          dateModifiedSecs: dateModifiedSecs,
          sourceDateTakenMillis: sourceDateTakenMillis,
          durationMillis: pageInfo.durationMillis ?? durationMillis,
        );
}
