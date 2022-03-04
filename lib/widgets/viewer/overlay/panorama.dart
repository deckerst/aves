import 'dart:async';

import 'package:aves/model/entry.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/viewer/overlay/common.dart';
import 'package:aves/widgets/viewer/panorama_page.dart';
import 'package:flutter/material.dart';

class PanoramaOverlay extends StatelessWidget {
  final AvesEntry entry;
  final Animation<double> scale;

  const PanoramaOverlay({
    Key? key,
    required this.entry,
    required this.scale,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Spacer(),
        OverlayTextButton(
          scale: scale,
          buttonLabel: context.l10n.viewerOpenPanoramaButtonLabel,
          onPressed: () async {
            final info = await metadataFetchService.getPanoramaInfo(entry);
            if (info != null) {
              unawaited(Navigator.push(
                context,
                MaterialPageRoute(
                  settings: const RouteSettings(name: PanoramaPage.routeName),
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
