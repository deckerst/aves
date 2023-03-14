import 'dart:async';

import 'package:aves/model/video_playback.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/theme/format.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/dialogs/aves_dialog.dart';
import 'package:aves_video/aves_video.dart';
import 'package:flutter/material.dart';

class DatabasePlaybackStateHandler extends PlaybackStateHandler {
  static const resumeTimeSaveMinProgress = .05;
  static const resumeTimeSaveMaxProgress = .95;

  @override
  Future<int?> getResumeTime({required int entryId, required BuildContext context}) async {
    final playback = await metadataDb.loadVideoPlayback(entryId);
    final resumeTime = playback?.resumeTimeMillis ?? 0;
    if (resumeTime == 0) return null;

    // clear on retrieval
    await metadataDb.removeVideoPlayback({entryId});

    final resume = await showDialog<bool>(
      context: context,
      builder: (context) => AvesDialog(
        content: Text(context.l10n.videoResumeDialogMessage(formatFriendlyDuration(Duration(milliseconds: resumeTime)))),
        actions: [
          TextButton(
            onPressed: () => Navigator.maybeOf(context)?.pop(false),
            child: Text(context.l10n.videoStartOverButtonLabel),
          ),
          TextButton(
            onPressed: () => Navigator.maybeOf(context)?.pop(true),
            child: Text(context.l10n.videoResumeButtonLabel),
          ),
        ],
      ),
      routeSettings: const RouteSettings(name: AvesDialog.confirmationRouteName),
    );
    if (resume == null || !resume) return 0;
    return resumeTime;
  }

  @override
  Future<void> saveResumeTime({required int entryId, required int position, required double progress}) async {
    if (resumeTimeSaveMinProgress < progress && progress < resumeTimeSaveMaxProgress) {
      await metadataDb.addVideoPlayback({
        VideoPlaybackRow(
          entryId: entryId,
          resumeTimeMillis: position,
        )
      });
    } else {
      await metadataDb.removeVideoPlayback({entryId});
    }
  }
}
