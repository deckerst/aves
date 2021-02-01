import 'package:aves/model/entry.dart';

class HeroInfo {
  final AvesEntry entry;

  const HeroInfo(this.entry);

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is HeroInfo && other.entry == entry;
  }

  @override
  int get hashCode => entry.hashCode;
}
