import 'package:aves/model/entry/entry.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

@immutable
class NamingPattern {
  final List<NamingProcessor> processors;

  static final processorPattern = RegExp(r'<(.+?)(,(.+?))?>');
  static const processorOptionSeparator = ',';
  static const optionKeyValueSeparator = '=';

  const NamingPattern(this.processors);

  factory NamingPattern.from({
    required String userPattern,
    required int entryCount,
  }) {
    final processors = <NamingProcessor>[];

    const defaultCounterStart = 1;
    final defaultCounterPadding = '$entryCount'.length;

    var index = 0;
    final matches = processorPattern.allMatches(userPattern);
    matches.forEach((match) {
      final start = match.start;
      final end = match.end;
      if (index < start) {
        processors.add(LiteralNamingProcessor(userPattern.substring(index, start)));
        index = start;
      }
      final processorKey = match.group(1);
      final processorOptions = match.group(3);
      switch (processorKey) {
        case DateNamingProcessor.key:
          if (processorOptions != null) {
            processors.add(DateNamingProcessor(processorOptions.trim()));
          }
          break;
        case NameNamingProcessor.key:
          processors.add(const NameNamingProcessor());
          break;
        case CounterNamingProcessor.key:
          int? start, padding;
          _applyProcessorOptions(processorOptions, (key, value) {
            final valueInt = int.tryParse(value);
            if (valueInt != null) {
              switch (key) {
                case CounterNamingProcessor.optionStart:
                  start = valueInt;
                  break;
                case CounterNamingProcessor.optionPadding:
                  padding = valueInt;
                  break;
              }
            }
          });
          processors.add(CounterNamingProcessor(start: start ?? defaultCounterStart, padding: padding ?? defaultCounterPadding));
          break;
        default:
          debugPrint('unsupported naming processor: ${match.group(0)}');
          break;
      }
      index = end;
    });
    if (index < userPattern.length) {
      processors.add(LiteralNamingProcessor(userPattern.substring(index, userPattern.length)));
    }

    return NamingPattern(processors);
  }

  static void _applyProcessorOptions(String? processorOptions, void Function(String key, String value) applyOption) {
    if (processorOptions != null) {
      processorOptions.split(processorOptionSeparator).map((v) => v.trim()).forEach((kv) {
        final parts = kv.split(optionKeyValueSeparator);
        if (parts.length >= 2) {
          final key = parts[0];
          final value = parts.skip(1).join(optionKeyValueSeparator);
          applyOption(key, value);
        }
      });
    }
  }

  static int getInsertionOffset(String userPattern, int offset) {
    offset = offset.clamp(0, userPattern.length);
    final matches = processorPattern.allMatches(userPattern);
    for (final match in matches) {
      final start = match.start;
      final end = match.end;
      if (offset <= start) return offset;
      if (offset <= end) return end;
    }
    return offset;
  }

  static String defaultPatternFor(String processorKey) {
    switch (processorKey) {
      case DateNamingProcessor.key:
        return '<$processorKey, yyyyMMdd-HHmmss>';
      case CounterNamingProcessor.key:
      case NameNamingProcessor.key:
      default:
        return '<$processorKey>';
    }
  }

  String apply(AvesEntry entry, int index) => processors.map((v) => v.process(entry, index) ?? '').join().trimLeft();
}

@immutable
abstract class NamingProcessor extends Equatable {
  const NamingProcessor();

  String? process(AvesEntry entry, int index);
}

@immutable
class LiteralNamingProcessor extends NamingProcessor {
  final String text;

  @override
  List<Object?> get props => [text];

  const LiteralNamingProcessor(this.text);

  @override
  String? process(AvesEntry entry, int index) => text;
}

@immutable
class DateNamingProcessor extends NamingProcessor {
  static const key = 'date';

  final DateFormat format;

  @override
  List<Object?> get props => [format.pattern];

  DateNamingProcessor(String pattern) : format = DateFormat(pattern);

  @override
  String? process(AvesEntry entry, int index) {
    final date = entry.bestDate;
    return date != null ? format.format(date) : null;
  }
}

@immutable
class NameNamingProcessor extends NamingProcessor {
  static const key = 'name';

  @override
  List<Object?> get props => [];

  const NameNamingProcessor();

  @override
  String? process(AvesEntry entry, int index) => entry.filenameWithoutExtension;
}

@immutable
class CounterNamingProcessor extends NamingProcessor {
  final int start;
  final int padding;

  static const key = 'counter';
  static const optionStart = 'start';
  static const optionPadding = 'padding';

  @override
  List<Object?> get props => [start, padding];

  const CounterNamingProcessor({
    required this.start,
    required this.padding,
  });

  @override
  String? process(AvesEntry entry, int index) => '${index + start}'.padLeft(padding, '0');
}
