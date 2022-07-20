import 'package:aves/model/entry.dart';
import 'package:aves/model/video_playback.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/theme/format.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/dialogs/aves_dialog.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

abstract class AvesVideoController {
  final AvesEntry _entry;
  final bool persistPlayback;

  AvesEntry get entry => _entry;

  AvesVideoController(AvesEntry entry, {required this.persistPlayback}) : _entry = entry;

  static const resumeTimeSaveMinProgress = .05;
  static const resumeTimeSaveMaxProgress = .95;
  static const resumeTimeSaveMinDuration = Duration(minutes: 2);

  @mustCallSuper
  Future<void> dispose() async {
    await _savePlaybackState();
  }

  Future<void> _savePlaybackState() async {
    final id = entry.id;
    if (!isReady || duration < resumeTimeSaveMinDuration.inMilliseconds) return;

    if (persistPlayback) {
      final _progress = progress;
      if (resumeTimeSaveMinProgress < _progress && _progress < resumeTimeSaveMaxProgress) {
        await metadataDb.addVideoPlayback({
          VideoPlaybackRow(
            entryId: id,
            resumeTimeMillis: currentPosition,
          )
        });
      } else {
        await metadataDb.removeVideoPlayback({id});
      }
    }
  }

  Future<int?> getResumeTime(BuildContext context) async {
    if (!persistPlayback) return null;

    final id = entry.id;
    final playback = await metadataDb.loadVideoPlayback(id);
    final resumeTime = playback?.resumeTimeMillis ?? 0;
    if (resumeTime == 0) return null;

    // clear on retrieval
    await metadataDb.removeVideoPlayback({id});

    final resume = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AvesDialog(
          content: Text(context.l10n.videoResumeDialogMessage(formatFriendlyDuration(Duration(milliseconds: resumeTime)))),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(context.l10n.videoStartOverButtonLabel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(context.l10n.videoResumeButtonLabel),
            ),
          ],
        );
      },
    );
    if (resume == null || !resume) return 0;
    return resumeTime;
  }

  Future<void> play();

  Future<void> pause();

  Future<void> seekTo(int targetMillis);

  Future<void> seekToProgress(double progress) => seekTo((duration * progress).toInt());

  Listenable get playCompletedListenable;

  VideoStatus get status;

  Stream<VideoStatus> get statusStream;

  Stream<double> get volumeStream;

  Stream<double> get speedStream;

  bool get isReady;

  bool get isPlaying => status == VideoStatus.playing;

  int get duration;

  int get currentPosition;

  double get progress {
    final _duration = duration;
    return _duration != 0 ? currentPosition.toDouble() / _duration : 0;
  }

  Stream<int> get positionStream;

  Stream<String?> get timedTextStream;

  ValueNotifier<bool> get canCaptureFrameNotifier;

  ValueNotifier<bool> get canMuteNotifier;

  ValueNotifier<bool> get canSetSpeedNotifier;

  ValueNotifier<bool> get canSelectStreamNotifier;

  ValueNotifier<double> get sarNotifier;

  bool get isMuted;

  double get speed;

  double get minSpeed;

  double get maxSpeed;

  set speed(double speed);

  Future<void> selectStream(StreamType type, StreamSummary? selected);

  Future<StreamSummary?> getSelectedStream(StreamType type);

  List<StreamSummary> get streams;

  Future<Uint8List> captureFrame();

  Future<void> toggleMute();

  Widget buildPlayerWidget(BuildContext context);
}

enum VideoStatus {
  idle,
  initialized,
  paused,
  playing,
  completed,
  error,
}

enum StreamType { video, audio, text }

class StreamSummary {
  final StreamType type;
  final int? index, width, height;
  final String? codecName, language, title;

  const StreamSummary({
    required this.type,
    required this.index,
    required this.codecName,
    required this.language,
    required this.title,
    required this.width,
    required this.height,
  });

  @override
  String toString() => '$runtimeType#${shortHash(this)}{type: type, index: $index, codecName: $codecName, language: $language, title: $title, width: $width, height: $height}';
}
