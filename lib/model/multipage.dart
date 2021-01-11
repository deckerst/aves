import 'package:flutter/foundation.dart';

class SinglePageInfo {
  final int width, height;

  SinglePageInfo({
    this.width,
    this.height,
  });

  factory SinglePageInfo.fromMap(Map map) {
    return SinglePageInfo(
      width: map['width'] as int,
      height: map['height'] as int,
    );
  }

  @override
  String toString() => '$runtimeType#${shortHash(this)}{width=$width, height=$height}';
}

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
