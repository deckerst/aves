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

  XmpTagSectionSliver({
    Key key,
    @required this.collection,
    @required this.entry,
  }) : super(key: key, listenable: entry.metadataChangeNotifier);

  @override
  Widget build(BuildContext context) {
    final tags = entry.xmpSubjects;
    return SliverList(
      delegate: SliverChildListDelegate.fixed(
        tags.isEmpty
            ? []
            : [
                const SectionRow('Tags'),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: TagButton.buttonBorderWidth / 2),
                  child: Wrap(
                    spacing: 8,
                    children: tags
                        .map((tag) => TagButton(
                              tag: tag,
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

class TagButton extends StatelessWidget {
  final String tag;
  final VoidCallback onPressed;

  const TagButton({
    @required this.tag,
    @required this.onPressed,
  });

  static const double buttonBorderWidth = 2;

  @override
  Widget build(BuildContext context) {
    return OutlineButton(
      onPressed: onPressed,
      borderSide: BorderSide(
        color: stringToColor(tag),
        width: buttonBorderWidth,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(42),
      ),
      child: Text(tag),
    );
  }
}
