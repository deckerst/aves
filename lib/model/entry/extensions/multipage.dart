import 'dart:async';

import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/multipage.dart';
import 'package:aves/ref/bursts.dart';
import 'package:aves/services/common/services.dart';
import 'package:collection/collection.dart';

extension ExtraAvesEntryMultipage on AvesEntry {
  bool get isMultiPage => isStack || ((catalogMetadata?.isMultiPage ?? false) && (isMotionPhoto || !isHdr));

  bool get isStack => stackedEntries?.isNotEmpty == true;

  bool get isMotionPhoto => catalogMetadata?.isMotionPhoto ?? false;

  String? getBurstKey(List<String> patterns) {
    final key = BurstPatterns.getKeyForName(filenameWithoutExtension, patterns);
    return key != null ? '$directory/$key' : null;
  }

  Future<MultiPageInfo?> getMultiPageInfo() async {
    if (isStack) {
      return MultiPageInfo(
        mainEntry: this,
        pages: stackedEntries!
            .mapIndexed((index, entry) => SinglePageInfo(
                  index: index,
                  pageId: entry.id,
                  isDefault: index == 0,
                  uri: entry.uri,
                  mimeType: entry.mimeType,
                  width: entry.width,
                  height: entry.height,
                  rotationDegrees: entry.rotationDegrees,
                  durationMillis: entry.durationMillis,
                ))
            .toList(),
      );
    } else {
      return await metadataFetchService.getMultiPageInfo(this);
    }
  }
}
