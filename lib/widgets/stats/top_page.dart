import 'dart:convert';
import 'dart:typed_data';

import 'package:aves/model/filters/covered/stored_album.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/ref/locales.dart';
import 'package:aves/ref/mime_types.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/action_mixins/feedback.dart';
import 'package:aves/widgets/common/basic/insets.dart';
import 'package:aves/widgets/common/basic/scaffold.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/extensions/media_query.dart';
import 'package:aves/widgets/common/identity/aves_filter_chip.dart';
import 'package:aves/widgets/stats/filter_table.dart';
import 'package:aves/widgets/viewer/controls/notifications.dart';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class StatsTopPage<T extends Comparable> extends StatelessWidget with FeedbackMixin {
  static const routeName = '/collection/stats/top';

  final String title;
  final int totalEntryCount;
  final Map<T, int> entryCountMap;
  final CollectionFilter Function(T key) filterBuilder;
  final bool sortByCount;
  final AFilterCallback onFilterSelection;

  const StatsTopPage({
    super.key,
    required this.title,
    required this.totalEntryCount,
    required this.entryCountMap,
    required this.filterBuilder,
    required this.sortByCount,
    required this.onFilterSelection,
  });

  @override
  Widget build(BuildContext context) {
    return AvesScaffold(
      appBar: AppBar(
        automaticallyImplyLeading: !settings.useTvLayout,
        title: Text(title),
        actions: [
          IconButton(
            icon: Icon(AIcons.fileExport),
            onPressed: () => _export(context),
            tooltip: context.l10n.settingsActionExport,
          ),
        ],
      ),
      body: GestureAreaProtectorStack(
        child: SafeArea(
          bottom: false,
          child: Builder(
            builder: (context) {
              return NotificationListener<SelectFilterNotification>(
                onNotification: (notification) {
                  onFilterSelection(notification.filter);
                  return true;
                },
                child: SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8) +
                      EdgeInsets.only(
                        bottom: context.select<MediaQueryData, double>((mq) => mq.effectiveBottomPadding),
                      ),
                  child: FilterTable(
                    totalEntryCount: totalEntryCount,
                    entryCountMap: entryCountMap,
                    filterBuilder: filterBuilder,
                    sortByCount: sortByCount,
                    maxRowCount: null,
                    onFilterSelection: onFilterSelection,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _export(BuildContext context) async {
    final sortedEntries = entryCountMap.entries.toList();
    if (sortByCount) {
      sortedEntries.sort((kv1, kv2) {
        final c = kv2.value.compareTo(kv1.value);
        return c != 0 ? c : kv1.key.compareTo(kv2.key);
      });
    }

    final csvContent = csv.encode([
      [title, '#'],
      ...sortedEntries.map((kv) {
        final filter = filterBuilder(kv.key);
        final count = kv.value;

        String label;
        switch (filter) {
          case StoredAlbumFilter _:
            label = filter.album;
          default:
            label = filter.getLabel(context);
        }
        return [label, count];
      }),
    ]);

    const mimeType = MimeTypes.csv;
    final success = await storageService.createFile(
      'aves-stats-${DateFormat('yyyyMMdd_HHmmss', asciiLocale).format(DateTime.now())}${MimeTypes.extensionFor(mimeType)}',
      mimeType,
      Uint8List.fromList(utf8.encode(csvContent)),
    );
    if (success != null) {
      if (success) {
        showFeedback(context, FeedbackType.info, context.l10n.genericSuccessFeedback);
      } else {
        showFeedback(context, FeedbackType.warn, context.l10n.genericFailureFeedback);
      }
    }
  }
}
