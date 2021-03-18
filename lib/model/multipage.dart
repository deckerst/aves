import 'package:flutter/foundation.dart';

class MultiPageInfo {
  final String uri;
  final List<SinglePageInfo> pages;

  int get pageCount => pages.length;

  MultiPageInfo({
    @required this.uri,
    this.pages,
  }) {
    if (pages.isNotEmpty) {
      pages.sort();
      // make sure there is a page marked as default
      if (defaultPage == null) {
        final firstPage = pages.removeAt(0);
        pages.insert(0, firstPage.copyWith(isDefault: true));
      }
    }
  }

  factory MultiPageInfo.fromPageMaps(String uri, List<Map> pageMaps) {
    return MultiPageInfo(
      uri: uri,
      pages: pageMaps.map((page) => SinglePageInfo.fromMap(page)).toList(),
    );
  }

  SinglePageInfo get defaultPage => pages.firstWhere((page) => page.isDefault, orElse: () => null);

  SinglePageInfo getByIndex(int index) => pages.firstWhere((page) => page.index == index, orElse: () => null);

  SinglePageInfo getById(int pageId) => pages.firstWhere((page) => page.pageId == pageId, orElse: () => null);

  @override
  String toString() => '$runtimeType#${shortHash(this)}{uri=$uri, pages=$pages}';
}

class SinglePageInfo implements Comparable<SinglePageInfo> {
  final int index, pageId;
  final String mimeType;
  final bool isDefault;
  final int width, height, durationMillis;

  const SinglePageInfo({
    this.index,
    this.pageId,
    this.mimeType,
    this.isDefault,
    this.width,
    this.height,
    this.durationMillis,
  });

  SinglePageInfo copyWith({
    bool isDefault,
  }) {
    return SinglePageInfo(
      index: index,
      pageId: pageId,
      mimeType: mimeType,
      isDefault: isDefault ?? this.isDefault,
      width: width,
      height: height,
      durationMillis: durationMillis,
    );
  }

  factory SinglePageInfo.fromMap(Map map) {
    final index = map['page'] as int;
    return SinglePageInfo(
      index: index,
      pageId: index,
      mimeType: map['mimeType'] as String,
      isDefault: map['isDefault'] as bool ?? false,
      width: map['width'] as int ?? 0,
      height: map['height'] as int ?? 0,
      durationMillis: map['durationMillis'] as int,
    );
  }

  @override
  String toString() => '$runtimeType#${shortHash(this)}{index=$index, pageId=$pageId, mimeType=$mimeType, isDefault=$isDefault, width=$width, height=$height, durationMillis=$durationMillis}';

  @override
  int compareTo(SinglePageInfo other) => index.compareTo(other.index);
}
