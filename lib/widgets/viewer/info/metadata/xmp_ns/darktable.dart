import 'package:aves/utils/xmp_utils.dart';
import 'package:aves/widgets/viewer/info/metadata/xmp_namespaces.dart';
import 'package:aves/widgets/viewer/info/metadata/xmp_structs.dart';
import 'package:flutter/material.dart';

class XmpDarktableNamespace extends XmpNamespace {
  late final historyPattern = RegExp(nsPrefix + r'history\[(\d+)\]/(.*)');

  final history = <int, Map<String, String>>{};

  XmpDarktableNamespace(String nsPrefix, Map<String, String> rawProps) : super(Namespaces.darktable, nsPrefix, rawProps);

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
