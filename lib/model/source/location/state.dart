import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/filters/covered/location.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/model/source/filter_summary.dart';

mixin StateMixin on SourceBase {
  // by state code
  final Map<String, FilterSummary> _filterSummary = {};

  void invalidateStateFilterSummary({
    Set<AvesEntry>? entries,
    Set<String>? stateCodes,
    bool notify = true,
  }) {
    if (_filterSummary.isEmpty) return;

    if (entries == null && stateCodes == null) {
      _filterSummary.clear();
    } else {
      stateCodes ??= {};
      if (entries != null) {
        stateCodes.addAll(entries.where((entry) => entry.hasAddress).map((entry) => entry.addressDetails?.stateCode).nonNulls);
      }
      stateCodes.forEach(_filterSummary.remove);
    }
    if (notify) {
      eventBus.fire(StateSummaryInvalidatedEvent(stateCodes));
    }
  }

  FilterSummary _getSummary(LocationFilter filter) {
    final stateCode = filter.code;
    if (stateCode == null) return FilterSummary.empty;
    return _filterSummary.putIfAbsent(stateCode, () => computeFilterSummary(filter));
  }

  int stateEntryCount(LocationFilter filter) => _getSummary(filter).entryCount;

  int stateSize(LocationFilter filter) => _getSummary(filter).size;

  AvesEntry? stateRecentEntry(LocationFilter filter) => _getSummary(filter).recentEntry;
}

class StatesChangedEvent;

class const StateSummaryInvalidatedEvent(final Set<String>? stateCodes);
