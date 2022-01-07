import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

@immutable
class AvesXmp extends Equatable {
  final String? xmpString;
  final String? extendedXmpString;

  @override
  List<Object?> get props => [xmpString, extendedXmpString];

  const AvesXmp({
    required this.xmpString,
    this.extendedXmpString,
  });

  static AvesXmp? fromList(List<String> xmpStrings) {
    switch (xmpStrings.length) {
      case 0:
        return null;
      case 1:
        return AvesXmp(xmpString: xmpStrings.single);
      default:
        final byExtending = groupBy<String, bool>(xmpStrings, (v) => v.contains(':HasExtendedXMP='));
        final extending = byExtending[true] ?? [];
        final extension = byExtending[false] ?? [];
        if (extending.length == 1 && extension.length == 1) {
          return AvesXmp(
            xmpString: extending.single,
            extendedXmpString: extension.single,
          );
        }

        // take the first XMP and ignore the rest when the file is weirdly constructed
        debugPrint('warning: entry has ${xmpStrings.length} XMP directories, xmpStrings=$xmpStrings');
        return AvesXmp(xmpString: xmpStrings.firstOrNull);
    }
  }
}
