import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/widgets/common/identity/aves_filter_chip.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HiddenFilters extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Selector<Settings, Set<CollectionFilter>>(
        selector: (context, s) => s.hiddenFilters,
        builder: (context, hiddenFilters, child) {
          return ListTile(
            title: hiddenFilters.isEmpty ? Text('There are no hidden filters') : Text('Hidden filters'),
            trailing: hiddenFilters.isEmpty
                ? null
                : OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          settings: RouteSettings(name: HiddenFilterPage.routeName),
                          builder: (context) => HiddenFilterPage(),
                        ),
                      );
                    },
                    child: Text('Edit'.toUpperCase()),
                  ),
          );
        });
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
        child: Padding(
          padding: EdgeInsets.all(8),
          child: Consumer<Settings>(
            builder: (context, settings, child) {
              final filterList = settings.hiddenFilters.toList()..sort();
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: filterList
                    .map((filter) => AvesFilterChip(
                          filter: filter,
                          removable: true,
                          onTap: (filter) => context.read<CollectionSource>().changeFilterVisibility(filter, true),
                        ))
                    .toList(),
              );
            },
          ),
        ),
      ),
    );
  }
}
