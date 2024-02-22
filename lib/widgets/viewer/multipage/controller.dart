import 'dart:async';
import 'dart:math';

import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/entry/extensions/multipage.dart';
import 'package:aves/model/multipage.dart';
import 'package:flutter/foundation.dart';

class MultiPageController {
  final AvesEntry entry;
  final ValueNotifier<int?> pageNotifier = ValueNotifier(null);

  bool _disposed = false;
  MultiPageInfo? _info;

  final StreamController<MultiPageInfo?> _infoStreamController = StreamController.broadcast();

  Stream<MultiPageInfo?> get infoStream => _infoStreamController.stream;

  MultiPageInfo? get info => _info;

  int? get page => pageNotifier.value;

  set page(int? page) => pageNotifier.value = page;

  MultiPageController(this.entry) {
    if (kFlutterMemoryAllocationsEnabled) {
      FlutterMemoryAllocations.instance.dispatchObjectCreated(
        library: 'aves',
        className: '$MultiPageController',
        object: this,
      );
    }
    reset();
  }

  void reset() => entry.getMultiPageInfo().then((info) {
        if (info == null || _disposed) return;
        final currentPage = pageNotifier.value;
        if (currentPage == null) {
          pageNotifier.value = info.defaultPage?.index ?? 0;
        } else {
          pageNotifier.value = min(currentPage, info.pageCount - 1);
        }
        _info = info;
        _infoStreamController.add(_info);
      });

  void dispose() {
    if (kFlutterMemoryAllocationsEnabled) {
      FlutterMemoryAllocations.instance.dispatchObjectDisposed(object: this);
    }
    _info?.dispose();
    _disposed = true;
    pageNotifier.dispose();
  }

  @override
  String toString() => '$runtimeType#${shortHash(this)}{entry=$entry, page=$page, info=$info}';
}
