import 'package:aves_model/aves_model.dart';
import 'package:aves_video/aves_video.dart';
import 'package:ffmpeg_kit_flutter_min/ffmpeg_kit_config.dart';
import 'package:ffmpeg_kit_flutter_min/ffprobe_kit.dart';
import 'package:flutter/foundation.dart';

class FfmpegVideoMetadataFetcher extends AvesVideoMetadataFetcher {
  static const chaptersKey = 'chapters';
  static const formatKey = 'format';
  static const streamsKey = 'streams';

  @override
  void init() {}

  @override
  Future<Map> getMetadata(AvesEntryBase entry) async {
    var uri = entry.uri;
    if (uri.startsWith('content://')) {
      final safUri = await FFmpegKitConfig.getSafParameterForRead(uri);
      if (safUri == null) {
        debugPrint('failed to get SAF URI for entry=$entry');
        return {};
      }
      uri = safUri;
    }

    final session = await FFprobeKit.getMediaInformation(uri);
    final information = session.getMediaInformation();
    if (information == null) {
      final failStackTrace = await session.getFailStackTrace();
      final output = await session.getOutput();
      debugPrint('failed to get video metadata for entry=$entry, failStackTrace=$failStackTrace, output=$output');
      return {};
    }

    final props = information.getAllProperties();
    if (props == null) return {};

    final chapters = props[chaptersKey];
    if (chapters is List) {
      if (chapters.isEmpty) {
        props.remove(chaptersKey);
      }
    }

    final format = props.remove(formatKey);
    if (format is Map) {
      format.remove(Keys.filename);
      format.remove('size');
      _normalizeGroup(format);
      props.addAll(format);
    }

    final streams = props[streamsKey];
    if (streams is List) {
      streams.forEach((stream) {
        if (stream is Map) {
          _normalizeGroup(stream);

          final fps = stream[Keys.avgFrameRate];
          if (fps is String) {
            final parts = fps.split('/');
            if (parts.length == 2) {
              final num = int.tryParse(parts[0]);
              final den = int.tryParse(parts[1]);
              if (num != null && den != null) {
                if (den > 0) {
                  stream[Keys.fpsNum] = num;
                  stream[Keys.fpsDen] = den;
                }
                stream.remove(Keys.avgFrameRate);
              }
            }
          }

          final disposition = stream[Keys.disposition];
          if (disposition is Map) {
            disposition.removeWhere((key, value) => value == 0);
            stream[Keys.disposition] = disposition.keys.join(', ');
          }

          final idValue = stream['id'];
          if (idValue is String) {
            final id = int.tryParse(idValue);
            if (id != null) {
              stream[Keys.index] = id - 1;
              stream.remove('id');
            }
          }

          if (stream[Keys.streamType] == 'data') {
            stream[Keys.streamType] = MediaStreamTypes.metadata;
          }
        }
      });
    }
    return props;
  }

  void _normalizeGroup(Map<dynamic, dynamic> stream) {
    void replaceKey(k1, k2) {
      final v = stream.remove(k1);
      if (v != null) {
        stream[k2] = v;
      }
    }

    replaceKey('bit_rate', Keys.bitrate);
    replaceKey('codec_type', Keys.streamType);
    replaceKey('format_name', Keys.mediaFormat);
    replaceKey('level', Keys.codecLevel);
    replaceKey('nb_frames', Keys.frameCount);
    replaceKey('pix_fmt', Keys.codecPixelFormat);
    replaceKey('profile', Keys.codecProfileId);

    final tags = stream.remove('tags');
    if (tags is Map) {
      stream.addAll(tags);
    }

    <String>{
      Keys.codecProfileId,
      Keys.rFrameRate,
      'bits_per_sample',
      'closed_captions',
      'codec_long_name',
      'film_grain',
      'has_b_frames',
      'start_pts',
      'start_time',
      'vendor_id',
    }.forEach((key) {
      final value = stream[key];
      switch (value) {
        case final num v:
          if (v == 0) {
            stream.remove(key);
          }
        case final String v:
          if (double.tryParse(v) == 0 || v == '0/0' || v == 'unknown' || v == '[0][0][0][0]') {
            stream.remove(key);
          }
      }
    });
  }
}
