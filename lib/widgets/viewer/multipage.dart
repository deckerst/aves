import 'dart:async';

import 'package:aves/model/entry.dart';
import 'package:aves/model/multipage.dart';
import 'package:aves/services/metadata_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class MultiPageController extends ChangeNotifier {
  Future<MultiPageInfo> info;
  final ValueNotifier<int> pageNotifier = ValueNotifier(null);

  MultiPageController(AvesEntry entry) {
    info = MetadataService.getMultiPageInfo(entry).then((value) {
      final defaultPage = value.pages.firstWhere((page) => page.isDefault, orElse: () => null);
        pageNotifier.value = defaultPage?.index ?? 0;
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
