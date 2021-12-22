import 'dart:async';

import 'package:aves/model/entry.dart';
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
    entry.getMultiPageInfo().then((value) {
      if (value == null || _disposed) return;
      pageNotifier.value = value.defaultPage?.index ?? 0;
      _info = value;
      _infoStreamController.add(_info);
    });
  }

  void dispose() {
    _disposed = true;
    pageNotifier.dispose();
  }

  @override
  String toString() => '$runtimeType#${shortHash(this)}{entry=$entry, page=$page, info=$info}';
}
