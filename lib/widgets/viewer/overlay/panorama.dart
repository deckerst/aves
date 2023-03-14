import 'dart:async';

import 'package:aves/model/entry/entry.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/identity/buttons/overlay_button.dart';
import 'package:aves/widgets/viewer/panorama_page.dart';
import 'package:flutter/material.dart';

class PanoramaOverlay extends StatelessWidget {
  final AvesEntry entry;
  final Animation<double> scale;

  const PanoramaOverlay({
    super.key,
    required this.entry,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Spacer(),
        ScalingOverlayTextButton(
          scale: scale,
          onPressed: () async {
            final info = await metadataFetchService.getPanoramaInfo(entry);
            if (info != null) {
              unawaited(Navigator.maybeOf(context)?.push(
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
          child: Text(context.l10n.viewerOpenPanoramaButtonLabel),
        ),
      ],
    );
  }
}
