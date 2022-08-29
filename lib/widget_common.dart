import 'dart:async';

import 'package:aves/app_flavor.dart';
import 'package:aves/model/entry.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/model/source/media_store_source.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/widgets/home_widget.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const _widgetDrawChannel = MethodChannel('deckers.thibault/aves/widget_draw');

void widgetMainCommon(AppFlavor flavor) async {
  WidgetsFlutterBinding.ensureInitialized();
  initPlatformServices();
  await settings.init(monitorPlatformSettings: false);

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

Future<Uint8List> _drawWidget(dynamic args) async {
  final widgetId = args['widgetId'] as int;
  final widthPx = args['widthPx'] as int;
  final heightPx = args['heightPx'] as int;
  final devicePixelRatio = args['devicePixelRatio'] as double;
  final drawEntryImage = args['drawEntryImage'] as bool;
  final reuseEntry = args['reuseEntry'] as bool;

  final entry = drawEntryImage ? await _getWidgetEntry(widgetId, reuseEntry) : null;
  final painter = HomeWidgetPainter(
    entry: entry,
    devicePixelRatio: devicePixelRatio,
  );
  return painter.drawWidget(
    widthPx: widthPx,
    heightPx: heightPx,
    outline: settings.getWidgetOutline(widgetId),
    shape: settings.getWidgetShape(widgetId),
  );
}

Future<AvesEntry?> _getWidgetEntry(int widgetId, bool reuseEntry) async {
  final uri = reuseEntry ? settings.getWidgetUri(widgetId) : null;
  if (uri != null) {
    final entry = await mediaFetchService.getEntry(uri, null);
    if (entry != null) return entry;
  }

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
  entries.shuffle();
  final entry = entries.firstOrNull;
  if (entry != null) {
    settings.setWidgetUri(widgetId, entry.uri);
  }
  return entry;
}
