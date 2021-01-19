import 'package:aves/model/image_entry.dart';
import 'package:flutter/foundation.dart';

class MultiPageInfo {
  final Map<int, SinglePageInfo> pages;

  int get pageCount => pages.length;

  MultiPageInfo({
    this.pages,
  });

  factory MultiPageInfo.fromMap(Map map) {
    final pages = <int, SinglePageInfo>{};
    map.keys.forEach((key) {
      final index = key as int;
      pages.putIfAbsent(index, () => SinglePageInfo.fromMap(map[key]));
    });
    return MultiPageInfo(pages: pages);
  }

  @override
  String toString() => '$runtimeType#${shortHash(this)}{pages=$pages}';
}

class SinglePageInfo {
  final String mimeType;
  final int width, height;
  final int trackId, durationMillis;

  SinglePageInfo({
    this.mimeType,
    this.width,
    this.height,
    this.trackId,
    this.durationMillis,
  });

  factory SinglePageInfo.fromMap(Map map) {
    return SinglePageInfo(
      mimeType: map['mimeType'] as String,
      width: map['width'] as int,
      height: map['height'] as int,
      trackId: map['trackId'] as int,
      durationMillis: map['durationMillis'] as int,
    );
  }

  @override
  String toString() => '$runtimeType#${shortHash(this)}{mimeType=$mimeType, width=$width, height=$height, trackId=$trackId, durationMillis=$durationMillis}';
}

class AvesPageEntry extends ImageEntry {
  final SinglePageInfo pageInfo;

  AvesPageEntry({
    @required this.pageInfo,
    String uri,
    String path,
    int contentId,
    int page,
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
          page: page,
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
