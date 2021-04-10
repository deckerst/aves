import 'dart:async';

import 'package:aves/model/entry.dart';
import 'package:aves/model/video/channel_layouts.dart';
import 'package:aves/utils/math_utils.dart';
import 'package:fijkplayer/fijkplayer.dart';

class StreamInfo {
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
          case 'index':
          case 'fps_num':
          case 'sar_num':
          case 'tbr_num':
          case 'tbr_den':
            break;
          case 'bitrate':
            dir['Bitrate'] = formatBitrate(value, round: 1);
            break;
          case 'channel_layout':
            dir['Channel Layout'] = ChannelLayouts.names[value] ?? value.toString();
            break;
          case 'codec_name':
            dir['Codec'] = value.toString().toUpperCase().replaceAll('_', ' ');
            break;
          case 'fps_den':
            dir['Frame Rate'] = roundToPrecision(stream['fps_num'] / stream['fps_den'], decimals: 3).toString();
            break;
          case 'height':
            dir['Height'] = '$value pixels';
            break;
          case 'language':
            dir['Language'] = value;
            break;
          case 'sample_rate':
            dir['Sample Rate'] = '$value Hz';
            break;
          case 'sar_den':
            dir['SAR'] = '${stream['sar_num']}:${stream['sar_den']}';
            break;
          case 'type':
            switch (value) {
              case 'timedtext':
                dir['Type'] = 'timed text';
                break;
              case 'audio':
              case 'video':
              case 'metadata':
              case 'subtitle':
              case 'unknown':
              default:
                dir['Type'] = value;
            }
            break;
          case 'width':
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
