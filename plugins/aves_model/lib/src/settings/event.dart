import 'package:meta/meta.dart';

@immutable
class SettingsChangedEvent {
  final String key;
  final Object? oldValue;
  final Object? newValue;

  // old and new values as stored, e.g. `List<String>` for collections
  const SettingsChangedEvent(this.key, this.oldValue, this.newValue);
}
