import 'package:aves/model/collection_filters.dart';
import 'package:aves/model/collection_lens.dart';
import 'package:aves/model/image_entry.dart';
import 'package:aves/widgets/album/filtered_collection_page.dart';
import 'package:aves/widgets/fullscreen/info/info_page.dart';
import 'package:aves/widgets/fullscreen/info/navigation_button.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:outline_material_icons/outline_material_icons.dart';

class XmpTagSectionSliver extends AnimatedWidget {
  final CollectionLens collection;
  final ImageEntry entry;

  XmpTagSectionSliver({
    Key key,
    @required this.collection,
    @required this.entry,
  }) : super(key: key, listenable: entry.metadataChangeNotifier);

  @override
  Widget build(BuildContext context) {
    final tags = entry.xmpSubjects..sort(compareAsciiUpperCase);
    return SliverList(
      delegate: SliverChildListDelegate.fixed(
        tags.isEmpty
            ? []
            : [
                const SectionRow(OMIcons.label),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: NavigationButton.buttonBorderWidth / 2),
                  child: Wrap(
                    spacing: 8,
                    children: tags
                        .map((tag) => NavigationButton(
                              label: tag,
                              onPressed: () => _goToTag(context, tag),
                            ))
                        .toList(),
                  ),
                ),
              ],
      ),
    );
  }

  void _goToTag(BuildContext context, String tag) {
    if (collection == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FilteredCollectionPage(
          collection: collection,
          filter: TagFilter(tag),
          title: tag,
        ),
      ),
    );
  }
}
