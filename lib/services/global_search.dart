import 'dart:ui';

import 'package:aves/services/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

class GlobalSearch {
  static const platform = MethodChannel('deckers.thibault/aves/global_search');

  static Future<void> registerCallback() async {
    try {
      await platform.invokeMethod('registerCallback', <String, dynamic>{
        'callbackHandle': PluginUtilities.getCallbackHandle(_init)?.toRawHandle(),
      });
    } on PlatformException catch (e) {
      debugPrint('registerCallback failed with code=${e.code}, exception=${e.message}, details=${e.details}');
    }
  }
}

Future<void> _init() async {
  WidgetsFlutterBinding.ensureInitialized();

  // service initialization for path context, database
  initPlatformServices();
  await metadataDb.init();

  // `intl` initialization for date formatting
  await initializeDateFormatting();

  const _channel = MethodChannel('deckers.thibault/aves/global_search_background');
  _channel.setMethodCallHandler((call) async {
    switch (call.method) {
      case 'getSuggestions':
        return await _getSuggestions(call.arguments);
      default:
        throw PlatformException(code: 'not-implemented', message: 'failed to handle method=${call.method}');
    }
  });
  await _channel.invokeMethod('initialized');
}

Future<List<Map<String, String?>>> _getSuggestions(dynamic args) async {
  final suggestions = <Map<String, String?>>[];
  if (args is Map) {
    final query = args['query'];
    final locale = args['locale'];
    if (query is String && locale is String) {
      final entries = await metadataDb.searchEntries(query, limit: 10);
      suggestions.addAll(entries.map((entry) {
        final date = entry.bestDate;
        return {
          'data': entry.uri,
          'mimeType': entry.mimeType,
          'title': entry.bestTitle,
          'subtitle': date != null ? '${DateFormat.yMMMd(locale).format(date)} • ${DateFormat.Hm(locale).format(date)}' : null,
          'iconUri': entry.uri,
        };
      }));
    }
  }
  return suggestions;
}
