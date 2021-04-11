import 'dart:async';

import 'package:aves/model/entry.dart';
import 'package:aves/model/video/channel_layouts.dart';
import 'package:aves/utils/math_utils.dart';
import 'package:fijkplayer/fijkplayer.dart';

class StreamInfo {
  static const keyBitrate = 'bitrate';
  static const keyChannelLayout = 'channel_layout';
  static const keyCodecName = 'codec_name';
  static const keyFpsDen = 'fps_den';
  static const keyFpsNum = 'fps_num';
  static const keyHeight = 'height';
  static const keyIndex = 'index';
  static const keyLanguage = 'language';
  static const keySampleRate = 'sample_rate';
  static const keySarDen = 'sar_den';
  static const keySarNum = 'sar_num';
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
    for (final kv in stream.entries) {
      final value = kv.value;
      if (value != null) {
        final key = kv.key;
        switch (key) {
          case keyIndex:
          case keyFpsNum:
          case keySarNum:
          case keyTbrNum:
          case keyTbrDen:
            break;
          case keyBitrate:
            dir['Bitrate'] = formatBitrate(value, round: 1);
            break;
          case keyChannelLayout:
            dir['Channel Layout'] = ChannelLayouts.names[value] ?? 'unknown ($value)';
            break;
          case keyCodecName:
            dir['Codec'] = value.toString().toUpperCase().replaceAll('_', ' ');
            break;
          case keyFpsDen:
            dir['Frame Rate'] = roundToPrecision(stream[keyFpsNum] / stream[keyFpsDen], decimals: 3).toString();
            break;
          case keyHeight:
            dir['Height'] = '$value pixels';
            break;
          case keyLanguage:
            dir['Language'] = value;
            break;
          case keySampleRate:
            dir['Sample Rate'] = '$value Hz';
            break;
          case keySarDen:
            dir['SAR'] = '${stream[keySarNum]}:${stream[keySarDen]}';
            break;
          case keyType:
            switch (value) {
              case typeTimedText:
                dir['Type'] = 'timed text';
                break;
              case typeAudio:
              case typeMetadata:
              case typeSubtitle:
              case typeUnknown:
              case typeVideo:
              default:
                dir['Type'] = value;
            }
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
}
