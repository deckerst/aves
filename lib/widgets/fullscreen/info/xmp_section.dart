import 'package:aves/model/collection_filters.dart';
import 'package:aves/model/collection_lens.dart';
import 'package:aves/model/image_entry.dart';
import 'package:aves/utils/color_utils.dart';
import 'package:aves/widgets/album/filtered_collection_page.dart';
import 'package:aves/widgets/fullscreen/info/info_page.dart';
import 'package:flutter/material.dart';

class XmpTagSectionSliver extends AnimatedWidget {
  final CollectionLens collection;
  final ImageEntry entry;

  static const double buttonBorderWidth = 2;

  XmpTagSectionSliver({
    Key key,
    @required this.collection,
    @required this.entry,
  }) : super(key: key, listenable: entry.metadataChangeNotifier);

  @override
  Widget build(BuildContext context) {
    final tags = entry.xmpSubjects;
    return SliverList(
      delegate: SliverChildListDelegate(
        tags.isEmpty
            ? []
            : [
                const SectionRow('XMP Tags'),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: buttonBorderWidth / 2),
                  child: Wrap(
                    spacing: 8,
                    children: tags
                        .map((tag) => OutlineButton(
                              onPressed: () => _goToTag(context, tag),
                              borderSide: BorderSide(
                                color: stringToColor(tag),
                                width: buttonBorderWidth,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(42),
                              ),
                              child: Text(tag),
                            ))
                        .toList(),
                  ),
                ),
              ],
      ),
    );
  }

  void _goToTag(BuildContext context, String tag) {
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
