import 'dart:async';

import 'package:aves/model/entry.dart';
import 'package:aves/model/multipage.dart';
import 'package:aves/services/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class MultiPageController {
  final AvesEntry entry;
  final ValueNotifier<int> pageNotifier = ValueNotifier(null);

  MultiPageInfo _info;

  final StreamController<MultiPageInfo> _infoStreamController = StreamController.broadcast();

  Stream<MultiPageInfo> get infoStream => _infoStreamController.stream;

  MultiPageInfo get info => _info;

  int get page => pageNotifier.value;

  set page(int page) => pageNotifier.value = page;

  MultiPageController(this.entry) {
    metadataService.getMultiPageInfo(entry).then((value) {
      pageNotifier.value = value.defaultPage.index;
      _info = value;
      _infoStreamController.add(_info);
    });
  }

  void dispose() {
    pageNotifier.dispose();
  }

  @override
  String toString() => '$runtimeType#${shortHash(this)}{entry=$entry, page=$page, info=$info}';
}
