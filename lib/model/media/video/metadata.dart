import 'dart:async';

import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/entry/extensions/keys.dart';
import 'package:aves/model/media/video/channel_layouts.dart';
import 'package:aves/model/media/video/codecs.dart';
import 'package:aves/model/media/video/profiles/aac.dart';
import 'package:aves/model/media/video/profiles/h264.dart';
import 'package:aves/model/media/video/profiles/hevc.dart';
import 'package:aves/model/media/video/stereo_3d_modes.dart';
import 'package:aves/model/metadata/catalog.dart';
import 'package:aves/ref/languages.dart';
import 'package:aves/ref/locales.dart';
import 'package:aves/ref/mime_types.dart';
import 'package:aves/ref/mp4.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/theme/format.dart';
import 'package:aves/utils/file_utils.dart';
import 'package:aves/utils/math_utils.dart';
import 'package:aves/utils/string_utils.dart';
import 'package:aves/utils/time_utils.dart';
import 'package:aves_model/aves_model.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';

class VideoMetadataFormatter {
  static final _dateY4M2D2H2m2s2Pattern = RegExp(r'(\d{4})[-./:](\d{1,2})[-./:](\d{1,2})([ T](\d{1,2}):(\d{1,2}):(\d{1,2})( ([ap]\.? ?m\.?))?)?');
  static final _ambiguousDatePatterns = {
    RegExp(r'^\d{2}[-/]\d{2}[-/]\d{4}$'),
  };
  static final _durationHmsmPattern = RegExp(r'(\d+):(\d+):(\d+)(.\d+)');
  static final _durationSmPattern = RegExp(r'(\d+)(.\d+)');
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

  // fetch size, rotation and duration
  static Future<Map<String, int>> getLoadingMetadata(AvesEntry entry) async {
    final mediaInfo = await videoMetadataFetcher.getMetadata(entry);
    final fields = <String, int>{};

    final streams = mediaInfo[Keys.streams];
    if (streams is List) {
      final allStreamInfo = streams.cast<Map>();
      final sizedStream = allStreamInfo.firstWhereOrNull((stream) => stream.containsKey(Keys.videoWidth) && stream.containsKey(Keys.videoHeight));
      if (sizedStream != null) {
        final width = sizedStream[Keys.videoWidth];
        final height = sizedStream[Keys.videoHeight];
        if (width is int && height is int) {
          fields[EntryFields.width] = width;
          fields[EntryFields.height] = height;
        }

        final rotationDegrees = sizedStream[Keys.rotate];
        if (rotationDegrees is int) {
          fields[EntryFields.rotationDegrees] = rotationDegrees;
        }
      }
    }

    final durationMicros = mediaInfo[Keys.durationMicros];
    if (durationMicros is num) {
      fields[EntryFields.durationMillis] = (durationMicros / 1000).round();
    } else {
      final duration = _parseDuration(mediaInfo[Keys.duration]);
      if (duration != null && duration > Duration.zero) {
        fields[EntryFields.durationMillis] = duration.inMilliseconds;
      }
    }
    return fields;
  }

  // fetch date and animated status
  static Future<CatalogMetadata?> completeCatalogMetadata(AvesEntry entry) async {
    var catalogMetadata = entry.catalogMetadata ?? CatalogMetadata(id: entry.id);

    final mediaInfo = await videoMetadataFetcher.getMetadata(entry);

    if (entry.mimeType == MimeTypes.avif) {
      final duration = _parseDuration(mediaInfo[Keys.duration]);
      if (duration == null || duration == Duration.zero) return null;

      catalogMetadata = catalogMetadata.copyWith(isAnimated: true);
    }

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
        await reportService.recordError('getCatalogMetadata failed to parse date=$dateString for mimeType=${entry.mimeType} entry=$entry');
      }
    }

    // exclude date if it is suspiciously close to epoch
    if (dateMillis != null && !DateTime.fromMillisecondsSinceEpoch(dateMillis).isAtSameDayAs(epoch)) {
      catalogMetadata = catalogMetadata.copyWith(dateMillis: dateMillis);
    }

    return catalogMetadata;
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
    // - `2020.10.14`
    // - `2016:11:16 18:00:00`
    // - `2021` (not enough to build a date)

    var match = _dateY4M2D2H2m2s2Pattern.firstMatch(dateString);
    if (match != null) {
      final year = int.tryParse(match.group(1)!);
      final month = int.tryParse(match.group(2)!);
      final day = int.tryParse(match.group(3)!);

      if (year != null && month != null && day != null) {
        var hour = 0, minute = 0, second = 0, pm = false;
        if (match.groupCount >= 7 && match.group(4) != null) {
          hour = int.tryParse(match.group(5)!) ?? 0;
          minute = int.tryParse(match.group(6)!) ?? 0;
          second = int.tryParse(match.group(7)!) ?? 0;
          pm = {'pm', 'p. m.'}.contains(match.group(9));
        }

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

          void save(String key, dynamic value) {
            if (value != null) {
              dir[keyLanguage != null ? '$key ($keyLanguage)' : key] = value.toString();
            }
          }

          switch (key) {
            case Keys.chapters:
            case Keys.codecLevel:
            case Keys.codecTag:
            case Keys.codecTagString:
            case Keys.durationTs:
            case Keys.fpsNum:
            case Keys.index:
            case Keys.isAvc:
            case Keys.probeScore:
            case Keys.programCount:
            case Keys.refs:
            case Keys.sarNum:
            case Keys.selectedAudioStream:
            case Keys.selectedTextStream:
            case Keys.selectedVideoStream:
            case Keys.statisticsTags:
            case Keys.streamCount:
            case Keys.streams:
            case Keys.streamType:
            case Keys.tbrNum:
            case Keys.tbrDen:
              break;
            case Keys.androidCaptureFramerate:
              final captureFps = double.parse(value);
              save('Capture Frame Rate', '${roundToPrecision(captureFps, decimals: 3)} FPS');
            case Keys.androidManufacturer:
              save('Android Manufacturer', value);
            case Keys.androidModel:
              save('Android Model', value);
            case Keys.androidVersion:
              save('Android Version', value);
            case Keys.audioChannels:
              save('Audio Channels', value);
            case Keys.bitrate:
            case Keys.bps:
              save('Bit Rate', _formatMetric(value, 'b/s'));
            case Keys.byteCount:
              save('Size', _formatFilesize(value));
            case Keys.channelLayout:
              save('Channel Layout', _formatChannelLayout(value));
            case Keys.codecName:
              if (value != 'none') {
                save('Format', _formatCodecName(value));
              }
            case Keys.codecPixelFormat:
              if (streamType == MediaStreamTypes.video) {
                // this is just a short name used by FFmpeg
                // user-friendly descriptions for related enums are defined in libavutil/pixfmt.h
                save('Pixel Format', value.toString().toUpperCase());
              }
            case Keys.hwPixelFormat:
              save('Hardware Pixel Format', value.toString().toUpperCase());
            case Keys.codedHeight:
              save('Coded Height', '$value pixels');
            case Keys.codedWidth:
              save('Coded Width', '$value pixels');
            case Keys.decoderHeight:
              save('Decoder Height', '$value pixels');
            case Keys.decoderWidth:
              save('Decoder Width', '$value pixels');
            case Keys.colorMatrix:
              save('Color Matrix', value.toString().toUpperCase());
            case Keys.colorPrimaries:
              save('Color Primaries', value.toString().toUpperCase());
            case Keys.colorRange:
              save('Color Range', value.toString().toUpperCase());
            case Keys.colorSpace:
              save('Color Space', value.toString().toUpperCase());
            case Keys.colorTransfer:
              save('Color Transfer', value.toString().toUpperCase());
            case Keys.codecProfileId:
              {
                final profile = int.tryParse(value);
                if (profile != null) {
                  String? profileString;
                  switch (codec) {
                    case Codecs.h264:
                    case Codecs.hevc:
                      {
                        final levelValue = info[Keys.codecLevel];
                        if (levelValue != null) {
                          final level = levelValue is int ? levelValue : int.tryParse(levelValue) ?? 0;
                          if (codec == Codecs.h264) {
                            profileString = H264.formatProfile(profile, level);
                          } else {
                            profileString = Hevc.formatProfile(profile, level);
                          }
                        }
                      }
                    case Codecs.aac:
                      profileString = AAC.formatProfile(profile);
                    default:
                      profileString = profile.toString();
                  }
                  save('Format Profile', profileString);
                }
              }
            case Keys.compatibleBrands:
              final formattedBrands = RegExp(r'.{4}').allMatches(value).map((m) {
                final brand = m.group(0)!;
                return _formatBrand(brand);
              }).join(', ');
              save('Compatible Brands', formattedBrands);
            case Keys.creationTime:
              save('Creation Time', _formatDate(value));
            case Keys.date:
              if (value is String && value != '0') {
                final charCount = value.length;
                save(charCount == 4 ? 'Year' : 'Date', value);
              }
            case Keys.duration:
              save('Duration', _formatDuration(value));
            case Keys.durationMicros:
              if (value != 0) save('Duration', formatPreciseDuration(Duration(microseconds: value)));
            case Keys.extraDataSize:
              save('Extra Data Size', _formatFilesize(value));
            case Keys.fps:
              save('Frame Rate', '${roundToPrecision(info[Keys.fps], decimals: 3)} FPS');
            case Keys.fpsDen:
              save('Frame Rate', '${roundToPrecision(info[Keys.fpsNum] / info[Keys.fpsDen], decimals: 3)} FPS');
            case Keys.frameCount:
              save('Frame Count', value);
            case Keys.gamma:
              save('Gamma', value.toString().toUpperCase());
            case Keys.hasBFrames:
              save('Has B-Frames', value);
            case Keys.hearingImpaired:
              save('Hearing impaired', value);
            case Keys.language:
              if (value != 'und') save('Language', _formatLanguage(value));
            case Keys.location:
              save('Location', _formatLocation(value));
            case Keys.majorBrand:
              save('Major Brand', _formatBrand(value));
            case Keys.mediaFormat:
              save('Format', value.toString().splitMapJoin(',', onMatch: (s) => ', ', onNonMatch: _formatCodecName));
            case Keys.minorVersion:
              if (value != '0') save('Minor Version', value);
            case Keys.nalLengthSize:
              save('NAL Length Size', _formatFilesize(value));
            case Keys.quicktimeLocationAccuracyHorizontal:
              save('QuickTime Location Horizontal Accuracy', value);
            case Keys.quicktimeCreationDate:
            case Keys.quicktimeLocationIso6709:
            case Keys.quicktimeMake:
            case Keys.quicktimeModel:
            case Keys.quicktimeSoftware:
              // redundant with `QuickTime Metadata` directory
              break;
            case Keys.rFrameRate:
              save('R Frame Rate', value);
            case Keys.rotate:
              save('Rotation', '$value°');
            case Keys.sampleFormat:
              save('Sample Format', value.toString().toUpperCase());
            case Keys.sampleRate:
              save('Sample Rate', _formatMetric(value, 'Hz'));
            case Keys.sar:
              save('Sample Aspect Ratio', value);
            case Keys.sarDen:
              final sarNum = info[Keys.sarNum];
              final sarDen = info[Keys.sarDen];
              // skip common square pixels (1:1)
              if (sarNum != sarDen) save('SAR', '$sarNum:$sarDen');
            case Keys.segmentCount:
              save('Segment Count', value);
            case Keys.sourceOshash:
              save('Source OSHash', value);
            case Keys.startMicros:
              if (value != 0) save('Start', formatPreciseDuration(Duration(microseconds: value)));
            case Keys.startPts:
              save('Start PTS', value);
            case Keys.startTime:
              save('Start', _formatDuration(value));
            case Keys.statisticsWritingApp:
              save('Stats Writing App', value);
            case Keys.statisticsWritingDateUtc:
              save('Stats Writing Date', _formatDate(value));
            case Keys.stereo3dMode:
              save('Stereo 3D Mode', _formatStereo3dMode(value));
            case Keys.timeBase:
              save('Time Base', value);
            case Keys.track:
              if (value != '0') save('Track', value);
            case Keys.vendorId:
              save('Vendor ID', value);
            case Keys.videoHeight:
              save('Video Height', '$value pixels');
            case Keys.videoWidth:
              save('Video Width', '$value pixels');
            case Keys.visualImpaired:
              save('Visual impaired', value);
            case Keys.xiaomiSlowMoment:
              save('Xiaomi Slow Moment', value);
            default:
              save(key.toSentenceCase(), value);
          }
        } catch (error) {
          debugPrint('failed to process video info key=${kv.key} value=${kv.value}, error=$error');
        }
      }
    }
    return dir;
  }

  static String _formatBrand(String value) => Mp4.brands[value] ?? value;

  static String _formatChannelLayout(dynamic value) {
    if (value is int) {
      return ChannelLayouts.names[value] ?? 'unknown ($value)';
    }
    return '$value';
  }

  static String _formatCodecName(String value) => _codecNames[value] ?? value.toUpperCase().replaceAll('_', ' ');

  // input example: '2021-04-12T09:14:37.000000Z'
  static String? _formatDate(String value) {
    final date = DateTime.tryParse(value);
    if (date == null) return value;
    if (date == epoch) return null;
    return date.toIso8601String();
  }

  static String _formatStereo3dMode(String value) => Stereo3dModes.names[value] ?? value;

  // input example: '00:00:05.408000000' or '5.408000'
  static Duration? _parseDuration(String? value) {
    if (value == null) return null;

    var match = _durationHmsmPattern.firstMatch(value);
    if (match != null) {
      final h = int.tryParse(match.group(1)!);
      final m = int.tryParse(match.group(2)!);
      final s = int.tryParse(match.group(3)!);
      final millis = double.tryParse(match.group(4)!);
      if (h != null && m != null && s != null && millis != null) {
        return Duration(
          hours: h,
          minutes: m,
          seconds: s,
          milliseconds: (millis * 1000).toInt(),
        );
      }
    }

    match = _durationSmPattern.firstMatch(value);
    if (match != null) {
      final s = int.tryParse(match.group(1)!);
      final millis = double.tryParse(match.group(2)!);
      if (s != null && millis != null) {
        return Duration(
          seconds: s,
          milliseconds: (millis * 1000).toInt(),
        );
      }
    }

    return null;
  }

  // input example: '00:00:05.408000000' or '5.408000'
  static String _formatDuration(String value) {
    final duration = _parseDuration(value);
    return duration != null ? formatPreciseDuration(duration) : value;
  }

  static String _formatFilesize(dynamic value) {
    final size = value is int ? value : int.tryParse(value);
    return size != null ? formatFileSize(asciiLocale, size) : value;
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
