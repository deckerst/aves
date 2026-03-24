import 'dart:async';

import 'package:aves/model/filters/filters.dart';
import 'package:aves/services/app_service.dart';
import 'package:aves/services/common/channel.dart';
import 'package:aves/services/common/services.dart';
import 'package:flutter/services.dart';

class IntentService {
  static const _platform = AvesMethodChannel('deckers.thibault/aves/intent');
  static final _stream = AvesStreamsChannel('deckers.thibault/aves/activity_result_stream');

  static Future<Map<String, dynamic>> getIntentData() async {
    try {
      // returns nullable map with 'action' and possibly 'uri' 'mimeType'
      final result = await _platform.invokeMethod('getIntentData');
      if (result is Map) return result.cast<String, dynamic>();
    } on PlatformException catch (e, stack) {
      await reportService.recordError(e, stack);
    }
    return {};
  }

  static Future<void> submitPickedItems(List<String> uris) async {
    try {
      await _platform.invokeMethod('submitPickedItems', <String, Object?>{
        'uris': uris,
      });
    } on PlatformException catch (e, stack) {
      if (e.code == 'submitPickedItems-large') {
        throw TooManyItemsException();
      } else {
        await reportService.recordError(e, stack);
      }
    }
  }

  static Future<void> submitPickedCollectionFilters(Set<CollectionFilter>? filters) async {
    try {
      await _platform.invokeMethod('submitPickedCollectionFilters', <String, Object?>{
        'filters': filters?.map((filter) => filter.toJson()).toList(),
      });
    } on PlatformException catch (e, stack) {
      await reportService.recordError(e, stack);
    }
  }

  static Future<Set<CollectionFilter>?> pickCollectionFilters(Set<CollectionFilter>? initialFilters) async {
    try {
      final opCompleter = Completer<Set<CollectionFilter>?>();
      _stream
          .receiveBroadcastStream(<String, dynamic>{
            'op': 'pickCollectionFilters',
            'initialFilters': initialFilters?.map((filter) => filter.toJson()).toList(),
          })
          .listen(
            (data) {
              final result = (data as List?)?.cast<String>().map(CollectionFilter.fromJson).nonNulls.toSet();
              opCompleter.complete(result);
            },
            onError: opCompleter.completeError,
            onDone: () {
              if (!opCompleter.isCompleted) opCompleter.complete(null);
            },
            cancelOnError: true,
          );
      // `await` here, so that `completeError` will be caught below
      return await opCompleter.future;
    } on PlatformException catch (e, stack) {
      await reportService.recordError(e, stack);
    }
    return null;
  }
}
