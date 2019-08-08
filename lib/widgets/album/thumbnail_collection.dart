import 'package:aves/model/image_entry.dart';
import 'package:aves/utils/date_utils.dart';
import 'package:aves/widgets/album/thumbnail.dart';
import 'package:aves/widgets/common/draggable_scrollbar.dart';
import 'package:aves/widgets/common/outlined_text.dart';
import 'package:aves/widgets/debug_page.dart';
import 'package:aves/widgets/fullscreen/image_page.dart';
import "package:collection/collection.dart";
import 'package:flutter/material.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:intl/intl.dart';

class ThumbnailCollection extends StatelessWidget {
  final List<ImageEntry> entries;
  final bool done;
  final Map<DateTime, List<ImageEntry>> sections;
  final ScrollController scrollController = ScrollController();

  ThumbnailCollection({Key key, this.entries, this.done})
      : sections = groupBy(entries, (entry) => entry.monthTaken),
        super(key: key);

  @override
  Widget build(BuildContext context) {
//    debugPrint('$runtimeType build with sections=${sections.length}');
    if (!done) {
      return Center(
        child: Text(
          'streamed ${entries.length} items',
          style: TextStyle(fontSize: 16),
        ),
      );
    }
    final bottomInsets = MediaQuery.of(context).viewInsets.bottom;
    final sectionKeys = sections.keys.toList();
    return SafeArea(
      child: DraggableScrollbar.arrows(
        child: CustomScrollView(
          controller: scrollController,
          slivers: [
            SliverAppBar(
              title: Text('Aves - All'),
              actions: [
                IconButton(icon: Icon(Icons.whatshot), onPressed: () => goToDebug(context)),
              ],
              floating: true,
            ),
            ...sectionKeys.map((sectionKey) {
              Widget sliver = SectionSliver(
                entries: entries,
                sections: sections,
                sectionKey: sectionKey,
              );
              if (sectionKey == sectionKeys.last) {
                sliver = SliverPadding(
                  padding: EdgeInsets.only(bottom: bottomInsets),
                  sliver: sliver,
                );
              }
              return sliver;
            }),
          ],
        ),
        controller: scrollController,
        padding: EdgeInsets.only(bottom: bottomInsets),
        labelTextBuilder: (double offset) => Text(
          "${offset ~/ 1}",
          style: TextStyle(color: Colors.blueGrey),
        ),
      ),
    );
  }

  Future goToDebug(BuildContext context) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DebugPage(),
      ),
    );
  }
}

class SectionSliver extends StatelessWidget {
  final List<ImageEntry> entries;
  final Map<DateTime, List<ImageEntry>> sections;
  final DateTime sectionKey;

  const SectionSliver({
    Key key,
    this.entries,
    this.sections,
    this.sectionKey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
//    debugPrint('$runtimeType build with sectionKey=$sectionKey');
    final columnCount = 4;
    return SliverStickyHeader(
      header: MonthSectionHeader(date: sectionKey),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate(
          (sliverContext, index) {
            final sectionEntries = sections[sectionKey];
            if (index >= sectionEntries.length) return null;
            final entry = sectionEntries[index];
            final mediaQuery = MediaQuery.of(sliverContext);
            return GestureDetector(
              onTap: () => _showFullscreen(sliverContext, entry),
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
    );
  }

  Future _showFullscreen(BuildContext context, ImageEntry entry) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullscreenPage(
          entries: entries,
          initialUri: entry.uri,
        ),
      ),
    );
  }
}

class DaySectionHeader extends StatelessWidget {
  final String text;

  DaySectionHeader({Key key, DateTime date})
      : text = formatDate(date),
        super(key: key);

  static DateFormat md = DateFormat.MMMMd();
  static DateFormat ymd = DateFormat.yMMMMd();

  static formatDate(DateTime date) {
    if (isToday(date)) return 'Today';
    if (isThisYear(date)) return md.format(date);
    return ymd.format(date);
  }

  @override
  Widget build(BuildContext context) {
    return SectionHeader(text: text);
  }
}

class MonthSectionHeader extends StatelessWidget {
  final String text;

  MonthSectionHeader({Key key, DateTime date})
      : text = formatDate(date),
        super(key: key);

  static DateFormat m = DateFormat.MMMM();
  static DateFormat ym = DateFormat.yMMMM();

  static formatDate(DateTime date) {
    if (isThisMonth(date)) return 'This month';
    if (isThisYear(date)) return m.format(date);
    return ym.format(date);
  }

  @override
  Widget build(BuildContext context) {
    return SectionHeader(text: text);
  }
}

class SectionHeader extends StatelessWidget {
  final String text;

  const SectionHeader({Key key, this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: OutlinedText(
        text,
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
