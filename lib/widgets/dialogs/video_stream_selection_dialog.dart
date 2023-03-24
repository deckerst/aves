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

class VideoStreamSelectionDialog extends StatefulWidget {
  static const routeName = '/dialog/select_video_stream';

  final Map<MediaStreamSummary, bool> streams;

  const VideoStreamSelectionDialog({
    super.key,
    required this.streams,
  });

  @override
  State<VideoStreamSelectionDialog> createState() => _VideoStreamSelectionDialogState();
}

class _VideoStreamSelectionDialogState extends State<VideoStreamSelectionDialog> {
  late List<MediaStreamSummary?> _videoStreams, _audioStreams, _textStreams;
  MediaStreamSummary? _currentVideo, _currentAudio, _currentText;

  @override
  void initState() {
    super.initState();

    final byType = groupBy<MediaStreamSummary, MediaStreamType>(widget.streams.keys, (v) => v.type);
    // check width/height to exclude image streams (that are included among video streams)
    _videoStreams = (byType[MediaStreamType.video] ?? []).where((v) => v.width != null && v.height != null).toList();
    _audioStreams = (byType[MediaStreamType.audio] ?? []);
    _textStreams = [null, ...byType[MediaStreamType.text] ?? []];

    final streamEntries = widget.streams.entries;
    _currentVideo = streamEntries.firstWhereOrNull((kv) => kv.key.type == MediaStreamType.video && kv.value)?.key;
    _currentAudio = streamEntries.firstWhereOrNull((kv) => kv.key.type == MediaStreamType.audio && kv.value)?.key;
    _currentText = streamEntries.firstWhereOrNull((kv) => kv.key.type == MediaStreamType.text && kv.value)?.key;
  }

  @override
  Widget build(BuildContext context) {
    final canSelectVideo = _videoStreams.length > 1;
    final canSelectAudio = _audioStreams.length > 1;
    final canSelectText = _textStreams.length > 1;
    final canSelect = canSelectVideo || canSelectAudio || canSelectText;
    return AvesDialog(
      content: canSelect ? null : Text(context.l10n.videoStreamSelectionDialogNoSelection),
      scrollableContent: canSelect
          ? [
              if (canSelectVideo)
                ..._buildSection(
                  icon: AIcons.streamVideo,
                  title: context.l10n.videoStreamSelectionDialogVideo,
                  streams: _videoStreams,
                  current: _currentVideo,
                  setter: (v) => _currentVideo = v,
                ),
              if (canSelectAudio)
                ..._buildSection(
                  icon: AIcons.streamAudio,
                  title: context.l10n.videoStreamSelectionDialogAudio,
                  streams: _audioStreams,
                  current: _currentAudio,
                  setter: (v) => _currentAudio = v,
                ),
              if (canSelectText)
                ..._buildSection(
                  icon: AIcons.streamText,
                  title: context.l10n.videoStreamSelectionDialogText,
                  streams: _textStreams,
                  current: _currentText,
                  setter: (v) => _currentText = v,
                ),
              const SizedBox(height: 8),
            ]
          : null,
      actions: [
        const CancelButton(),
        if (canSelect)
          TextButton(
            onPressed: () => _submit(context),
            child: Text(context.l10n.applyButtonLabel),
          ),
      ],
    );
  }

  static String _formatLanguage(String value) {
    final language = Language.living639_2.firstWhereOrNull((language) => language.iso639_2 == value);
    return language?.native ?? value;
  }

  String _commonStreamName(MediaStreamSummary? stream) {
    if (stream == null) return context.l10n.videoStreamSelectionDialogOff;
    final title = stream.title;
    final language = stream.language;
    if (language != null && language != 'und') {
      final formattedLanguage = _formatLanguage(language);
      return '$formattedLanguage${title != null && title != formattedLanguage ? ' • $title' : ''}';
    } else if (title != null) {
      return title;
    } else {
      return '${context.l10n.videoStreamSelectionDialogTrack} ${stream.index} (${stream.codecName})';
    }
  }

  String _streamName(MediaStreamSummary? stream) {
    final common = _commonStreamName(stream);
    if (stream != null && stream.type == MediaStreamType.video) {
      final w = stream.width;
      final h = stream.height;
      if (w != null && h != null) {
        return '$common • $w${AText.resolutionSeparator}$h';
      }
    }
    return common;
  }

  List<Widget> _buildSection({
    required IconData icon,
    required String title,
    required List<MediaStreamSummary?> streams,
    required MediaStreamSummary? current,
    required ValueSetter<MediaStreamSummary?> setter,
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
        child: TextDropdownButton<MediaStreamSummary>(
          values: streams.whereNotNull().toList(),
          valueText: _streamName,
          value: current,
          onChanged: streams.length > 1 ? (newValue) => setState(() => setter(newValue)) : null,
          isExpanded: true,
          dropdownColor: Themes.thirdLayerColor(context),
        ),
      ),
    ];
  }

  void _submit(BuildContext context) => Navigator.maybeOf(context)?.pop({
        MediaStreamType.video: _currentVideo,
        MediaStreamType.audio: _currentAudio,
        MediaStreamType.text: _currentText,
      });
}
