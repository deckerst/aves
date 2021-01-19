import 'package:flutter/widgets.dart';

extension ExtraContext on BuildContext {
  String get currentRouteName => ModalRoute.of(this)?.settings?.name;
}
