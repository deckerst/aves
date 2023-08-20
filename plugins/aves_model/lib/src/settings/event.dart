import 'package:meta/meta.dart';

@immutable
class SettingsChangedEvent {
  final String key;
  final dynamic oldValue;
  final dynamic newValue;

  // old and new values as stored, e.g. `List<String>` for collections
  const SettingsChangedEvent(this.key, this.oldValue, this.newValue);
}
