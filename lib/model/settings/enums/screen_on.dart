import 'package:aves/model/settings/enums/enums.dart';
import 'package:aves/services/common/services.dart';

extension ExtraKeepScreenOn on KeepScreenOn {
  void apply() {
    windowService.keepScreenOn(this == KeepScreenOn.always);
  }
}
