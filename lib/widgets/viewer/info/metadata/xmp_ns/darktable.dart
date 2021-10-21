import 'package:aves/widgets/viewer/info/metadata/xmp_namespaces.dart';
import 'package:aves/widgets/viewer/info/metadata/xmp_structs.dart';
import 'package:flutter/material.dart';

class XmpDarktableNamespace extends XmpNamespace {
  static const ns = 'darktable';

  static final historyPattern = RegExp(ns + r':history\[(\d+)\]/(.*)');

  final history = <int, Map<String, String>>{};

  XmpDarktableNamespace(Map<String, String> rawProps) : super(ns, rawProps);

  @override
  bool extractData(XmpProp prop) => extractIndexedStruct(prop, historyPattern, history);

  @override
  List<Widget> buildFromExtractedData() => [
        if (history.isNotEmpty)
          XmpStructArrayCard(
            title: 'History',
            structByIndex: history,
          ),
      ];
}
