import 'package:aves/common/draggable_scrollbar.dart';
import 'package:aves/common/outlined_text.dart';
import 'package:aves/thumbnail.dart';
import "package:collection/collection.dart";
import 'package:flutter/material.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:intl/intl.dart';

class ThumbnailCollection extends StatelessWidget {
  final Map<String, List<Map>> sections;
  final ScrollController scrollController = ScrollController();

  ThumbnailCollection(List<Map> entries) : sections = groupBy(entries, getDayTaken);

  static DateTime getBestDate(Map entry) {
    var dateTakenMillis = entry['sourceDateTakenMillis'] as int;
    if (dateTakenMillis != null && dateTakenMillis > 0) return DateTime.fromMillisecondsSinceEpoch(dateTakenMillis);

    var dateModifiedSecs = entry['dateModifiedSecs'] as int;
    if (dateModifiedSecs != null && dateModifiedSecs > 0) return DateTime.fromMillisecondsSinceEpoch(dateModifiedSecs * 1000);

    return null;
  }

  static DateFormat sectionDateFormat = DateFormat('yyyy/MM/dd');

  static String getDayTaken(Map entry) {
    var date = getBestDate(entry);
    return date == null ? 'Unknown' : sectionDateFormat.format(date);
  }

  @override
  Widget build(BuildContext context) {
    var columnCount = 4;
    var extent = MediaQuery.of(context).size.width / columnCount;

    return DraggableScrollbar.arrows(
      labelTextBuilder: (double offset) => Text(
        "${offset ~/ 1}",
        style: TextStyle(color: Colors.blueGrey),
      ),
      controller: scrollController,
      child: CustomScrollView(
        controller: scrollController,
        slivers: [
          SliverAppBar(
            title: Text('Aves - All'),
            floating: true,
          ),
          ...sections.keys.map((sectionKey) => SliverStickyHeader(
                header: SectionHeader(sectionKey),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      var entries = sections[sectionKey];
                      if (index >= entries.length) return null;
                      return Thumbnail(
                        entry: entries[index],
                        extent: extent,
                      );
                    },
                    childCount: sections[sectionKey].length,
                  ),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columnCount,
                  ),
                ),
              ))
        ],
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String primaryText;

  SectionHeader(this.primaryText);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: OutlinedText(
        primaryText,
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
        ),
        outlineColor: Colors.black87,
        outlineWidth: 2,
      ),
    );
  }
}
