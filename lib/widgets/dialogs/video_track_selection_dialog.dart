import 'package:aves/ref/languages.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/theme/text.dart';
import 'package:aves/theme/themes.dart';
import 'package:aves/widgets/common/basic/text_dropdown_button.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves_video/aves_video.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import 'aves_dialog.dart';

class VideoTrackSelectionDialog extends StatefulWidget {
  static const routeName = '/dialog/select_video_track';

  final Map<MediaTrackSummary, bool> tracks;

  const VideoTrackSelectionDialog({
    super.key,
    required this.tracks,
  });

  @override
  State<VideoTrackSelectionDialog> createState() => _VideoTrackSelectionDialogState();
}

class _VideoTrackSelectionDialogState extends State<VideoTrackSelectionDialog> {
  late List<MediaTrackSummary?> _videoTracks, _audioTracks, _textTracks;
  MediaTrackSummary? _currentVideo, _currentAudio, _currentText;

  @override
  void initState() {
    super.initState();

    final byType = groupBy<MediaTrackSummary, MediaTrackType>(widget.tracks.keys, (v) => v.type);
    // check width/height to exclude image tracks (that are included among video tracks)
    _videoTracks = (byType[MediaTrackType.video] ?? []).where((v) => v.width != null && v.height != null).toList();
    _audioTracks = (byType[MediaTrackType.audio] ?? []);
    _textTracks = [null, ...byType[MediaTrackType.text] ?? []];

    final trackEntries = widget.tracks.entries;
    _currentVideo = trackEntries.firstWhereOrNull((kv) => kv.key.type == MediaTrackType.video && kv.value)?.key;
    _currentAudio = trackEntries.firstWhereOrNull((kv) => kv.key.type == MediaTrackType.audio && kv.value)?.key;
    _currentText = trackEntries.firstWhereOrNull((kv) => kv.key.type == MediaTrackType.text && kv.value)?.key;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final canSelectVideo = _videoTracks.length > 1;
    final canSelectAudio = _audioTracks.length > 1;
    final canSelectText = _textTracks.length > 1;
    final canSelect = canSelectVideo || canSelectAudio || canSelectText;
    if (!canSelect) {
      return AvesMessageDialog.info(l10n.videoStreamSelectionDialogNoSelection);
    }
    return AvesDialog(
      scrollableContent: [
        if (canSelectVideo)
          ..._buildSection(
            icon: AIcons.trackVideo,
            title: l10n.videoStreamSelectionDialogVideo,
            tracks: _videoTracks,
            current: _currentVideo,
            setter: (v) => _currentVideo = v,
          ),
        if (canSelectAudio)
          ..._buildSection(
            icon: AIcons.trackAudio,
            title: l10n.videoStreamSelectionDialogAudio,
            tracks: _audioTracks,
            current: _currentAudio,
            setter: (v) => _currentAudio = v,
          ),
        if (canSelectText)
          ..._buildSection(
            icon: AIcons.trackText,
            title: l10n.videoStreamSelectionDialogText,
            tracks: _textTracks,
            current: _currentText,
            setter: (v) => _currentText = v,
          ),
        const SizedBox(height: 8),
      ],
      actions: [
        const CancelButton(),
        TextButton(
          onPressed: () => _submit(context),
          child: Text(l10n.applyButtonLabel),
        ),
      ],
    );
  }

  static String _formatLanguage(String value) {
    final language = Language.living639_2.firstWhereOrNull((language) => language.iso639_2 == value);
    return language?.native ?? value;
  }

  String _commonTrackName(MediaTrackSummary? track) {
    if (track == null) return context.l10n.videoStreamSelectionDialogOff;
    final title = track.title;
    final language = track.language;
    if (language != null && language != 'und') {
      final formattedLanguage = _formatLanguage(language);
      return '$formattedLanguage${title != null && title != formattedLanguage ? ' • $title' : ''}';
    } else if (title != null) {
      return title;
    } else {
      return '${context.l10n.videoStreamSelectionDialogTrack} ${track.index} (${track.codecName})';
    }
  }

  String _trackName(MediaTrackSummary? track) {
    final common = _commonTrackName(track);
    if (track != null && track.type == MediaTrackType.video) {
      final w = track.width;
      final h = track.height;
      if (w != null && h != null) {
        return '$common • $w${AText.resolutionSeparator}$h';
      }
    }
    return common;
  }

  List<Widget> _buildSection({
    required IconData icon,
    required String title,
    required List<MediaTrackSummary?> tracks,
    required MediaTrackSummary? current,
    required ValueSetter<MediaTrackSummary?> setter,
  }) {
    return [
      Padding(
        padding: const EdgeInsets.only(left: 16, top: 16, right: 16),
        child: Row(
          children: [
            Icon(icon),
            const SizedBox(width: 16),
            Text(title),
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        // allow `null` subtitle track to disable subtitles
        child: TextDropdownButton<MediaTrackSummary?>(
          values: tracks,
          valueText: _trackName,
          value: current,
          onChanged: tracks.length > 1 ? (newValue) => setState(() => setter(newValue)) : null,
          isExpanded: true,
          dropdownColor: Themes.thirdLayerColor(context),
        ),
      ),
    ];
  }

  void _submit(BuildContext context) => Navigator.maybeOf(context)?.pop({
    MediaTrackType.video: _currentVideo,
    MediaTrackType.audio: _currentAudio,
    MediaTrackType.text: _currentText,
  });
}
