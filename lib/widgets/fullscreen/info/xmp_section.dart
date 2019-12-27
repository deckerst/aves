import 'package:aves/model/image_collection.dart';
import 'package:aves/model/image_entry.dart';
import 'package:aves/widgets/album/filtered_collection_page.dart';
import 'package:aves/widgets/fullscreen/info/info_page.dart';
import 'package:flutter/material.dart';

class XmpTagSection extends AnimatedWidget {
  final ImageCollection collection;
  final ImageEntry entry;

  XmpTagSection({
    Key key,
    @required this.collection,
    @required this.entry,
  }) : super(key: key, listenable: entry.metadataChangeNotifier);

  @override
  Widget build(BuildContext context) {
    final tags = entry.xmpSubjects;
    return tags.isEmpty
        ? const SizedBox.shrink()
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionRow('XMP Tags'),
              Wrap(
                spacing: 8,
                children: tags.map((tag) {
                  final borderColor = Theme.of(context).accentColor;
                  return OutlineButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FilteredCollectionPage(
                          collection: collection,
                          filter: (entry) => entry.xmpSubjects.contains(tag),
                          title: tag,
                        ),
                      ),
                    ),
                    borderSide: BorderSide(
                      color: borderColor,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(42),
                    ),
                    child: Text(tag),
                  );
                }).toList(),
              ),
            ],
          );
  }
}
