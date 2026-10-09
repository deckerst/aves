import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/filters/covered/location.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/model/source/filter_summary.dart';

mixin CountryMixin on SourceBase {
  // by country code
  final Map<String, FilterSummary> _filterSummary = {};

  void invalidateCountryFilterSummary({
    Set<AvesEntry>? entries,
    Set<String>? countryCodes,
    bool notify = true,
  }) {
    if (_filterSummary.isEmpty) return;

    if (entries == null && countryCodes == null) {
      _filterSummary.clear();
    } else {
      countryCodes ??= {};
      if (entries != null) {
        countryCodes.addAll(entries.where((entry) => entry.hasAddress).map((entry) => entry.addressDetails?.countryCode).nonNulls);
      }
      countryCodes.forEach(_filterSummary.remove);
    }
    if (notify) {
      eventBus.fire(CountrySummaryInvalidatedEvent(countryCodes));
    }
  }

  FilterSummary _getSummary(LocationFilter filter) {
    final countryCode = filter.code;
    if (countryCode == null) return FilterSummary.empty;
    return _filterSummary.putIfAbsent(countryCode, () => computeFilterSummary(filter));
  }

  int countryEntryCount(LocationFilter filter) => _getSummary(filter).entryCount;

  int countrySize(LocationFilter filter) => _getSummary(filter).size;

  AvesEntry? countryRecentEntry(LocationFilter filter) => _getSummary(filter).recentEntry;
}

class CountriesChangedEvent;

class const CountrySummaryInvalidatedEvent(final Set<String>? countryCodes);
