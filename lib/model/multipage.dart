import 'package:aves/model/entry.dart';
import 'package:aves/ref/mime_types.dart';
import 'package:aves/services/services.dart';
import 'package:flutter/foundation.dart';

class MultiPageInfo {
  final AvesEntry mainEntry;
  final List<SinglePageInfo> pages;

  int get pageCount => pages.length;

  MultiPageInfo({
    @required this.mainEntry,
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

  factory MultiPageInfo.fromPageMaps(AvesEntry mainEntry, List<Map> pageMaps) {
    return MultiPageInfo(
      mainEntry: mainEntry,
      pages: pageMaps.map((page) => SinglePageInfo.fromMap(page)).toList(),
    );
  }

  SinglePageInfo get defaultPage => pages.firstWhere((page) => page.isDefault, orElse: () => null);

  SinglePageInfo getByIndex(int index) => pages.firstWhere((page) => page.index == index, orElse: () => null);

  SinglePageInfo getById(int pageId) => pages.firstWhere((page) => page.pageId == pageId, orElse: () => null);

  Future<void> extractMotionPhotoVideo() async {
    final videoPage = pages.firstWhere((page) => page.isVideo, orElse: () => null);
    if (videoPage != null && videoPage.uri == null) {
      final fields = await embeddedDataService.extractMotionPhotoVideo(mainEntry);
      final extractedUri = fields != null ? fields['uri'] as String : null;
      if (extractedUri != null) {
        final pageIndex = pages.indexOf(videoPage);
        pages.removeAt(pageIndex);
        pages.insert(
            pageIndex,
            videoPage.copyWith(
              uri: extractedUri,
            ));
      }
    }
  }

  @override
  String toString() => '$runtimeType#${shortHash(this)}{mainEntry=$mainEntry, pages=$pages}';
}

class SinglePageInfo implements Comparable<SinglePageInfo> {
  final int index, pageId;
  final bool isDefault;
  final String uri, mimeType;
  final int width, height, rotationDegrees, durationMillis;

  const SinglePageInfo({
    this.index,
    this.pageId,
    this.isDefault,
    this.uri,
    this.mimeType,
    this.width,
    this.height,
    this.rotationDegrees,
    this.durationMillis,
  });

  SinglePageInfo copyWith({
    bool isDefault,
    String uri,
  }) {
    return SinglePageInfo(
      index: index,
      pageId: pageId,
      isDefault: isDefault ?? this.isDefault,
      uri: uri ?? this.uri,
      mimeType: mimeType,
      width: width,
      height: height,
      rotationDegrees: rotationDegrees,
      durationMillis: durationMillis,
    );
  }

  factory SinglePageInfo.fromMap(Map map) {
    final index = map['page'] as int;
    return SinglePageInfo(
      index: index,
      pageId: index,
      isDefault: map['isDefault'] as bool ?? false,
      mimeType: map['mimeType'] as String,
      width: map['width'] as int ?? 0,
      height: map['height'] as int ?? 0,
      rotationDegrees: map['rotationDegrees'] as int,
      durationMillis: map['durationMillis'] as int,
    );
  }

  bool get isVideo => MimeTypes.isVideo(mimeType);

  @override
  String toString() => '$runtimeType#${shortHash(this)}{index=$index, pageId=$pageId, isDefault=$isDefault, uri=$uri, mimeType=$mimeType, width=$width, height=$height, rotationDegrees=$rotationDegrees, durationMillis=$durationMillis}';

  @override
  int compareTo(SinglePageInfo other) => index.compareTo(other.index);
}
