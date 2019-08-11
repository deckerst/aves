import 'package:aves/model/image_entry.dart';
import 'package:aves/widgets/fullscreen/info/info_page.dart';
import 'package:flutter/material.dart';

class XmpTagSection extends AnimatedWidget {
  final ImageEntry entry;

  const XmpTagSection({Key key, this.entry}) : super(key: key, listenable: entry);

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
                          child: Chip(
                            backgroundColor: Theme.of(context).accentColor,
                            label: Text(tag),
                          ),
                        ))
                    .toList(),
              ),
            ],
          );
  }
}
