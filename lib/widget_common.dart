import 'dart:async';

import 'package:aves/app_flavor.dart';
import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/entry/sort.dart';
import 'package:aves/model/settings/enums/widget_outline.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/model/source/media_store_source.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/utils/android_file_utils.dart';
import 'package:aves/widgets/home_widget.dart';
import 'package:aves_model/aves_model.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const _widgetDrawChannel = MethodChannel('deckers.thibault/aves/widget_draw');

void widgetMainCommon(AppFlavor flavor) async {
  debugPrint('Widget main start');
  WidgetsFlutterBinding.ensureInitialized();
  initPlatformServices();
  await settings.init(monitorPlatformSettings: false);
  await reportService.init();

  debugPrint('Widget channel method handling setup');
  _widgetDrawChannel.setMethodCallHandler((call) async {
    // widget settings may be modified in a different process after channel setup
    await settings.reload();

    switch (call.method) {
      case 'drawWidget':
        return _drawWidget(call.arguments);
      default:
        throw PlatformException(code: 'not-implemented', message: 'failed to handle method=${call.method}');
    }
  });
}

Future<Map<String, dynamic>> _drawWidget(dynamic args) async {
  final widgetId = args['widgetId'] as int;
  final sizesDip = (args['sizesDip'] as List).cast<Map>().map((kv) {
    return Size(kv['widthDip'] as double, kv['heightDip'] as double);
  }).toList();
  final cornerRadiusPx = args['cornerRadiusPx'] as double?;
  final devicePixelRatio = args['devicePixelRatio'] as double;
  final drawEntryImage = args['drawEntryImage'] as bool;
  final reuseEntry = args['reuseEntry'] as bool;
  final isSystemThemeDark = args['isSystemThemeDark'] as bool;

  final brightness = isSystemThemeDark ? Brightness.dark : Brightness.light;
  final outline = await settings.getWidgetOutline(widgetId).color(brightness);

  final entry = drawEntryImage ? await _getWidgetEntry(widgetId, reuseEntry) : null;
  final painter = HomeWidgetPainter(
    entry: entry,
    devicePixelRatio: devicePixelRatio,
  );
  final bytesBySizeDip = <Map<String, dynamic>>[];
  await Future.forEach(sizesDip, (sizeDip) async {
    final bytes = await painter.drawWidget(
      sizeDip: sizeDip,
      cornerRadiusPx: cornerRadiusPx,
      outline: outline,
      shape: settings.getWidgetShape(widgetId),
    );
    bytesBySizeDip.add({
      'widthDip': sizeDip.width,
      'heightDip': sizeDip.height,
      'bytes': bytes,
    });
  });
  return {
    'bytesBySizeDip': bytesBySizeDip,
    'updateOnTap': settings.getWidgetOpenPage(widgetId) == WidgetOpenPage.updateWidget,
  };
}

Future<AvesEntry?> _getWidgetEntry(int widgetId, bool reuseEntry) async {
  final uri = reuseEntry ? settings.getWidgetUri(widgetId) : null;
  if (uri != null) {
    final entry = await mediaFetchService.getEntry(uri, null);
    if (entry != null) return entry;
  }

  await androidFileUtils.init();

  final filters = settings.getWidgetCollectionFilters(widgetId);
  final source = MediaStoreSource();
  final readyCompleter = Completer();
  source.stateNotifier.addListener(() {
    if (source.isReady) {
      readyCompleter.complete();
    }
  });
  await source.init(canAnalyze: false);
  await readyCompleter.future;

  final entries = CollectionLens(source: source, filters: filters).sortedEntries;
  switch (settings.getWidgetDisplayedItem(widgetId)) {
    case WidgetDisplayedItem.random:
      entries.shuffle();
    case WidgetDisplayedItem.mostRecent:
      entries.sort(AvesEntrySort.compareByDate);
  }
  final entry = entries.firstOrNull;
  if (entry != null) {
    settings.setWidgetUri(widgetId, entry.uri);
  }
  source.dispose();
  return entry;
}
