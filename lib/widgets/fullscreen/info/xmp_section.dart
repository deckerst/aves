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
        ? SizedBox.shrink()
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionRow('XMP Tags'),
              Wrap(
                children: tags
                    .map((tag) => Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4.0),
                          child: ActionChip(
                            label: Text(tag),
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
                            backgroundColor: Theme.of(context).accentColor,
                          ),
                        ))
                    .toList(),
              ),
            ],
          );
  }
}
