import 'dart:ui';

import 'package:aves/model/device.dart';
import 'package:aves/model/entry/sort.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/services/common/channel.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/theme/format.dart';
import 'package:aves/utils/android_file_utils.dart';
import 'package:collection/collection.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/date_symbol_data_local.dart';

class GlobalSearch {
  static const _platform = AvesMethodChannel('deckers.thibault/aves/global_search');

  static Future<void> registerCallback() async {
    try {
      await _platform.invokeMethod('registerCallback', <String, Object?>{
        // callback needs to be annotated with `@pragma('vm:entry-point')` to work in release mode
        'callbackHandle': PluginUtilities.getCallbackHandle(_init)?.toRawHandle(),
      });
    } on PlatformException catch (e, stack) {
      await reportService.recordError(e, stack);
    }
  }
}

@pragma('vm:entry-point')
Future<void> _init() async {
  WidgetsFlutterBinding.ensureInitialized();
  initPlatformServices();
  await androidFileUtils.init();
  await localMediaDb.init();
  await androidFileUtils.init();
  await localMediaDb.init();
  await device.init();
  await mobileServices.init();
  await settings.init(monitorPlatformSettings: false, shouldSanitize: false);
  await reportService.init();
  videoMetadataFetcher.init();

  // `intl` initialization for date formatting
  await initializeDateFormatting();

  const _channel = AvesMethodChannel('deckers.thibault/aves/global_search_background');
  _channel.setMethodCallHandler((call) async {
    switch (call.method) {
      case 'getSuggestions':
        return await _getSuggestions(call.arguments);
      default:
        throw PlatformException(code: 'not-implemented', message: 'failed to handle method=${call.method}');
    }
  });
  try {
    await _channel.invokeMethod('initialized');
  } on PlatformException catch (e, stack) {
    await reportService.recordError(e, stack);
  }
}

Future<List<Map<String, String?>>> _getSuggestions(Object? args) async {
  final suggestions = <Map<String, String?>>[];
  if (args is Map) {
    final query = args['query'];
    final localeName = args['locale'];
    final use24hour = args['use24hour'];
    debugPrint('getSuggestions query=$query, localeName=$localeName use24hour=$use24hour');

    if (query is String) {
      final entries = (await localMediaDb.searchLiveEntries(query, limit: 9)).toList();
      final catalogMetadata = await localMediaDb.loadCatalogMetadataById(entries.map((entry) => entry.id).toSet());
      catalogMetadata.forEach((metadata) => entries.firstWhereOrNull((entry) => entry.id == metadata.id)?.catalogMetadata = metadata);
      entries.sort(AvesEntrySort.compareByDate);

      suggestions.addAll(
        entries.map((entry) {
          final date = entry.bestDate;
          return {
            'data': entry.uri,
            'mimeType': entry.mimeType,
            'title': entry.bestTitle,
            'subtitle': date != null ? formatDateTime(date, settings.avesLocale, use24hour) : null,
            'iconUri': entry.uri,
          };
        }),
      );
    }
  }
  return suggestions;
}
