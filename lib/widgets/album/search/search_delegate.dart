import 'package:aves/model/collection_lens.dart';
import 'package:aves/model/filters/album.dart';
import 'package:aves/model/filters/favourite.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/filters/location.dart';
import 'package:aves/model/filters/mime.dart';
import 'package:aves/model/filters/query.dart';
import 'package:aves/model/filters/tag.dart';
import 'package:aves/model/mime_types.dart';
import 'package:aves/widgets/album/search/expandable_filter_row.dart';
import 'package:flutter/material.dart';
import 'package:outline_material_icons/outline_material_icons.dart';

class ImageSearchDelegate extends SearchDelegate<CollectionFilter> {
  final CollectionLens collection;
  final ValueNotifier<String> expandedSectionNotifier = ValueNotifier(null);

  ImageSearchDelegate(this.collection);

  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context);
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      tooltip: 'Back',
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
      onPressed: () => close(context, null),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          tooltip: 'Clear',
          icon: Icon(OMIcons.clear),
          onPressed: () {
            query = '';
            showSuggestions(context);
          },
        ),
    ];
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final source = collection.source;
    final upQuery = query.trim().toUpperCase();
    final containQuery = (String s) => s.toUpperCase().contains(upQuery);
    return SafeArea(
      child: ValueListenableBuilder<String>(
          valueListenable: expandedSectionNotifier,
          builder: (context, expandedSection, child) {
            return ListView(
              children: [
                _buildFilterRow(
                  context: context,
                  filters: [FavouriteFilter(), MimeFilter(MimeTypes.ANY_VIDEO), MimeFilter(MimeFilter.animated), MimeFilter(MimeTypes.SVG)].where((f) => containQuery(f.label)),
                ),
                _buildFilterRow(
                  context: context,
                  title: 'Albums',
                  filters: source.sortedAlbums.where(containQuery).map((s) => AlbumFilter(s, source.getUniqueAlbumName(s))).where((f) => containQuery(f.uniqueName)),
                ),
                _buildFilterRow(
                  context: context,
                  title: 'Cities',
                  filters: source.sortedCities.where(containQuery).map((s) => LocationFilter(LocationLevel.city, s)),
                ),
                _buildFilterRow(
                  context: context,
                  title: 'Countries',
                  filters: source.sortedCountries.where(containQuery).map((s) => LocationFilter(LocationLevel.country, s)),
                ),
                _buildFilterRow(
                  context: context,
                  title: 'Tags',
                  filters: source.sortedTags.where(containQuery).map((s) => TagFilter(s)),
                ),
              ],
            );
          }),
    );
  }

  Widget _buildFilterRow({@required BuildContext context, String title, @required Iterable<CollectionFilter> filters}) {
    return ExpandableFilterRow(
      title: title,
      filters: filters,
      expandedNotifier: expandedSectionNotifier,
      onPressed: (filter) => close(context, filter),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final cleanQuery = query.trim();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // `buildResults` is called in the build phase,
      // so we post the call that will filter the collection
      // and possibly trigger a rebuild here
      close(context, cleanQuery.isNotEmpty ? QueryFilter(cleanQuery) : null);
    });
    return const SizedBox.shrink();
  }
}
