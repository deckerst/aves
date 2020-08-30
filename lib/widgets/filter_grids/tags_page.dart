import 'package:aves/model/filters/tag.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/model/source/tag.dart';
import 'package:aves/widgets/album/empty.dart';
import 'package:aves/widgets/common/icons.dart';
import 'package:aves/widgets/filter_grids/filter_grid_page.dart';
import 'package:flutter/material.dart';

class TagListPage extends StatelessWidget {
  final CollectionSource source;

  const TagListPage({@required this.source});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: source.eventBus.on<TagsChangedEvent>(),
      builder: (context, snapshot) => FilterNavigationPage(
        source: source,
        title: 'Tags',
        filterEntries: source.getTagEntries(),
        filterBuilder: (s) => TagFilter(s),
        emptyBuilder: () => EmptyContent(
          icon: AIcons.tag,
          text: 'No tags',
        ),
      ),
    );
  }
}
