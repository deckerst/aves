import 'dart:math';

import 'package:aves/theme/durations.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/utils/constants.dart';
import 'package:aves/widgets/common/basic/multi_cross_fader.dart';
import 'package:aves/widgets/common/identity/highlight_title.dart';
import 'package:aves/widgets/fullscreen/info/common.dart';
import 'package:flutter/material.dart';

class XmpStructArrayCard extends StatefulWidget {
  final String title;
  final List<Map<String, String>> structs = [];
  final Map<String, InfoLinkHandler> Function(int index) linkifier;

  XmpStructArrayCard({
    @required this.title,
    @required Map<int, Map<String, String>> structByIndex,
    this.linkifier,
  }) {
    structs.length = structByIndex.keys.fold(0, max);
    structByIndex.keys.forEach((index) => structs[index - 1] = structByIndex[index]);
  }

  @override
  _XmpStructArrayCardState createState() => _XmpStructArrayCardState();
}

class _XmpStructArrayCardState extends State<XmpStructArrayCard> {
  int _index;

  List<Map<String, String>> get structs => widget.structs;

  @override
  void initState() {
    super.initState();
    _index = structs.length - 1;
  }

  @override
  Widget build(BuildContext context) {
    void setIndex(int index) {
      index = index.clamp(0, structs.length - 1);
      if (_index != index) {
        _index = index;
        setState(() {});
      }
    }

    return Card(
      margin: XmpStructCard.cardMargin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 8, top: 8, right: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Flexible(
                  child: HighlightTitle(
                    '${widget.title} ${_index + 1}',
                    color: Colors.transparent,
                    selectable: true,
                  ),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: Icon(AIcons.previous),
                  onPressed: _index > 0 ? () => setIndex(_index - 1) : null,
                  tooltip: 'Previous',
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: Icon(AIcons.next),
                  onPressed: _index < structs.length - 1 ? () => setIndex(_index + 1) : null,
                  tooltip: 'Next',
                ),
              ],
            ),
          ),
          MultiCrossFader(
            duration: Durations.xmpStructArrayCardTransition,
            sizeCurve: Curves.easeOutBack,
            alignment: AlignmentDirectional.topStart,
            child: Padding(
              // add padding at this level (instead of the column level)
              // so that the crossfader can animate the content size
              // without clipping the text
              padding: EdgeInsets.only(left: 8, right: 8, bottom: 8),
              child: InfoRowGroup(
                structs[_index],
                maxValueLength: Constants.infoGroupMaxValueLength,
                linkHandlers: widget.linkifier?.call(_index + 1),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class XmpStructCard extends StatelessWidget {
  final String title;
  final Map<String, String> struct;
  final Map<String, InfoLinkHandler> Function() linkifier;

  static const cardMargin = EdgeInsets.symmetric(vertical: 8, horizontal: 0);

  const XmpStructCard({
    @required this.title,
    @required this.struct,
    this.linkifier,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: cardMargin,
      child: Padding(
        padding: EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HighlightTitle(
              title,
              color: Colors.transparent,
              selectable: true,
            ),
            InfoRowGroup(
              struct,
              maxValueLength: Constants.infoGroupMaxValueLength,
              linkHandlers: linkifier?.call(),
            ),
          ],
        ),
      ),
    );
  }
}
