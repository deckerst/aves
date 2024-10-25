import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/filters/location.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/utils/collection_utils.dart';
import 'package:collection/collection.dart';

mixin StateMixin on SourceBase {
  // by state code
  final Map<String, int> _filterEntryCountMap = {}, _filterSizeMap = {};
  final Map<String, AvesEntry?> _filterRecentEntryMap = {};

  void invalidateStateFilterSummary({
    Set<AvesEntry>? entries,
    Set<String>? stateCodes,
    bool notify = true,
  }) {
    if (_filterEntryCountMap.isEmpty && _filterSizeMap.isEmpty && _filterRecentEntryMap.isEmpty) return;

    if (entries == null && stateCodes == null) {
      _filterEntryCountMap.clear();
      _filterSizeMap.clear();
      _filterRecentEntryMap.clear();
    } else {
      stateCodes ??= {};
      if (entries != null) {
        stateCodes.addAll(entries.where((entry) => entry.hasAddress).map((entry) => entry.addressDetails?.stateCode).nonNulls);
      }
      stateCodes.forEach((stateCode) {
        _filterEntryCountMap.remove(stateCode);
        _filterSizeMap.remove(stateCode);
        _filterRecentEntryMap.remove(stateCode);
      });
    }
    if (notify) {
      eventBus.fire(StateSummaryInvalidatedEvent(stateCodes));
    }
  }

  int stateEntryCount(LocationFilter filter) {
    final stateCode = filter.code;
    if (stateCode == null) return 0;
    return _filterEntryCountMap.putIfAbsent(stateCode, () => visibleEntries.where(filter.test).length);
  }

  int stateSize(LocationFilter filter) {
    final stateCode = filter.code;
    if (stateCode == null) return 0;
    return _filterSizeMap.putIfAbsent(stateCode, () => visibleEntries.where(filter.test).map((v) => v.sizeBytes).sum);
  }

  AvesEntry? stateRecentEntry(LocationFilter filter) {
    final stateCode = filter.code;
    if (stateCode == null) return null;
    return _filterRecentEntryMap.putIfAbsent(stateCode, () => sortedEntriesByDate.firstWhereOrNull(filter.test));
  }
}

class StatesChangedEvent {}

class StateSummaryInvalidatedEvent {
  final Set<String>? stateCodes;

  const StateSummaryInvalidatedEvent(this.stateCodes);
}
