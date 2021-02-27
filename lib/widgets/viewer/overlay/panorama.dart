import 'package:aves/model/entry.dart';
import 'package:aves/services/metadata_service.dart';
import 'package:aves/widgets/viewer/overlay/common.dart';
import 'package:aves/widgets/viewer/panorama_page.dart';
import 'package:flutter/material.dart';
import 'package:pedantic/pedantic.dart';

class PanoramaOverlay extends StatelessWidget {
  final AvesEntry entry;
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
          onPressed: () async {
            final info = await MetadataService.getPanoramaInfo(entry);
            if (info != null) {
              unawaited(Navigator.push(
                context,
                MaterialPageRoute(
                  settings: RouteSettings(name: PanoramaPage.routeName),
                  builder: (context) => PanoramaPage(
                    entry: entry,
                    info: info,
                  ),
                ),
              ));
            }
          },
        )
      ],
    );
  }
}
