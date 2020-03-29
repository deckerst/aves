import 'package:aves/model/collection_lens.dart';
import 'package:aves/model/collection_source.dart';
import 'package:aves/model/filters/album.dart';
import 'package:aves/model/filters/country.dart';
import 'package:aves/model/filters/favourite.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/filters/gif.dart';
import 'package:aves/model/filters/query.dart';
import 'package:aves/model/filters/tag.dart';
import 'package:aves/model/filters/video.dart';
import 'package:aves/utils/constants.dart';
import 'package:aves/widgets/common/aves_filter_chip.dart';
import 'package:flutter/material.dart';
import 'package:outline_material_icons/outline_material_icons.dart';

class ImageSearchDelegate extends SearchDelegate<CollectionFilter> {
  final CollectionLens collection;

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
    final upQuery = query.toUpperCase();
    final containQuery = (String s) => s.toUpperCase().contains(upQuery);
    return SafeArea(
      child: ListView(
        children: [
          ..._buildFilterRow(
            filters: [FavouriteFilter(), VideoFilter(), GifFilter()].where((f) => containQuery(f.label)),
          ),
          ..._buildFilterRow(
            title: 'Countries',
            filters: source.sortedCountries.where(containQuery).map((s) => CountryFilter(s)),
          ),
          ..._buildFilterRow(
            title: 'Albums',
            filters: source.sortedAlbums.where(containQuery).map((s) => AlbumFilter(s, CollectionSource.getUniqueAlbumName(s, source.sortedAlbums))).where((f) => containQuery(f.uniqueName)),
          ),
          ..._buildFilterRow(
            title: 'Tags',
            filters: source.sortedTags.where(containQuery).map((s) => TagFilter(s)),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildFilterRow({String title, @required Iterable<CollectionFilter> filters}) {
    if (filters.isEmpty) return [];
    final filtersList = filters.toList();
    return [
      if (title != null && title.isNotEmpty)
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            title,
            style: Constants.titleTextStyle,
          ),
        ),
      Container(
        height: kMinInteractiveDimension,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(AvesFilterChip.buttonBorderWidth / 2) + const EdgeInsets.symmetric(horizontal: 6),
          itemBuilder: (context, index) {
            if (index >= filtersList.length) return null;
            final filter = filtersList[index];
            return Center(
              child: AvesFilterChip(
                filter: filter,
                onPressed: (filter) => close(context, filter),
              ),
            );
          },
          separatorBuilder: (context, index) => const SizedBox(width: 8),
          itemCount: filtersList.length,
        ),
      ),
    ];
  }

  @override
  Widget buildResults(BuildContext context) {
    close(context, QueryFilter(query));
    return const SizedBox.shrink();
  }
}
