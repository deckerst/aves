import 'package:meta/meta.dart';

@immutable
class const SettingsChangedEvent(
  final String key,
  // old and new values as stored, e.g. `List<String>` for collections
  final Object? oldValue,
  final Object? newValue,
);
