import 'dart:async';

import 'package:aves/model/entry.dart';
import 'package:aves/model/metadata/catalog.dart';
import 'package:aves/model/video/channel_layouts.dart';
import 'package:aves/model/video/codecs.dart';
import 'package:aves/model/video/keys.dart';
import 'package:aves/model/video/profiles/aac.dart';
import 'package:aves/model/video/profiles/h264.dart';
import 'package:aves/model/video/profiles/hevc.dart';
import 'package:aves/ref/languages.dart';
import 'package:aves/ref/mp4.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/theme/format.dart';
import 'package:aves/utils/file_utils.dart';
import 'package:aves/utils/math_utils.dart';
import 'package:aves/utils/string_utils.dart';
import 'package:aves/utils/time_utils.dart';
import 'package:aves/widgets/viewer/video/fijkplayer.dart';
import 'package:collection/collection.dart';
import 'package:fijkplayer/fijkplayer.dart';
import 'package:flutter/foundation.dart';

class VideoMetadataFormatter {
  static final _dateY4M2D2H2m2s2Pattern = RegExp(r'(\d{4})[-/](\d{2})[-/](\d{2}) (\d{2}):(\d{2}):(\d{2})');
  static final _dateY4M2D2H2m2s2APmPattern = RegExp(r'(\d{4})[-/](\d{1,2})[-/](\d{1,2})T(\d+):(\d+):(\d+)( ([ap]\.? ?m\.?))?Z');
  static final _ambiguousDatePatterns = {
    RegExp(r'^\d{2}[-/]\d{2}[-/]\d{4}$'),
  };
  static final _durationPattern = RegExp(r'(\d+):(\d+):(\d+)(.\d+)');
  static final _locationPattern = RegExp(r'([+-][.0-9]+)');
  static final Map<String, String> _codecNames = {
    Codecs.ac3: 'AC-3',
    Codecs.eac3: 'E-AC-3',
    Codecs.h264: 'AVC (H.264)',
    Codecs.hevc: 'HEVC (H.265)',
    Codecs.matroska: 'Matroska',
    Codecs.mpeg4: 'MPEG-4 Visual',
    Codecs.mpts: 'MPEG-TS',
    Codecs.opus: 'Opus',
    Codecs.pgs: 'PGS',
    Codecs.subrip: 'SubRip',
    Codecs.theora: 'Theora',
    Codecs.vorbis: 'Vorbis',
    Codecs.webm: 'WebM',
  };

  static Future<Map> getVideoMetadata(AvesEntry entry) async {
    final player = FijkPlayer();
    final info = await player.setDataSourceUntilPrepared(entry.uri).then((v) {
      return player.getInfo();
    }).catchError((error) {
      debugPrint('failed to get video metadata for entry=$entry, error=$error');
      return {};
    });
    await player.release();
    return info;
  }

  static Future<Map<String, int>> getLoadingMetadata(AvesEntry entry) async {
    final mediaInfo = await getVideoMetadata(entry);
    final fields = <String, int>{};

    final streams = mediaInfo[Keys.streams];
    if (streams is List) {
      final allStreamInfo = streams.cast<Map>();
      final sizedStream = allStreamInfo.firstWhereOrNull((stream) => stream.containsKey(Keys.width) && stream.containsKey(Keys.height));
      if (sizedStream != null) {
        final width = sizedStream[Keys.width];
        final height = sizedStream[Keys.height];
        if (width is int && height is int) {
          fields['width'] = width;
          fields['height'] = height;
        }
      }
    }

    final durationMicros = mediaInfo[Keys.durationMicros];
    if (durationMicros is num) {
      fields['durationMillis'] = (durationMicros / 1000).round();
    }
    return fields;
  }

  static Future<CatalogMetadata?> getCatalogMetadata(AvesEntry entry) async {
    final mediaInfo = await getVideoMetadata(entry);

    // only consider values with at least 8 characters (yyyymmdd),
    // ignoring unset values like `0`, as well as year values like `2021`
    bool isDefined(dynamic value) => value is String && value.length >= 8;

    var dateString = mediaInfo[Keys.date];
    if (!isDefined(dateString)) {
      dateString = mediaInfo[Keys.creationTime];
    }
    int? dateMillis;
    if (isDefined(dateString)) {
      dateMillis = parseVideoDate(dateString);
      if (dateMillis == null && !isAmbiguousDate(dateString)) {
        await reportService.recordError('getCatalogMetadata failed to parse date=$dateString for mimeType=${entry.mimeType} entry=$entry', null);
      }
    }

    if (dateMillis != null) {
      return (entry.catalogMetadata ?? CatalogMetadata(id: entry.id)).copyWith(
        dateMillis: dateMillis,
      );
    }

    return entry.catalogMetadata;
  }

  static bool isAmbiguousDate(String dateString) {
    return _ambiguousDatePatterns.any((pattern) => pattern.hasMatch(dateString));
  }

  static int? parseVideoDate(String dateString) {
    final date = DateTime.tryParse(dateString);
    if (date != null) {
      return date.millisecondsSinceEpoch;
    }

    // `DateTime` does not recognize these values found in the wild:
    // - `UTC 2021-05-30 19:14:21`
    // - `2021/10/31 21:23:17`
    // - `2021-09-10T7:14:49 pmZ`
    // - `2022-01-28T5:07:46 p. m.Z`
    // - `2012-1-1T12:00:00Z`
    // - `2021` (not enough to build a date)

    var match = _dateY4M2D2H2m2s2Pattern.firstMatch(dateString);
    if (match != null) {
      final year = int.tryParse(match.group(1)!);
      final month = int.tryParse(match.group(2)!);
      final day = int.tryParse(match.group(3)!);
      final hour = int.tryParse(match.group(4)!);
      final minute = int.tryParse(match.group(5)!);
      final second = int.tryParse(match.group(6)!);

      if (year != null && month != null && day != null && hour != null && minute != null && second != null) {
        final date = DateTime(year, month, day, hour, minute, second, 0);
        return date.millisecondsSinceEpoch;
      }
    }

    match = _dateY4M2D2H2m2s2APmPattern.firstMatch(dateString);
    if (match != null) {
      final year = int.tryParse(match.group(1)!);
      final month = int.tryParse(match.group(2)!);
      final day = int.tryParse(match.group(3)!);
      final hour = int.tryParse(match.group(4)!);
      final minute = int.tryParse(match.group(5)!);
      final second = int.tryParse(match.group(6)!);
      final pm = match.group(8) == 'pm';

      if (year != null && month != null && day != null && hour != null && minute != null && second != null) {
        final date = DateTime(year, month, day, hour + (pm ? 12 : 0), minute, second, 0);
        return date.millisecondsSinceEpoch;
      }
    }

    return null;
  }

  // pattern to extract optional language code suffix, e.g. 'location-eng'
  static final keyWithLanguagePattern = RegExp(r'^(.*)-([a-z]{3})$');

  static Map<String, String> formatInfo(Map info) {
    final dir = <String, String>{};
    final streamType = info[Keys.streamType];
    final codec = info[Keys.codecName];
    for (final kv in info.entries) {
      final value = kv.value;
      if (value != null) {
        try {
          String? key;
          String? keyLanguage;
          // some keys have a language suffix, but they may be duplicates
          // we only keep the root key when they have the same value as the same key with no language
          final languageMatch = keyWithLanguagePattern.firstMatch(kv.key);
          if (languageMatch != null) {
            final code = languageMatch.group(2)!;
            final native = _formatLanguage(code);
            if (native != code) {
              final root = languageMatch.group(1)!;
              final rootValue = info[root];
              // skip if it is a duplicate of the same entry with no language
              if (rootValue == value) continue;
              key = root;
              if (info.keys.cast<String>().where((k) => k.startsWith('$root-')).length > 1) {
                // only keep language when multiple languages are present
                keyLanguage = native;
              }
            }
          }
          key = (key ?? (kv.key as String)).toLowerCase();

          void save(String key, String? value) {
            if (value != null) {
              dir[keyLanguage != null ? '$key ($keyLanguage)' : key] = value;
            }
          }

          switch (key) {
            case Keys.codecLevel:
            case Keys.fpsNum:
            case Keys.handlerName:
            case Keys.index:
            case Keys.sarNum:
            case Keys.selectedAudioStream:
            case Keys.selectedTextStream:
            case Keys.selectedVideoStream:
            case Keys.statisticsTags:
            case Keys.streams:
            case Keys.streamType:
            case Keys.tbrNum:
            case Keys.tbrDen:
              break;
            case Keys.androidCaptureFramerate:
              final captureFps = double.parse(value);
              save('Capture Frame Rate', '${roundToPrecision(captureFps, decimals: 3).toString()} FPS');
              break;
            case Keys.androidVersion:
              save('Android Version', value);
              break;
            case Keys.bitrate:
            case Keys.bps:
              save('Bit Rate', _formatMetric(value, 'b/s'));
              break;
            case Keys.byteCount:
              save('Size', _formatFilesize(value));
              break;
            case Keys.channelLayout:
              save('Channel Layout', _formatChannelLayout(value));
              break;
            case Keys.codecName:
              if (value != 'none') {
                save('Format', _formatCodecName(value));
              }
              break;
            case Keys.codecPixelFormat:
              if (streamType == StreamTypes.video) {
                // this is just a short name used by FFmpeg
                // user-friendly descriptions for related enums are defined in libavutil/pixfmt.h
                save('Pixel Format', (value as String).toUpperCase());
              }
              break;
            case Keys.codecProfileId:
              {
                final profile = int.tryParse(value);
                if (profile != null) {
                  String? profileString;
                  switch (codec) {
                    case Codecs.h264:
                    case Codecs.hevc:
                      {
                        final levelString = info[Keys.codecLevel];
                        if (levelString != null) {
                          final level = int.tryParse(levelString) ?? 0;
                          if (codec == Codecs.h264) {
                            profileString = H264.formatProfile(profile, level);
                          } else {
                            profileString = Hevc.formatProfile(profile, level);
                          }
                        }
                        break;
                      }
                    case Codecs.aac:
                      profileString = AAC.formatProfile(profile);
                      break;
                    default:
                      profileString = profile.toString();
                      break;
                  }
                  save('Format Profile', profileString);
                }
                break;
              }
            case Keys.compatibleBrands:
              final formattedBrands = RegExp(r'.{4}').allMatches(value).map((m) {
                final brand = m.group(0)!;
                return _formatBrand(brand);
              }).join(', ');
              save('Compatible Brands', formattedBrands);
              break;
            case Keys.creationTime:
              save('Creation Time', _formatDate(value));
              break;
            case Keys.date:
              if (value is String && value != '0') {
                final charCount = value.length;
                save(charCount == 4 ? 'Year' : 'Date', value);
              }
              break;
            case Keys.duration:
              save('Duration', _formatDuration(value));
              break;
            case Keys.durationMicros:
              if (value != 0) save('Duration', formatPreciseDuration(Duration(microseconds: value)));
              break;
            case Keys.fpsDen:
              save('Frame Rate', '${roundToPrecision(info[Keys.fpsNum] / info[Keys.fpsDen], decimals: 3).toString()} FPS');
              break;
            case Keys.frameCount:
              save('Frame Count', value);
              break;
            case Keys.height:
              save('Height', '$value pixels');
              break;
            case Keys.language:
              if (value != 'und') save('Language', _formatLanguage(value));
              break;
            case Keys.location:
              save('Location', _formatLocation(value));
              break;
            case Keys.majorBrand:
              save('Major Brand', _formatBrand(value));
              break;
            case Keys.mediaFormat:
              save('Format', (value as String).splitMapJoin(',', onMatch: (s) => ', ', onNonMatch: _formatCodecName));
              break;
            case Keys.mediaType:
              save('Media Type', value);
              break;
            case Keys.minorVersion:
              if (value != '0') save('Minor Version', value);
              break;
            case Keys.rotate:
              save('Rotation', '$value°');
              break;
            case Keys.sampleRate:
              save('Sample Rate', _formatMetric(value, 'Hz'));
              break;
            case Keys.sarDen:
              final sarNum = info[Keys.sarNum];
              final sarDen = info[Keys.sarDen];
              // skip common square pixels (1:1)
              if (sarNum != sarDen) save('SAR', '$sarNum:$sarDen');
              break;
            case Keys.sourceOshash:
              save('Source OSHash', value);
              break;
            case Keys.startMicros:
              if (value != 0) save('Start', formatPreciseDuration(Duration(microseconds: value)));
              break;
            case Keys.statisticsWritingApp:
              save('Stats Writing App', value);
              break;
            case Keys.statisticsWritingDateUtc:
              save('Stats Writing Date', _formatDate(value));
              break;
            case Keys.track:
              if (value != '0') save('Track', value);
              break;
            case Keys.width:
              save('Width', '$value pixels');
              break;
            default:
              save(key.toSentenceCase(), value.toString());
          }
        } catch (error) {
          debugPrint('failed to process video info key=${kv.key} value=${kv.value}, error=$error');
        }
      }
    }
    return dir;
  }

  static String _formatBrand(String value) => Mp4.brands[value] ?? value;

  static String _formatChannelLayout(value) => ChannelLayouts.names[value] ?? 'unknown ($value)';

  static String _formatCodecName(String value) => _codecNames[value] ?? value.toUpperCase().replaceAll('_', ' ');

  // input example: '2021-04-12T09:14:37.000000Z'
  static String? _formatDate(String value) {
    final date = DateTime.tryParse(value);
    if (date == null) return value;
    if (date == epoch) return null;
    return date.toIso8601String();
  }

  // input example: '00:00:05.408000000'
  static String _formatDuration(String value) {
    final match = _durationPattern.firstMatch(value);
    if (match != null) {
      final h = int.tryParse(match.group(1)!);
      final m = int.tryParse(match.group(2)!);
      final s = int.tryParse(match.group(3)!);
      final millis = double.tryParse(match.group(4)!);
      if (h != null && m != null && s != null && millis != null) {
        return formatPreciseDuration(Duration(
          hours: h,
          minutes: m,
          seconds: s,
          milliseconds: (millis * 1000).toInt(),
        ));
      }
    }
    return value;
  }

  static String _formatFilesize(String value) {
    final size = int.tryParse(value);
    return size != null ? formatFileSize('en_US', size) : value;
  }

  static String _formatLanguage(String value) {
    final language = Language.living639_2.firstWhereOrNull((language) => language.iso639_2 == value);
    return language?.native ?? value;
  }

  // format ISO 6709 input, e.g. '+37.5090+127.0243/' (Samsung), '+51.3328-000.7053+113.474/' (Apple)
  static String? _formatLocation(String value) {
    final matches = _locationPattern.allMatches(value);
    if (matches.isNotEmpty) {
      final coordinates = matches.map((m) => double.tryParse(m.group(0)!)).toList();
      if (coordinates.every((c) => c == 0)) return null;
      return coordinates.join(', ');
    }
    return value;
  }

  static String _formatMetric(dynamic size, String unit, {int round = 2}) {
    if (size is String) {
      final parsed = int.tryParse(size);
      if (parsed == null) return size;
      size = parsed;
    }

    const divider = 1000;
    if (size < divider) return '$size $unit';
    if (size < divider * divider) return '${(size / divider).toStringAsFixed(round)} K$unit';
    return '${(size / divider / divider).toStringAsFixed(round)} M$unit';
  }
}

class StreamTypes {
  static const attachment = 'attachment';
  static const audio = 'audio';
  static const metadata = 'metadata';
  static const subtitle = 'subtitle';
  static const timedText = 'timedtext';
  static const unknown = 'unknown';
  static const video = 'video';
}
