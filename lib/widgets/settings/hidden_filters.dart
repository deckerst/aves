import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/collection/empty.dart';
import 'package:aves/widgets/common/identity/aves_filter_chip.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HiddenFilterTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text('Hidden filters'),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            settings: RouteSettings(name: HiddenFilterPage.routeName),
            builder: (context) => HiddenFilterPage(),
          ),
        );
      },
    );
  }
}

class HiddenFilterPage extends StatelessWidget {
  static const routeName = '/settings/hidden';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hidden Filters'),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Row(
                children: [
                  Icon(AIcons.info),
                  SizedBox(width: 16),
                  Expanded(child: Text('Photos and videos matching hidden filters will not appear in your collection.')),
                ],
              ),
            ),
            Divider(),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(8),
                child: Consumer<Settings>(
                  builder: (context, settings, child) {
                    final hiddenFilters = settings.hiddenFilters;
                    final filterList = hiddenFilters.toList()..sort();
                    if (hiddenFilters.isEmpty) {
                      return EmptyContent(
                        icon: AIcons.hide,
                        text: 'No hidden filters',
                      );
                    }
                    return Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: filterList
                          .map((filter) => AvesFilterChip(
                                filter: filter,
                                removable: true,
                                onTap: (filter) => context.read<CollectionSource>().changeFilterVisibility(filter, true),
                                onLongPress: null,
                              ))
                          .toList(),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
