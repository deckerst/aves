import 'dart:async';

import 'package:aves/model/entry.dart';
import 'package:aves/model/multipage.dart';
import 'package:aves/services/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class MultiPageController extends ChangeNotifier {
  final AvesEntry entry;
  Future<MultiPageInfo> info;
  final ValueNotifier<int> pageNotifier = ValueNotifier(null);

  MultiPageController(this.entry) {
    info = metadataService.getMultiPageInfo(entry).then((value) {
      pageNotifier.value = value.defaultPage.index;
      return value;
    });
  }

  int get page => pageNotifier.value;

  set page(int page) => pageNotifier.value = page;

  @override
  void dispose() {
    pageNotifier.dispose();
    super.dispose();
  }
}
