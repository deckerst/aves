import 'package:aves/model/image_entry.dart';
import 'package:aves/widgets/fullscreen/overlay/common.dart';
import 'package:aves/widgets/fullscreen/panorama_page.dart';
import 'package:flutter/material.dart';

class PanoramaOverlay extends StatelessWidget {
  final ImageEntry entry;
  final Animation<double> scale;

  const PanoramaOverlay({
    Key key,
    @required this.entry,
    @required this.scale,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Spacer(),
        OverlayTextButton(
          scale: scale,
          text: 'Open Panorama',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                settings: RouteSettings(name: PanoramaPage.routeName),
                builder: (context) => PanoramaPage(entry: entry),
              ),
            );
          },
        )
      ],
    );
  }
}
