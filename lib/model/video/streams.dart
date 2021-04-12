import 'dart:async';

import 'package:aves/model/entry.dart';
import 'package:aves/model/video/channel_layouts.dart';
import 'package:aves/model/video/h264.dart';
import 'package:aves/ref/languages.dart';
import 'package:aves/utils/math_utils.dart';
import 'package:fijkplayer/fijkplayer.dart';

class StreamInfo {
  static const keyBitrate = 'bitrate';
  static const keyChannelLayout = 'channel_layout';
  static const keyCodecLevel = 'codec_level';
  static const keyCodecName = 'codec_name';
  static const keyCodecPixelFormat = 'codec_pixel_format';
  static const keyCodecProfileId = 'codec_profile_id';
  static const keyDurationMicro = 'duration_us';
  static const keyFormat = 'format';
  static const keyFpsDen = 'fps_den';
  static const keyFpsNum = 'fps_num';
  static const keyHeight = 'height';
  static const keyIndex = 'index';
  static const keyLanguage = 'language';
  static const keySampleRate = 'sample_rate';
  static const keySarDen = 'sar_den';
  static const keySarNum = 'sar_num';
  static const keyStartMicro = 'start_us';
  static const keyTbrDen = 'tbr_den';
  static const keyTbrNum = 'tbr_num';
  static const keyType = 'type';
  static const keyWidth = 'width';

  static const typeAudio = 'audio';
  static const typeMetadata = 'metadata';
  static const typeSubtitle = 'subtitle';
  static const typeTimedText = 'timedtext';
  static const typeUnknown = 'unknown';
  static const typeVideo = 'video';

  static Future<Map> getVideoInfo(AvesEntry entry) async {
    final player = FijkPlayer();
    await player.setDataSource(entry.uri, autoPlay: false);

    final completer = Completer();
    void onChange() {
      if ([FijkState.prepared, FijkState.error].contains(player.state)) {
        completer.complete();
      }
    }

    player.addListener(onChange);
    await player.prepareAsync();
    await completer.future;
    player.removeListener(onChange);

    final info = await player.getInfo();
    await player.release();
    return info;
  }

  static String formatBitrate(int size, {int round = 2}) {
    const divider = 1000;
    const symbol = 'bit/s';

    if (size < divider) return '$size $symbol';

    if (size < divider * divider && size % divider == 0) {
      return '${(size / divider).toStringAsFixed(0)} K$symbol';
    }
    if (size < divider * divider) {
      return '${(size / divider).toStringAsFixed(round)} K$symbol';
    }

    if (size < divider * divider * divider && size % divider == 0) {
      return '${(size / (divider * divider)).toStringAsFixed(0)} M$symbol';
    }
    return '${(size / divider / divider).toStringAsFixed(round)} M$symbol';
  }

  static Map<String, String> formatStreamInfo(Map stream) {
    final dir = <String, String>{};
    final type = stream[keyType];
    final codec = stream[keyCodecName];
    for (final kv in stream.entries) {
      final value = kv.value;
      if (value != null) {
        final key = kv.key;
        switch (key) {
          case keyCodecLevel:
          case keyFpsNum:
          case keyIndex:
          case keySarNum:
          case keyTbrNum:
          case keyTbrDen:
          case keyType:
            break;
          case keyBitrate:
            dir['Bitrate'] = formatBitrate(value, round: 1);
            break;
          case keyChannelLayout:
            dir['Channel Layout'] = ChannelLayouts.names[value] ?? 'unknown ($value)';
            break;
          case keyCodecName:
            dir['Codec'] = _getCodecName(value as String);
            break;
          case keyCodecPixelFormat:
            if (type == typeVideo) {
              dir['Pixel Format'] = (value as String).toUpperCase();
            }
            break;
          case keyCodecProfileId:
            if (codec == 'h264') {
              final profile = int.tryParse(value as String);
              if (profile != null && profile != 0) {
                final level = int.tryParse(stream[keyCodecLevel] as String);
                dir['Codec Profile'] = H264.formatProfile(profile, level);
              }
            }
            break;
          case keyFpsDen:
            dir['Frame Rate'] = roundToPrecision(stream[keyFpsNum] / stream[keyFpsDen], decimals: 3).toString();
            break;
          case keyHeight:
            dir['Height'] = '$value pixels';
            break;
          case keyLanguage:
            if (value != 'und') {
              final language = Language.living639_2.firstWhere((language) => language.iso639_2 == value, orElse: () => null);
              dir['Language'] = language?.native ?? value;
            }
            break;
          case keySampleRate:
            dir['Sample Rate'] = '$value Hz';
            break;
          case keySarDen:
            dir['SAR'] = '${stream[keySarNum]}:${stream[keySarDen]}';
            break;
          case keyWidth:
            dir['Width'] = '$value pixels';
            break;
          default:
            dir[key] = value.toString();
        }
      }
    }
    return dir;
  }

  static String _getCodecName(String value) {
    switch (value) {
      case 'ac3':
        return 'AC-3';
      case 'eac3':
        return 'E-AC-3';
      case 'h264':
        return 'AVC (H.264)';
      case 'hdmv_pgs_subtitle':
        return 'PGS';
      case 'hevc':
        return 'HEVC (H.265)';
      case 'mpeg4':
        return 'MPEG-4 Visual';
      case 'subrip':
        return 'SubRip';
      default:
        return value.toUpperCase().replaceAll('_', ' ');
    }
  }
}
