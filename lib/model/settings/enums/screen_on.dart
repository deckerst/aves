import 'package:aves/services/common/services.dart';
import 'package:aves_model/aves_model.dart';

extension ExtraKeepScreenOn on KeepScreenOn {
  void apply() {
    windowService.keepScreenOn(this == KeepScreenOn.always);
  }
}
