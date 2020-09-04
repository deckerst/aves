import 'package:aves/model/filters/location.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/model/source/location.dart';
import 'package:aves/widgets/album/empty.dart';
import 'package:aves/widgets/common/icons.dart';
import 'package:aves/widgets/filter_grids/filter_grid_page.dart';
import 'package:flutter/material.dart';

class CountryListPage extends StatelessWidget {
  static const routeName = '/countries';

  final CollectionSource source;

  const CountryListPage({@required this.source});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: source.eventBus.on<LocationsChangedEvent>(),
      builder: (context, snapshot) => FilterNavigationPage(
        source: source,
        title: 'Countries',
        filterEntries: source.getCountryEntries(),
        filterBuilder: (s) => LocationFilter(LocationLevel.country, s),
        emptyBuilder: () => EmptyContent(
          icon: AIcons.location,
          text: 'No countries',
        ),
      ),
    );
  }
}
