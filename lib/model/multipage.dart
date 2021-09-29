import 'package:aves/model/entry.dart';
import 'package:aves/ref/mime_types.dart';
import 'package:aves/services/common/services.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';

class MultiPageInfo {
  final AvesEntry mainEntry;
  final List<SinglePageInfo> _pages;
  final Map<SinglePageInfo, AvesEntry> _pageEntries = {};

  int get pageCount => _pages.length;

  MultiPageInfo({
    required this.mainEntry,
    required List<SinglePageInfo> pages,
  }) : _pages = pages {
    if (_pages.isNotEmpty) {
      _pages.sort();
      // make sure there is a page marked as default
      if (defaultPage == null) {
        final firstPage = _pages.removeAt(0);
        _pages.insert(0, firstPage.copyWith(isDefault: true));
      }

      final burstEntries = mainEntry.burstEntries;
      if (burstEntries != null) {
        _pageEntries.addEntries(pages.map((pageInfo) {
          final pageEntry = burstEntries.firstWhere((entry) => entry.uri == pageInfo.uri);
          return MapEntry(pageInfo, pageEntry);
        }));
      }
    }
  }

  factory MultiPageInfo.fromPageMaps(AvesEntry mainEntry, List<Map> pageMaps) {
    return MultiPageInfo(
      mainEntry: mainEntry,
      pages: pageMaps.map((page) => SinglePageInfo.fromMap(page)).toList(),
    );
  }

  SinglePageInfo? get defaultPage => _pages.firstWhereOrNull((page) => page.isDefault);

  SinglePageInfo? getById(int? pageId) => _pages.firstWhereOrNull((page) => page.pageId == pageId);

  SinglePageInfo? getByIndex(int? pageIndex) => _pages.firstWhereOrNull((page) => page.index == pageIndex);

  AvesEntry getPageEntryByIndex(int? pageIndex) => _getPageEntry(getByIndex(pageIndex));

  AvesEntry _getPageEntry(SinglePageInfo? pageInfo) {
    if (pageInfo != null) {
      return _pageEntries.putIfAbsent(pageInfo, () => _createPageEntry(pageInfo));
    } else {
      return mainEntry;
    }
  }

  Set<AvesEntry> get videoPageEntries => _pages.where((page) => page.isVideo).map(_getPageEntry).toSet();

  List<AvesEntry> get exportEntries => _pages.map((pageInfo) => _createPageEntry(pageInfo, eraseDefaultPageId: false)).toList();

  Future<void> extractMotionPhotoVideo() async {
    final videoPage = _pages.firstWhereOrNull((page) => page.isVideo);
    if (videoPage != null && videoPage.uri == null) {
      final fields = await embeddedDataService.extractMotionPhotoVideo(mainEntry);
      if (fields.containsKey('uri')) {
        final pageIndex = _pages.indexOf(videoPage);
        _pages.removeAt(pageIndex);
        _pages.insert(
            pageIndex,
            videoPage.copyWith(
              uri: fields['uri'] as String?,
              // the initial fake page may contain inaccurate values for the following fields
              // so we override them with values from the extracted standalone video
              rotationDegrees: fields['sourceRotationDegrees'] as int?,
              durationMillis: fields['durationMillis'] as int?,
            ));
        _pageEntries.remove(videoPage);
      }
    }
  }

  AvesEntry _createPageEntry(SinglePageInfo pageInfo, {bool eraseDefaultPageId = true}) {
    // do not provide the page ID for the default page,
    // so that we can treat this page like the main entry
    // and retrieve cached images for it
    final pageId = eraseDefaultPageId && pageInfo.isDefault ? null : pageInfo.pageId;

    return AvesEntry(
      uri: pageInfo.uri ?? mainEntry.uri,
      path: mainEntry.path,
      contentId: mainEntry.contentId,
      pageId: pageId,
      sourceMimeType: pageInfo.mimeType,
      width: pageInfo.width,
      height: pageInfo.height,
      sourceRotationDegrees: pageInfo.rotationDegrees ?? mainEntry.sourceRotationDegrees,
      sizeBytes: mainEntry.sizeBytes,
      sourceTitle: mainEntry.sourceTitle,
      dateModifiedSecs: mainEntry.dateModifiedSecs,
      sourceDateTakenMillis: mainEntry.sourceDateTakenMillis,
      durationMillis: pageInfo.durationMillis ?? mainEntry.durationMillis,
    )
      ..catalogMetadata = mainEntry.catalogMetadata?.copyWith(
        mimeType: pageInfo.mimeType,
        isMultiPage: false,
        rotationDegrees: pageInfo.rotationDegrees,
      )
      ..addressDetails = mainEntry.addressDetails?.copyWith();
  }

  @override
  String toString() => '$runtimeType#${shortHash(this)}{mainEntry=$mainEntry, pages=$_pages}';
}

class SinglePageInfo implements Comparable<SinglePageInfo> {
  final int index, pageId;
  final bool isDefault;
  final String? uri;
  final String mimeType;
  final int width, height;
  final int? rotationDegrees, durationMillis;

  const SinglePageInfo({
    required this.index,
    required this.pageId,
    required this.isDefault,
    this.uri,
    required this.mimeType,
    required this.width,
    required this.height,
    this.rotationDegrees,
    this.durationMillis,
  });

  SinglePageInfo copyWith({
    bool? isDefault,
    String? uri,
    int? rotationDegrees,
    int? durationMillis,
  }) {
    return SinglePageInfo(
      index: index,
      pageId: pageId,
      isDefault: isDefault ?? this.isDefault,
      uri: uri ?? this.uri,
      mimeType: mimeType,
      width: width,
      height: height,
      rotationDegrees: rotationDegrees ?? this.rotationDegrees,
      durationMillis: durationMillis ?? this.durationMillis,
    );
  }

  factory SinglePageInfo.fromMap(Map map) {
    final index = map['page'] as int;
    return SinglePageInfo(
      index: index,
      pageId: index,
      isDefault: map['isDefault'] as bool? ?? false,
      mimeType: map['mimeType'] as String,
      width: map['width'] as int? ?? 0,
      height: map['height'] as int? ?? 0,
      rotationDegrees: map['rotationDegrees'] as int?,
      durationMillis: map['durationMillis'] as int?,
    );
  }

  bool get isVideo => MimeTypes.isVideo(mimeType);

  @override
  String toString() => '$runtimeType#${shortHash(this)}{index=$index, pageId=$pageId, isDefault=$isDefault, uri=$uri, mimeType=$mimeType, width=$width, height=$height, rotationDegrees=$rotationDegrees, durationMillis=$durationMillis}';

  @override
  int compareTo(SinglePageInfo other) => index.compareTo(other.index);
}
