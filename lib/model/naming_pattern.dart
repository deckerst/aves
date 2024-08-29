import 'package:aves/convert/convert.dart';
import 'package:aves/model/entry/entry.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves_model/aves_model.dart';
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
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
    required String locale,
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
        case CounterNamingProcessor.key:
          int? start, padding;
          _applyProcessorOptions(processorOptions, (key, value) {
            final valueInt = int.tryParse(value);
            if (valueInt != null) {
              switch (key) {
                case CounterNamingProcessor.optionStart:
                  start = valueInt;
                case CounterNamingProcessor.optionPadding:
                  padding = valueInt;
              }
            }
          });
          processors.add(CounterNamingProcessor(start: start ?? defaultCounterStart, padding: padding ?? defaultCounterPadding));
        case DateNamingProcessor.key:
          if (processorOptions != null) {
            processors.add(DateNamingProcessor(processorOptions.trim(), locale));
          }
        case HashNamingProcessor.key:
          if (processorOptions != null) {
            processors.add(HashNamingProcessor(processorOptions.trim()));
          }
        case MetadataFieldNamingProcessor.key:
          if (processorOptions != null) {
            processors.add(MetadataFieldNamingProcessor(processorOptions.trim()));
          }
        case NameNamingProcessor.key:
          processors.add(const NameNamingProcessor());
        case TagsNamingProcessor.key:
          processors.add(TagsNamingProcessor(processorOptions?.trim() ?? ''));
        default:
          debugPrint('unsupported naming processor: ${match.group(0)}');
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
      case HashNamingProcessor.key:
        return '<$processorKey, md5>';
      case TagsNamingProcessor.key:
        return '<$processorKey, ->';
      case CounterNamingProcessor.key:
      case NameNamingProcessor.key:
      default:
        if (processorKey.startsWith(MetadataFieldNamingProcessor.key)) {
          final field = MetadataFieldNamingProcessor.fieldFromKey(processorKey);
          return '<${MetadataFieldNamingProcessor.key}, $field>';
        }
        return '<$processorKey>';
    }
  }

  Future<String> apply(AvesEntry entry, int index) async {
    final fields = processors.expand((v) => v.getRequiredFields()).toSet();
    final fieldValues = await metadataFetchService.getFields(entry, fields);
    return processors.map((v) => v.process(entry, index, fieldValues) ?? '').join().trim();
  }
}

@immutable
abstract class NamingProcessor extends Equatable {
  const NamingProcessor();

  String? process(AvesEntry entry, int index, Map<String, dynamic> fieldValues);

  Set<MetadataField> getRequiredFields() => {};
}

@immutable
class LiteralNamingProcessor extends NamingProcessor {
  final String text;

  @override
  List<Object?> get props => [text];

  const LiteralNamingProcessor(this.text);

  @override
  String? process(AvesEntry entry, int index, Map<String, dynamic> fieldValues) => text;
}

@immutable
class DateNamingProcessor extends NamingProcessor {
  static const key = 'date';

  final DateFormat format;

  @override
  List<Object?> get props => [format.pattern];

  DateNamingProcessor(String pattern, String locale) : format = DateFormat(pattern, locale);

  @override
  String? process(AvesEntry entry, int index, Map<String, dynamic> fieldValues) {
    final date = entry.bestDate;
    return date != null ? format.format(date) : null;
  }
}

@immutable
class TagsNamingProcessor extends NamingProcessor {
  static const key = 'tags';
  static const defaultSeparator = ' ';

  final String separator;

  @override
  List<Object?> get props => [separator];

  TagsNamingProcessor(String separator) : separator = separator.isEmpty ? defaultSeparator : separator;

  @override
  String? process(AvesEntry entry, int index, Map<String, dynamic> fieldValues) {
    return entry.tags.join(separator);
  }
}

@immutable
class MetadataFieldNamingProcessor extends NamingProcessor {
  static const key = 'field';

  static String keyWithField(MetadataField field) => '$key-${field.name}';

  // loose, for user to see and later parse
  static String fieldFromKey(String keyWithField) => keyWithField.substring(key.length + 1);

  late final MetadataField? field;

  @override
  List<Object?> get props => [field];

  MetadataFieldNamingProcessor(String field) {
    final lowerField = field.toLowerCase();
    this.field = MetadataField.values.firstWhereOrNull((v) => v.name.toLowerCase() == lowerField);
  }

  @override
  Set<MetadataField> getRequiredFields() => {field}.whereNotNull().toSet();

  @override
  String? process(AvesEntry entry, int index, Map<String, dynamic> fieldValues) {
    return fieldValues[field?.toPlatform]?.toString();
  }
}

@immutable
class NameNamingProcessor extends NamingProcessor {
  static const key = 'name';

  @override
  List<Object?> get props => [];

  const NameNamingProcessor();

  @override
  String? process(AvesEntry entry, int index, Map<String, dynamic> fieldValues) => entry.filenameWithoutExtension;
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
  String? process(AvesEntry entry, int index, Map<String, dynamic> fieldValues) => '${index + start}'.padLeft(padding, '0');
}

@immutable
class HashNamingProcessor extends NamingProcessor {
  static const key = 'hash';
  static const optionFunction = 'function';

  late final MetadataField? function;

  @override
  List<Object?> get props => [function];

  HashNamingProcessor(String function) {
    final lowerField = 'hash${function.toLowerCase()}';
    this.function = MetadataField.values.firstWhereOrNull((v) => v.name.toLowerCase() == lowerField);
  }

  @override
  Set<MetadataField> getRequiredFields() => {function}.whereNotNull().toSet();

  @override
  String? process(AvesEntry entry, int index, Map<String, dynamic> fieldValues) {
    return fieldValues[function?.toPlatform]?.toString();
  }
}
