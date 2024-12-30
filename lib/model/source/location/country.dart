import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/filters/covered/location.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/utils/collection_utils.dart';
import 'package:collection/collection.dart';

mixin CountryMixin on SourceBase {
  // by country code
  final Map<String, int> _filterEntryCountMap = {}, _filterSizeMap = {};
  final Map<String, AvesEntry?> _filterRecentEntryMap = {};

  void invalidateCountryFilterSummary({
    Set<AvesEntry>? entries,
    Set<String>? countryCodes,
    bool notify = true,
  }) {
    if (_filterEntryCountMap.isEmpty && _filterSizeMap.isEmpty && _filterRecentEntryMap.isEmpty) return;

    if (entries == null && countryCodes == null) {
      _filterEntryCountMap.clear();
      _filterSizeMap.clear();
      _filterRecentEntryMap.clear();
    } else {
      countryCodes ??= {};
      if (entries != null) {
        countryCodes.addAll(entries.where((entry) => entry.hasAddress).map((entry) => entry.addressDetails?.countryCode).nonNulls);
      }
      countryCodes.forEach((countryCode) {
        _filterEntryCountMap.remove(countryCode);
        _filterSizeMap.remove(countryCode);
        _filterRecentEntryMap.remove(countryCode);
      });
    }
    if (notify) {
      eventBus.fire(CountrySummaryInvalidatedEvent(countryCodes));
    }
  }

  int countryEntryCount(LocationFilter filter) {
    final countryCode = filter.code;
    if (countryCode == null) return 0;
    return _filterEntryCountMap.putIfAbsent(countryCode, () => visibleEntries.where(filter.test).length);
  }

  int countrySize(LocationFilter filter) {
    final countryCode = filter.code;
    if (countryCode == null) return 0;
    return _filterSizeMap.putIfAbsent(countryCode, () => visibleEntries.where(filter.test).map((v) => v.sizeBytes).sum);
  }

  AvesEntry? countryRecentEntry(LocationFilter filter) {
    final countryCode = filter.code;
    if (countryCode == null) return null;
    return _filterRecentEntryMap.putIfAbsent(countryCode, () => sortedEntriesByDate.firstWhereOrNull(filter.test));
  }
}

class CountriesChangedEvent {}

class CountrySummaryInvalidatedEvent {
  final Set<String>? countryCodes;

  const CountrySummaryInvalidatedEvent(this.countryCodes);
}
