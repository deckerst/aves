import 'package:aves/common/draggable_scrollbar.dart';
import 'package:aves/common/outlined_text.dart';
import 'package:aves/image_fullscreen_page.dart';
import 'package:aves/model/image_entry.dart';
import 'package:aves/thumbnail.dart';
import 'package:aves/utils/date_utils.dart';
import "package:collection/collection.dart";
import 'package:flutter/material.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:intl/intl.dart';

class ThumbnailCollection extends StatelessWidget {
  final List<Map> entries;
  final Map<DateTime, List<Map>> sections;
  final ScrollController scrollController = ScrollController();

  ThumbnailCollection(this.entries) : sections = groupBy(entries, ImageEntry.getDayTaken);

  @override
  Widget build(BuildContext context) {
    var columnCount = 4;
    var mediaQuery = MediaQuery.of(context);

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
                header: DaySectionHeader(sectionKey),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      var sectionEntries = sections[sectionKey];
                      if (index >= sectionEntries.length) return null;
                      var entry = sectionEntries[index];
                      return GestureDetector(
                        onTap: () => _showFullscreen(context, entry),
                        child: Thumbnail(
                          entry: entry,
                          extent: mediaQuery.size.width / columnCount,
                          devicePixelRatio: mediaQuery.devicePixelRatio,
                        ),
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

  Future _showFullscreen(BuildContext context, Map entry) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImageFullscreenPage(
          entries: entries,
          initialUri: entry['uri'],
        ),
      ),
    );
  }
}

class DaySectionHeader extends StatelessWidget {
  final String text;

  static DateFormat md = DateFormat.MMMMd();
  static DateFormat ymd = DateFormat.yMMMMd();

  static formatDate(DateTime date) {
    if (isToday(date)) return 'Today';
    if (isThisYear(date)) return md.format(date);
    return ymd.format(date);
  }

  DaySectionHeader(DateTime date) : text = formatDate(date);

  @override
  Widget build(BuildContext context) {
    return SectionHeader(text);
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
          color: Colors.grey[200],
          fontSize: 20,
          shadows: [
            Shadow(
              offset: Offset(0, 2),
              blurRadius: 3,
              color: Colors.grey[900],
            ),
          ],
        ),
        outlineColor: Colors.black87,
        outlineWidth: 2,
      ),
    );
  }
}
