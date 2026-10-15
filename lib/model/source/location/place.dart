import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/filters/covered/location.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/model/source/filter_summary.dart';

mixin PlaceMixin on SourceBase {
  // by place
  final Map<String, FilterSummary> _filterSummary = {};

  void invalidatePlaceFilterSummary({
    Set<AvesEntry>? entries,
    Set<String>? places,
    bool notify = true,
  }) {
    if (_filterSummary.isEmpty) return;

    if (entries == null && places == null) {
      _filterSummary.clear();
    } else {
      places ??= {};
      if (entries != null) {
        places.addAll(entries.map((entry) => entry.addressDetails?.place).nonNulls);
      }
      places.forEach(_filterSummary.remove);
    }
    if (notify) {
      eventBus.fire(PlaceSummaryInvalidatedEvent(places));
    }
  }

  FilterSummary _getSummary(LocationFilter filter) {
    return _filterSummary.putIfAbsent(filter.place, () => computeFilterSummary(filter));
  }

  int placeEntryCount(LocationFilter filter) => _getSummary(filter).entryCount;

  int placeSize(LocationFilter filter) => _getSummary(filter).size;

  AvesEntry? placeRecentEntry(LocationFilter filter) => _getSummary(filter).recentEntry;
}

class PlacesChangedEvent;

class const PlaceSummaryInvalidatedEvent(final Set<String>? places);
